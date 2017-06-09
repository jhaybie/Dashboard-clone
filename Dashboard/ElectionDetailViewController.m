//
//  ElectionDetailViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionDetailViewController.h"
#import "Candidate.h"
#import "Constant.h"
#import "Contact.h"
#import "DBCheckboxButton.h"
#import "Election.h"
#import "ElectionCardView.h"
#import "GlobalAPI.h"
#import "OtherElection.h"
#import "PinnedHeaderView.h"
#import "Race.h"
#import "UIColor+DBColors.h"

@interface ElectionDetailViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *electionCardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *electionCardViewHeightConstraint;
@property (nonatomic, strong) IBOutlet UITextView *candidatesTextView;
@property (nonatomic, strong) IBOutlet UIView *contactListView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactListViewHeightConstraint;
@property (nonatomic, strong) IBOutlet UIButton *bulkEmailButton;
@property (nonatomic, strong) IBOutlet UIButton *bulkTextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) IBOutlet UILabel *contactsHeaderLabel;
@property (nonatomic, strong) UIView/*PinnedHeaderView*/ *pinnedHeaderView;

@property (strong, nonatomic) NSArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<Contact *> *selectedContacts;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bulkViewHeightConstraint;

@end

@implementation ElectionDetailViewController
BOOL isPinnedHeaderViewVisible;

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self displaySelectedElectionCard];
    
    self.bulkEmailButton.backgroundColor = [UIColor globalFailureColorDisabled];
    self.bulkTextButton.backgroundColor = [UIColor dbBlue2Disabled];
    
    [self.previousButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [self.nextButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!isPinnedHeaderViewVisible) {
        [self updateScrollViewContentSize];
    }
}

#pragma mark - Private Methods

- (void)displayContactList {
    self.contacts = (self.forContacts) ? self.otherElections[self.electionIndex.section].contacts : [[NSArray alloc] init];
    
    if (self.contacts.count == 0) {
        [self.contactsHeaderLabel removeFromSuperview];
    }
    
    self.contactsHeaderLabel.hidden = false;
    ContactListView *clv = [[ContactListView alloc] initWithContacts:self.contacts];
    self.contactListViewHeightConstraint.constant = clv.frame.size.height;
    CGRect frame = self.contactListView.frame;
    int width = [[UIScreen mainScreen] bounds].size.width - 48;
    clv.frame = CGRectMake(0, 0, width, clv.frame.size.height);
    self.contactListView.frame = CGRectMake(frame.origin.x, frame.origin.y, width, clv.frame.size.height);
    clv.delegate = self;
    [self.contactListView addSubview:clv];
    [self.scrollView setNeedsDisplay];
}

- (void)displayElectionDetails {
    Election *election = (self.forContacts) ? self.otherElections[self.electionIndex.section].election : self.elections[self.electionIndex.section];
    Race *race = election.races[self.electionIndex.row];
    self.candidatesTextView.text = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    // display Election Name
    NSString *electionNameString = [NSString stringWithFormat:@"%@\n\n", election.electionName];
    NSMutableAttributedString *aElectionNameString = [[NSMutableAttributedString alloc] initWithString:electionNameString];
    [aElectionNameString addAttribute:NSFontAttributeName
                               value:[UIFont boldSystemFontOfSize:16.0]
                               range:NSMakeRange(0, electionNameString.length)];
    [aElectionNameString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, electionNameString.length)];
    
    [attributedString appendAttributedString:aElectionNameString];
    
    // display state info
    if (race.state.length > 0) {
        NSString *stateHeaderString = @"State\n";
        NSMutableAttributedString *aStateHeaderString = [[NSMutableAttributedString alloc] initWithString:stateHeaderString];
        [aStateHeaderString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:16.0]
                                   range:NSMakeRange(0, stateHeaderString.length)];
        [aStateHeaderString addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor whiteColor]
                                   range:NSMakeRange(0, stateHeaderString.length)];
        
        [attributedString appendAttributedString:aStateHeaderString];
        
        NSString *stateBodyString = [NSString stringWithFormat:@"%@\n\n", election.races[0].state];
        NSMutableAttributedString *aStateBodyString = [[NSMutableAttributedString alloc] initWithString:stateBodyString];
        [aStateBodyString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:14.0]
                                 range:NSMakeRange(0, stateBodyString.length)];
        [aStateBodyString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, stateBodyString.length)];
        
        [attributedString appendAttributedString:aStateBodyString];
    }
    
    // display city info
    if (race.city.length > 0) {
        NSString *cityHeaderString = @"City\n";
        NSMutableAttributedString *aCityHeaderString = [[NSMutableAttributedString alloc] initWithString:cityHeaderString];
        [aCityHeaderString addAttribute:NSFontAttributeName
                                  value:[UIFont boldSystemFontOfSize:16.0]
                                  range:NSMakeRange(0, cityHeaderString.length)];
        [aCityHeaderString addAttribute:NSForegroundColorAttributeName
                                  value:[UIColor whiteColor]
                                  range:NSMakeRange(0, cityHeaderString.length)];
        
        [attributedString appendAttributedString:aCityHeaderString];
        
        NSString *cityBodyString = [NSString stringWithFormat:@"%@\n\n", election.races[0].city];
        NSMutableAttributedString *aCityBodyString = [[NSMutableAttributedString alloc] initWithString:cityBodyString];
        [aCityBodyString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:14.0]
                                range:NSMakeRange(0, cityBodyString.length)];
        [aCityBodyString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor whiteColor]
                                range:NSMakeRange(0, cityBodyString.length)];
        
        [attributedString appendAttributedString:aCityBodyString];
    }
    
    // display special district info
    if (race.specialDistrict.length > 0) {
        NSString *sdHeaderString = @"Special District\n";
        NSMutableAttributedString *aSDHeaderString = [[NSMutableAttributedString alloc] initWithString:sdHeaderString];
        [aSDHeaderString addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:16.0]
                                range:NSMakeRange(0, sdHeaderString.length)];
        [aSDHeaderString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor whiteColor]
                                range:NSMakeRange(0, sdHeaderString.length)];
        
        [attributedString appendAttributedString:aSDHeaderString];
        
        NSString *sdBodyString = [NSString stringWithFormat:@"%@\n\n", election.races[0].city];
        NSMutableAttributedString *aSDBodyString = [[NSMutableAttributedString alloc] initWithString:sdBodyString];
        [aSDBodyString addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:14.0]
                              range:NSMakeRange(0, sdBodyString.length)];
        [aSDBodyString addAttribute:NSForegroundColorAttributeName
                              value:[UIColor whiteColor]
                              range:NSMakeRange(0, sdBodyString.length)];
        
        [attributedString appendAttributedString:aSDBodyString];
    }
    
    NSString *incumbentName = @"";
    // display candidate info
    if (race.candidates.count > 0) {
        NSString *candidateHeaderString = @"Candidates\n";
        NSMutableAttributedString *aCandidateHeaderString = [[NSMutableAttributedString alloc] initWithString:candidateHeaderString];
        [aCandidateHeaderString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:16.0]
                                       range:NSMakeRange(0, candidateHeaderString.length)];
        [aCandidateHeaderString addAttribute:NSForegroundColorAttributeName
                                       value:[UIColor whiteColor]
                                       range:NSMakeRange(0, candidateHeaderString.length)];
        
        [attributedString appendAttributedString:aCandidateHeaderString];
        
        NSString *candidateBodyString = @"";
        for (Candidate *candidate in election.races[0].candidates) {
            NSString *name = [NSString stringWithFormat:@"%@ %@ %@", candidate.firstName, candidate.middleName, candidate.lastName];
            if (name.length > 2) {
                name = [name stringByAppendingString:[NSString stringWithFormat:@" (%@)\n", candidate.party]];
            }
            candidateBodyString = [candidateBodyString stringByAppendingString:name];
            if (candidate.isIncumbent) {
                incumbentName = name;
            }
        }
        
        if ([candidateBodyString stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
            candidateBodyString = @"This election is pending and candidates have not yet been announced. This information will be updated when it is available.\n";
        }
        
        NSMutableAttributedString *aCandidateBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", candidateBodyString]];
        [aCandidateBodyString addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:14.0]
                                     range:NSMakeRange(0, candidateBodyString.length)];
        [aCandidateBodyString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:NSMakeRange(0, candidateBodyString.length)];
        
        [attributedString appendAttributedString:aCandidateBodyString];
    }
    
    // display incumbent info
    if (incumbentName.length > 0) {
        NSString *incumbentHeaderString = @"Incumbent\n";
        NSMutableAttributedString *aIncumbentHeaderString = [[NSMutableAttributedString alloc] initWithString:incumbentHeaderString];
        [aIncumbentHeaderString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:16.0]
                                       range:NSMakeRange(0, incumbentHeaderString.length)];
        [aIncumbentHeaderString addAttribute:NSForegroundColorAttributeName
                                       value:[UIColor whiteColor]
                                       range:NSMakeRange(0, incumbentHeaderString.length)];
        
        [attributedString appendAttributedString:aIncumbentHeaderString];
        
        NSString *incumbentBodyString = [NSString stringWithFormat:@"%@\n\n", incumbentName];
        NSMutableAttributedString *aIncumbentBodyString = [[NSMutableAttributedString alloc] initWithString:incumbentBodyString];
        [aIncumbentBodyString addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:14.0]
                                     range:NSMakeRange(0, incumbentBodyString.length)];
        [aIncumbentBodyString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:NSMakeRange(0, incumbentBodyString.length)];
        
        [attributedString appendAttributedString:aIncumbentBodyString];
    }
    
    // display election date info
    NSString *electionDateHeaderString = @"Election Date\n";
    NSMutableAttributedString *aElectionDateHeaderString = [[NSMutableAttributedString alloc] initWithString:electionDateHeaderString];
    [aElectionDateHeaderString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:16.0]
                                   range:NSMakeRange(0, electionDateHeaderString.length)];
    [aElectionDateHeaderString addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor whiteColor]
                                   range:NSMakeRange(0, electionDateHeaderString.length)];
    
    [attributedString appendAttributedString:aElectionDateHeaderString];
    
    NSString *electionDateBodyString = [NSDateFormatter localizedStringFromDate:election.electionDate
                                                                      dateStyle:NSDateFormatterMediumStyle
                                                                      timeStyle:NSDateFormatterNoStyle];
    NSMutableAttributedString *aElectionDateBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", electionDateBodyString]];
    [aElectionDateBodyString addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:14.0]
                                 range:NSMakeRange(0, electionDateBodyString.length)];
    [aElectionDateBodyString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, electionDateBodyString.length)];
    
    [attributedString appendAttributedString:aElectionDateBodyString];
    
    // display election time info
    if (election.electionDateTimesString.length > 0) {
        NSString *etHeaderString = @"Approximate Election Times\n";
        NSMutableAttributedString *aETHeaderString = [[NSMutableAttributedString alloc] initWithString:etHeaderString];
        [aETHeaderString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:16.0]
                                       range:NSMakeRange(0, etHeaderString.length)];
        [aETHeaderString addAttribute:NSForegroundColorAttributeName
                                       value:[UIColor whiteColor]
                                       range:NSMakeRange(0, etHeaderString.length)];
        
        [attributedString appendAttributedString:aETHeaderString];
        
        NSString *etBodyString = election.electionDateTimesString;
        NSMutableAttributedString *aETBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", etBodyString]];
        [aETBodyString addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:14.0]
                                     range:NSMakeRange(0, etBodyString.length)];
        [aETBodyString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:NSMakeRange(0, etBodyString.length)];
        
        [attributedString appendAttributedString:aETBodyString];
    }
    
    // display early voting date info
    if (election.earlyVotinDatesString.length > 0) {
        NSString *evdHeaderString = @"Early Voting Dates\n";
        NSMutableAttributedString *aEVDHeaderString = [[NSMutableAttributedString alloc] initWithString:evdHeaderString];
        [aEVDHeaderString addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:16.0]
                                range:NSMakeRange(0, evdHeaderString.length)];
        [aEVDHeaderString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor whiteColor]
                                range:NSMakeRange(0, evdHeaderString.length)];
        
        [attributedString appendAttributedString:aEVDHeaderString];
        
        NSString *evdBodyString = election.earlyVotinDatesString;
        NSMutableAttributedString *aEVDBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", evdBodyString]];
        [aEVDBodyString addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:14.0]
                              range:NSMakeRange(0, evdBodyString.length)];
        [aEVDBodyString addAttribute:NSForegroundColorAttributeName
                              value:[UIColor whiteColor]
                              range:NSMakeRange(0, evdBodyString.length)];
        
        [attributedString appendAttributedString:aEVDBodyString];
    }

    // display early voting time info
    if (election.earlyVotingTimesString.length > 0) {
        NSString *evtHeaderString = @"Approximate Early Voting Times\n";
        NSMutableAttributedString *aEVTHeaderString = [[NSMutableAttributedString alloc] initWithString:evtHeaderString];
        [aEVTHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, evtHeaderString.length)];
        [aEVTHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, evtHeaderString.length)];
        
        [attributedString appendAttributedString:aEVTHeaderString];
        
        NSString *evtBodyString = election.earlyVotingTimesString;
        NSMutableAttributedString *aEVTBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", evtBodyString]];
        [aEVTBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, evtBodyString.length)];
        [aEVTBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, evtBodyString.length)];
        
        [attributedString appendAttributedString:aEVTBodyString];
    }
    
    // display early voting link
    if (election.earlyVotingURLString.length > 0) {
        NSString *eviHeaderString = @"Early Voting Info\n";
        NSMutableAttributedString *aEVIHeaderString = [[NSMutableAttributedString alloc] initWithString:eviHeaderString];
        [aEVIHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, eviHeaderString.length)];
        [aEVIHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, eviHeaderString.length)];
        
        [attributedString appendAttributedString:aEVIHeaderString];
        
        NSString *eviBodyString = election.earlyVotingURLString;
        NSMutableAttributedString *aEVIBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", eviBodyString]];
        [aEVIBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, eviBodyString.length)];
        [aEVIBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, eviBodyString.length)];
        
        [attributedString appendAttributedString:aEVIBodyString];
    }
    
    // display voter registration link
    if (election.voterRegURLString.length > 0) {
        NSString *vruHeaderString = @"Voter Registration Link\n";
        NSMutableAttributedString *aVRUHeaderString = [[NSMutableAttributedString alloc] initWithString:vruHeaderString];
        [aVRUHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, vruHeaderString.length)];
        [aVRUHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, vruHeaderString.length)];
        
        [attributedString appendAttributedString:aVRUHeaderString];
        
        NSString *vruBodyString = election.voterRegURLString;
        NSMutableAttributedString *aVRUBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", vruBodyString]];
        [aVRUBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, vruBodyString.length)];
        [aVRUBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, vruBodyString.length)];
        
        [attributedString appendAttributedString:aVRUBodyString];
    }
    
    // display polling place link
    if (election.pollingPlaceURLString.length > 0) {
        NSString *ppuHeaderString = @"Polling Place Link\n";
        NSMutableAttributedString *aPPUHeaderString = [[NSMutableAttributedString alloc] initWithString:ppuHeaderString];
        [aPPUHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, ppuHeaderString.length)];
        [aPPUHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, ppuHeaderString.length)];
        
        [attributedString appendAttributedString:aPPUHeaderString];
        
        NSString *ppuBodyString = election.pollingPlaceURLString;
        NSMutableAttributedString *aPPUBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", ppuBodyString]];
        [aPPUBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, ppuBodyString.length)];
        [aPPUBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, ppuBodyString.length)];
        
        [attributedString appendAttributedString:aPPUBodyString];
    }
    
    // display absentee voting deadline info
    if (election.absenteeVotingDeadlines.length > 0) {
        NSString *avdHeaderString = @"Absentee Voting Deadlines\n";
        NSMutableAttributedString *aAVDHeaderString = [[NSMutableAttributedString alloc] initWithString:avdHeaderString];
        [aAVDHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, avdHeaderString.length)];
        [aAVDHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, avdHeaderString.length)];
        
        [attributedString appendAttributedString:aAVDHeaderString];
        
        NSString *avdBodyString = election.absenteeVotingDeadlines;
        NSMutableAttributedString *aAVDBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", avdBodyString]];
        [aAVDBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, avdBodyString.length)];
        [aAVDBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, avdBodyString.length)];
        
        [attributedString appendAttributedString:aAVDBodyString];
    }
    
    // display absentee voter link
    if (election.absenteeVotingURLString.length > 0) {
        NSString *avuHeaderString = @"Absentee Voting Deadlines\n";
        NSMutableAttributedString *aAVUHeaderString = [[NSMutableAttributedString alloc] initWithString:avuHeaderString];
        [aAVUHeaderString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:16.0]
                                 range:NSMakeRange(0, avuHeaderString.length)];
        [aAVUHeaderString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, avuHeaderString.length)];
        
        [attributedString appendAttributedString:aAVUHeaderString];
        
        NSString *avuBodyString = election.absenteeVotingURLString;
        NSMutableAttributedString *aAVUBodyString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", avuBodyString]];
        [aAVUBodyString addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:14.0]
                               range:NSMakeRange(0, avuBodyString.length)];
        [aAVUBodyString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, avuBodyString.length)];
        
        [attributedString appendAttributedString:aAVUBodyString];
    }
    
    self.candidatesTextView.attributedText = attributedString;
}

- (void)displaySelectedElectionCard {
    self.selectedContacts = [[NSMutableArray alloc] init];
    
    for (UIView *view in self.electionCardView.subviews) {
        [view removeFromSuperview];
    }
    Election *election = (self.forContacts) ? self.otherElections[self.electionIndex.section].election : self.elections[self.electionIndex.section];
    Race *race = election.races[self.electionIndex.row];
    
    DetailCardView *dcv = [[DetailCardView alloc] initWithRace:race forDate:election.electionDate];
    dcv.delegate = self;
    [self.electionCardView addSubview:dcv];
    
    if (isPinnedHeaderViewVisible) {
        [self.pinnedHeaderView removeFromSuperview];
    }
    CGRect pinnedFrame = CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, dcv.positionView.frame.size.height + 10);
    self.pinnedHeaderView = [[PinnedHeaderView alloc] initWithPosition:[NSString stringWithFormat:@"%@ (%@)", election.races[0].raceName, election.races[0].state]];
    self.pinnedHeaderView.frame = pinnedFrame;

    if (isPinnedHeaderViewVisible) {
        [self.view addSubview:self.pinnedHeaderView];
    }
    
    self.bulkViewHeightConstraint.constant = (self.forContacts) ? 50 : 0;
    
    [self.view layoutSubviews];
    
    [self displayElectionDetails];
    [self displayContactList];
    [self updateButtonStatus];
}

- (void)updateBulkButtonStatus {
    if (self.selectedContacts.count == 0) {
        self.bulkEmailButton.enabled = false;
        self.bulkTextButton.enabled = false;
        self.bulkEmailButton.backgroundColor = [UIColor globalFailureColorDisabled];
        self.bulkTextButton.backgroundColor = [UIColor dbBlue2Disabled];
    } else {
        BOOL shouldEnableBulkEmail = false;
        BOOL shouldEnableBulkText = false;
        
        for (Contact *contact in self.selectedContacts) {
            if (contact.email.length > 0) {
                shouldEnableBulkEmail = true;
            }
            if (contact.mobile.length > 0) {
                shouldEnableBulkText = true;
            }
        }
        
        UIColor *emailColor = (shouldEnableBulkEmail) ? [UIColor globalFailureColor] : [UIColor globalFailureColorDisabled];
        UIColor *textColor = (shouldEnableBulkText) ? [UIColor dbBlue2] : [UIColor dbBlue2Disabled];
        self.bulkEmailButton.enabled = shouldEnableBulkEmail;
        self.bulkTextButton.enabled = shouldEnableBulkText;
        self.bulkEmailButton.backgroundColor = emailColor;
        self.bulkTextButton.backgroundColor = textColor;
    }
}

- (void)updateButtonStatus {
    BOOL isAtBeginning = (self.electionIndex.section == 0 && self.electionIndex.row == 0);
    self.previousButton.enabled = !isAtBeginning;
    
    BOOL isAtEnd = false;
    if (self.forContacts) {
        isAtEnd = (self.electionIndex.section == self.otherElections.count - 1) && (self.electionIndex.row == [self.otherElections lastObject].election.races.count - 1);
    } else {
        isAtEnd = (self.electionIndex.section == self.elections.count - 1) && (self.electionIndex.row == [self.elections lastObject].races.count - 1);
    }
    self.nextButton.enabled = !isAtEnd;
}

- (void)updateScrollViewContentSize {
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    CGRect lastFrame = CGRectMake(0, contentRect.size.height, contentRect.size.width, 24);
    contentRect = CGRectUnion(contentRect, lastFrame);
    self.scrollView.contentSize = contentRect.size;
}

#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)bulkEmailButtonTapped:(id)sender {
    NSMutableArray<NSString *> *recipients = [[NSMutableArray alloc] init];
    for (Contact *contact in self.selectedContacts) {
        if (contact.email.length > 0) {
            [recipients addObject:contact.email];
        }
    }
    
    NSString *emailTitle = @"Test Email";
    NSString *messageBody = @"This is a test email.";
    
    MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
    messageController.mailComposeDelegate = self;
    [messageController setSubject:emailTitle];
    [messageController setMessageBody:messageBody isHTML:NO];
    [messageController setToRecipients:recipients];
    
    [self presentViewController:messageController
                       animated:true
                     completion:nil];
}

- (IBAction)bulkTextButtonTapped:(id)sender {
    NSMutableArray<NSString *> *recipients = [[NSMutableArray alloc] init];
    for (Contact *contact in self.selectedContacts) {
        if (contact.mobile.length > 0) {
            [recipients addObject:contact.mobile];
        }
    }
    
    NSString *message = @"This is a test message.";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    [self presentViewController:messageController
                       animated:true
                     completion:nil];}

- (IBAction)previousButtonTapped:(id)sender {
    if (self.electionIndex.row > 0) {
        self.electionIndex = [NSIndexPath indexPathForRow:self.electionIndex.row - 1 inSection:self.electionIndex.section];
    } else if (self.electionIndex.section > 0) {
        self.electionIndex = [NSIndexPath indexPathForRow:self.electionIndex.row inSection:self.electionIndex.section - 1];
    } else {
        self.electionIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self displaySelectedElectionCard];
}

- (IBAction)nextButtonTapped:(id)sender {
    if (self.forContacts) {
        if (self.electionIndex.row < self.otherElections[self.electionIndex.section].election.races.count - 1) {
            self.electionIndex = [NSIndexPath indexPathForRow:self.electionIndex.row + 1 inSection:self.electionIndex.section];
        } else if (self.electionIndex.section < self.otherElections.count - 1) {
            self.electionIndex = [NSIndexPath indexPathForRow:0 inSection:self.electionIndex.section + 1];
        } else {
            self.electionIndex = [NSIndexPath indexPathForRow:[self.otherElections lastObject].election.races.count - 1 inSection:self.otherElections.count - 1];
        }
    } else {
        if (self.electionIndex.row < self.elections[self.electionIndex.section].races.count - 1) {
            self.electionIndex = [NSIndexPath indexPathForRow:self.electionIndex.row + 1 inSection:self.electionIndex.section];
        } else if (self.electionIndex.section < self.elections.count - 1) {
            self.electionIndex = [NSIndexPath indexPathForRow:0 inSection:self.electionIndex.section + 1];
        } else {
            self.electionIndex = [NSIndexPath indexPathForRow:[self.elections lastObject].races.count - 1 inSection:self.elections.count - 1];
        }
    }
    [self displaySelectedElectionCard];
}

#pragma mark - ContactListView Delegate Methods

- (void)checkBoxButtonTapped:(DBCheckboxButton *)sender {
    if (sender.isChecked) {
        [self.selectedContacts addObject:self.contacts[sender.tag]];
    } else {
        NSString *contactID = self.contacts[sender.tag].contactID;
        NSMutableArray<Contact *> *selectedContactsCopy = [[NSMutableArray alloc] initWithArray:self.selectedContacts];
        for (int i = 0; i < selectedContactsCopy.count; i++) {
            if ([contactID isEqualToString:selectedContactsCopy[i].contactID]) {
                [self.selectedContacts removeObjectAtIndex:i];
            }
        }
    }
    [self updateBulkButtonStatus];
}

- (void)emailButtonTapped:(id)sender {
    int index = (int)((UIButton *)sender).tag;
    NSArray *recipients = @[self.contacts[index].email];
    NSString *emailTitle = @"You've been invited to join EveryElection";
    
    NSString *raceName = (self.forContacts) ? self.otherElections[self.electionIndex.section].election.races[self.electionIndex.row].raceName : self.elections[self.electionIndex.section].races[self.electionIndex.row].raceName;
    NSString *electionName = (self.forContacts) ? self.otherElections[self.electionIndex.section].election.electionName : self.elections[self.electionIndex.section].electionName;
    NSDate *electionDate = (self.forContacts) ? self.otherElections[self.electionIndex.section].election.electionDate : self.elections[self.electionIndex.section].electionDate;
    NSString *electionDateString = [NSDateFormatter localizedStringFromDate:electionDate
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterNoStyle];
//    NSString *candidateString = @"";
//    Race *race = (self.forContacts) ? self.otherElections[self.electionIndex.section].election.races[self.electionIndex.row] : self.elections[self.electionIndex.section].races[self.electionIndex.row];
//    for (int i = 0; i < race.candidates.count; i++) {
//        Candidate *c = race.candidates[i];
//        if (c.firstName.length > 0 && c.lastName.length > 0) {
//            if (i < race.candidates.count - 1) {
//                candidateString = [candidateString stringByAppendingString:[NSString stringWithFormat:@"%@ %@,", c.firstName, c.lastName]];
//            }
//        }
//    }
    
    NSString *messageBody = [NSString stringWithFormat:@"Hey!\n\nI was just tracking upcoming government elections using the EveryElections app and I noticed that you can vote in the upcoming %@ race in the %@ election! Just wanted to let you know.\n\nThe election will be held on %@.\n\nYou can get more info about this and other elections by downloading the EveryElections app!\n\n", raceName, electionName, electionDateString];
    MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
    messageController.mailComposeDelegate = self;
    [messageController setSubject:emailTitle];
    [messageController setMessageBody:messageBody isHTML:NO];
    [messageController setToRecipients:recipients];
    
    [self presentViewController:messageController animated:YES completion:NULL];
}

- (void)smsButtonTapped:(id)sender {
    int index = (int)((UIButton *)sender).tag;
    NSString *smsString = self.contacts[index].mobile;
    
    NSArray *recipients = @[smsString];
    
    NSString *electionState = (self.forContacts) ? self.otherElections[self.electionIndex.section].election.state : self.elections[self.electionIndex.section].state;
    NSString *message = [NSString stringWithFormat:@"Hey! You can vote in an upcoming election in %@!  Learn more about by downloading the EveryElections app!", electionState];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    [self presentViewController:messageController
                       animated:true
                     completion:nil];
}

- (void)phoneButtonTapped:(id)sender {
    int index = (int)((UIButton *)sender).tag;
    NSString *dialerString = [NSString stringWithFormat:@"telprompt://%@", self.contacts[index].phone];
    NSURL *phoneURL = [NSURL URLWithString:dialerString];
    [[UIApplication sharedApplication] openURL:phoneURL
                                       options:@{}
                             completionHandler:nil];
}

#pragma mark - MFMailComposeViewController Delegate Method

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                           message:@"Something went wrong"
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            [self presentViewController:alert
                               animated:true
                             completion:nil];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MFMessageComposeViewController Delegate Method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    if (result == MessageComposeResultCancelled){
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent){
        NSLog(@"Message sent");
    }
    else{
        NSLog(@"Message failed");
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= 140) {
        [self.view addSubview:self.pinnedHeaderView];
        isPinnedHeaderViewVisible = true;
    } else {
        [self.pinnedHeaderView removeFromSuperview];
        isPinnedHeaderViewVisible = false;
    }
    
}

#pragma mark - DetailCardView Delegate Method

- (void)detailCardViewStatusButtonTappedMessage:(NSDictionary *)messageDict {
    NSString *title = [messageDict objectForKey:@"Title"];
    NSString *message = [messageDict objectForKey:@"Message"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert
                       animated:true
                     completion:nil];}

@end
