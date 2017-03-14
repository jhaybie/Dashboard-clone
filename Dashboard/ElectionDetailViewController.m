//
//  ElectionDetailViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionDetailViewController.h"
#import "Contact.h"
#import "DBCheckboxButton.h"
#import "Election.h"
#import "ElectionCardView.h"
#import "GlobalAPI.h"
#import "PinnedHeaderView.h"
#import "UIColor+DBColors.h"

@interface ElectionDetailViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *electionCardView;
@property (nonatomic, strong) IBOutlet UITextView *candidatesTextView;
@property (nonatomic, strong) IBOutlet UIView *contactListView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactListViewHeightConstraint;
@property (nonatomic, strong) IBOutlet UIButton *bulkEmailButton;
@property (nonatomic, strong) IBOutlet UIButton *bulkTextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) PinnedHeaderView *pinnedHeaderView;

@property (strong, nonatomic) NSArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<Contact *> *selectedContacts;

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
    [GlobalAPI getAddressBookValidContactsSuccess:^(NSArray<Contact *> *contacts) {
        self.contacts = contacts;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            ContactListView *clv = [[ContactListView alloc] initWithContacts:self.contacts];
            self.contactListViewHeightConstraint.constant = clv.frame.size.height;
            CGRect frame = self.contactListView.frame;
            clv.frame = CGRectMake(0, 0, frame.size.width, clv.frame.size.height);
            self.contactListView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, clv.frame.size.height);
            clv.delegate = self;
            [self.contactListView addSubview:clv];
            [self.scrollView setNeedsDisplay];
        }];
        
    } failure:^(NSString *message) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"There was a problem accessing your Address Book."
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert
                           animated:true
                         completion:nil];
    }];
}

- (void)displaySelectedElectionCard {
    self.selectedContacts = [[NSMutableArray alloc] init];
    
    for (UIView *view in self.electionCardView.subviews) {
        [view removeFromSuperview];
    }
    Election *election = self.elections[self.electionIndex];
    
    ElectionCardView *ecv = [[ElectionCardView alloc] initWithElection:election];
    CGRect frame = CGRectMake(-8, -8, [[UIScreen mainScreen] bounds].size.width + 16, 222);
    ecv.frame = frame; //self.electionCardView.bounds;
    ecv.badgeView.hidden = true;
    [self.electionCardView addSubview:ecv];
    
    if (isPinnedHeaderViewVisible) {
        [self.pinnedHeaderView removeFromSuperview];
    }
    CGRect pinnedFrame = CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 74);
    self.pinnedHeaderView = [[PinnedHeaderView alloc] initWithPosition:election.positionName cityState:ecv.cityStateLabel.text];
    self.pinnedHeaderView.frame = pinnedFrame;
    if (isPinnedHeaderViewVisible) {
        [self.view addSubview:self.pinnedHeaderView];
    }
    
    // TODO: update candidate textview
    
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
    self.previousButton.enabled = self.electionIndex > 0;
    self.nextButton.enabled = self.electionIndex < self.elections.count - 1;
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
    self.electionIndex == (self.electionIndex == 0) ? 0 : (self.electionIndex--);
    [self displaySelectedElectionCard];
}

- (IBAction)nextButtonTapped:(id)sender {
    if (self.electionIndex <= self.elections.count - 1) {
        self.electionIndex++;
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
    NSString *emailTitle = @"Test Email";
    NSString *messageBody = @"This is a test email.";
    
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
    NSString *message = @"This is a test message.";
    
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

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed: {
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
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
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

@end
