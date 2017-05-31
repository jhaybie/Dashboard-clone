//
//  FirstViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "HomeViewController.h"
#import "Constant.h"
#import "Contact.h"
#import "Election.h"
#import "ElectionCardCell.h"
#import "ElectionDetailViewController.h"
#import "OtherElection.h"
#import "GlobalAPI.h"
#import "LoginViewController.h"
#import "Race.h"
#import "SVProgressHUD.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *electionCards;
@property (strong, nonatomic) NSMutableArray<UIColor *> *colors;

@property (strong, nonatomic) NSArray<Election *> *elections;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTopHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UILabel *emptyTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *emptyTextView;

@property (strong, nonatomic) NSMutableArray<ElectionCardCell *> *electionCells;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray <Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<OtherElection *> *otherElections;
@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *otherElectionCards;
@property (strong, nonatomic) NSMutableArray<ElectionCardCell *> *otherElectionCells;

@end

@implementation HomeViewController
BOOL yourElectionsSelected = true;

static NSString *yourEmptyTitleString = @"We couldn't find any upcoming elections in your area.";
static NSString *yourEmptyTextViewString = @"This could be for a couple of reasons:\n\n1. Your state, county, district, municipality, and/or city have not yet listed any upcoming elections, or\n\n2. We have not received the information necessary to post its upcoming election from your city.\n\nIf you think this was in error, please email info@newfounders.us";

static NSString *contactsEmptyTitleString = @"We couldn't find any upcoming elections near your contacts.";
static NSString *contactsEmptyTextViewString = @"This could be for a couple of reasons:\n\n1. All of your contacts' states, counties, districts, municipalities, and/or cities have not yet listed any upcoming elections, or\n\n2. We have not received the information necessary to post upcoming elections from your contacts' cities or states.\n\nIf you think this was in error, please email info@newfounders.us";

#pragma mark - Override Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADDRESS_UPDATED
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![FBSDKAccessToken currentAccessToken]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        lvc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:lvc
                           animated:true
                         completion:^{
                             NSLog(@"Done!");
                             
                             // TODO: load saved credentials here
                         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldShowNagView = true;
    
    self.navigationController.navigationBar.hidden = true;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFBLoginStatusChanged)
                                                 name:FBSDKProfileDidChangeNotification
                                               object:nil];
    [self registerTableViewCells];
    
    // Enable pull-to-refresh functionality
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getElections)
                  forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
    self.colors = [[NSMutableArray alloc] init];
    [self.colors addObject:[UIColor dbBlue1]];
    [self.colors addObject:[UIColor dbBlue2]];
    [self.colors addObject:[UIColor dbBlue3]];
    [self.colors addObject:[UIColor dbBlue4]];
    [self.colors addObject:[UIColor dbBlue3]];
    [self.colors addObject:[UIColor dbBlue2]];
    
    if (IS_IPHONE_5_5_INCH) {
        self.messageTopHeightConstraint.constant = 150;
    } else if (IS_IPHONE_4_7_INCH) {
        self.messageTopHeightConstraint.constant = 100;
    }
    
    [self createObservers];
    
    [self loadUserCardView];
    
    [self getElections];
    
    [self getContactList];
}

#pragma mark - Private Methods

- (void)addContact:(Contact *)contact toOtherElection:(Election *)election {
    for (OtherElection *oE in self.otherElections) {
        if (oE.contacts.count == 0) {
            oE.contacts = [[NSMutableArray alloc] init];
        }
        if (oE.election.electionID == election.electionID) {
            BOOL found = false;
            for (Contact *c in oE.contacts) {
                if ([c.contactID isEqualToString:contact.contactID]) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                [oE.contacts addObject:contact];
                break;
            }
        }
    }
}

- (UIColor *)colorForIndex:(NSInteger)row {
    NSInteger colorIndex = (row + 1) % self.colors.count;
    return self.colors[colorIndex];
}

- (void)createObservers {
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlValueChanged)
                    forControlEvents:UIControlEventValueChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getElections)
                                                 name:ADDRESS_UPDATED object:nil];
}

- (BOOL)electionExistsInOtherElections:(Election *)election {
    int eID = election.electionID;
    for (OtherElection *e in self.otherElections) {
        if (e.election.electionID == eID) {
            return true;
        }
    }
    return false;
}

- (void)getContactList {
    self.contacts = [[NSArray alloc] init];
    [GlobalAPI getAddressBookValidContactsForced:false
                                         success:^(NSArray<Contact *> *contacts) {
                                             self.contacts = contacts;
                                             
                                             [self processContacts];
                                             
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

- (void)getElections {
    [self.refreshControl endRefreshing];
    [SVProgressHUD show];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]) {
        [GlobalAPI getElections:^(NSArray<Election *> *elections) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            self.elections = [[NSArray alloc] initWithArray:elections];
            [self processElections];
        } failure:^(NSInteger statusCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            //
        }];
    } else {
        [GlobalAPI getRandomElectionsSuccess:^(NSArray<Election *> *elections) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            self.elections = [[NSArray alloc] initWithArray:elections];
            [self processElections];
        } failure:^(NSInteger statusCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            //
        }];
    }
}

- (void)processContacts {
    self.otherElections = [[NSMutableArray alloc] init];
    self.otherElectionCards = [[NSMutableArray alloc] init];
    self.otherElectionCells = [[NSMutableArray alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (Contact *contact in self.contacts) {
        dispatch_group_enter(group);
        [GlobalAPI getElectionsForContact:contact success:^(NSArray<Election *> *elections) {
            if (elections.count > 0) {
                for (Election *election in elections) {
                    if (![self electionExistsInOtherElections:election]) {
                        OtherElection *otherElection = [[OtherElection alloc] init];
                        otherElection.election = election;
                        otherElection.contacts = [[NSMutableArray alloc] init];
                        [otherElection.contacts addObject:contact];
                        [self.otherElections addObject:otherElection];
                    } else {
                        [self addContact:contact toOtherElection:election];
                    }
                }
            }
            dispatch_group_leave(group);
        } failure:^(NSInteger statusCode) {
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self processOtherElections];
    });
}

- (void)processElections {
    self.electionCards = [[NSMutableArray alloc] init];
    self.electionCells = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.elections.count; i++) {
        Election *election = self.elections[i];
        for (Race *race in election.races) {
            // TODO: maybe add some logic to filter out extraneous races???
            ElectionCardView *ecv = [[ElectionCardView alloc] initWithRace:race forDate:election.electionDate forContact:false contactCount:0 preferredWidth:[[UIScreen mainScreen] bounds].size.width - 16];
            ecv.delegate = self;
            ecv.positionView.backgroundColor = [self colorForIndex:i];
            [self.electionCards addObject:ecv];
            
            ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:ecv];
            [self.electionCells addObject:cell];
        }
    }
    if (self.electionCards.count == 0) {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
        [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:false];
    } else {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
        [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:true];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YOUR_ELECTIONS_RECEIVED
                                                        object:nil
                                                      userInfo:@{
                                                                 @"YourElections" : self.elections
                                                                 }];
    [self.tableView reloadData];
}

- (void)processOtherElections {
    if (self.otherElections.count > 0) {
        for (int i = 0; i < self.otherElections.count; i++) {
            OtherElection *oe = self.otherElections[i];
            for (Race *race in oe.election.races) {
                ElectionCardView *ecv = [[ElectionCardView alloc] initWithRace:race
                                                                       forDate:oe.election.electionDate
                                                                    forContact:true
                                                                  contactCount:(int)oe.contacts.count
                                                                preferredWidth:[[UIScreen mainScreen] bounds].size.width - 16];
                ecv.positionView.backgroundColor = [self colorForIndex:i];
                [self.otherElectionCards addObject:ecv];
                
                ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:ecv];
                [self.otherElectionCells addObject:cell];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_ELECTIONS_RECEIVED
                                                            object:nil
                                                          userInfo:@{
                                                                     @"OtherElections" : self.otherElections
                                                                     }];
    }
}

- (void)loadUserCardView {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                           parameters:@{@"fields" : @"first_name, last_name, picture.width(540).height(540), email, name, id, gender, birthday, permissions, location, friends"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Login error: %@", [error localizedDescription]);
                 return;
             }
             //NSLog(@"Gathered the following info from your logged in user: %@ email: %@ birthday: %@, profilePhotoURL: %@",
             //      result, result[@"email"], result[@"birthday"], result[@"picture"][@"data"][@"url"]);
             
             UserCardView *cardView = [[UserCardView alloc] initWithImageURL:result[@"picture"][@"data"][@"url"]
                                                                        name:result[@"name"]
                                                                   cityState:result[@"location"][@"name"]
                                                                  emailCount:0
                                                                    smsCount:0
                                                                  phoneCount:0];
             
             CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
             cardView.frame = frame;
             [self.cardView addSubview:cardView];
         }];
    }
}

- (void)presentElectionsNearYou {
    self.emptyTitleLabel.text = yourEmptyTitleString;
    self.emptyTextView.text = yourEmptyTextViewString;
    
    yourElectionsSelected = true;
    
    if (self.electionCells.count > 0) {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
        self.tableView.alpha = 0;
        [self.tableView reloadData];
        [UIView animateWithDuration:0.25f animations:^{
            self.tableView.alpha = 1;
        } completion:nil];
    } else {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
    }
}

- (void)presentElectionsNearYourContacts {
    self.emptyTitleLabel.text = contactsEmptyTitleString;
    self.emptyTextView.text = contactsEmptyTextViewString;
    
    yourElectionsSelected = false;
    
    if (self.otherElectionCells.count > 0) {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
        self.tableView.alpha = 0;
        [self.tableView reloadData];
        [UIView animateWithDuration:0.25f animations:^{
            self.tableView.alpha = 1;
        } completion:nil];
    } else {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
    }
}

- (void)registerTableViewCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"ElectionCardCell" bundle:nil]
         forCellReuseIdentifier:@"ElectionCardCell"];
}

- (void)segmentedControlValueChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: // Near You
            [self presentElectionsNearYou];
            break;
        case 1: // Near Your Contacts
            [self presentElectionsNearYourContacts];
            break;
        default:
            break;
    }
}

#pragma mark - Facebook SDK Delegate Methods

- (void)userFBLoginStatusChanged {
    if (![FBSDKAccessToken currentAccessToken]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        lvc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:lvc
                           animated:true
                         completion:^{
                             NSLog(@"Done!");
                             
                             // TODO: load saved credentials here
                         }];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
        [defaults setObject:@"" forKey:USER_STREET];
        [defaults setObject:@"" forKey:USER_CITY];
        [defaults setObject:@"" forKey:USER_STATE];
        [defaults setObject:@"" forKey:USER_ZIP_CODE];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
        [self loadUserCardView];
        [self getElections];
    }
}

-   (void)loginButton:(FBSDKLoginButton *)loginButtonv
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"LoginButtonDidLogOut called");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
    [defaults setObject:@"" forKey:USER_STREET];
    [defaults setObject:@"" forKey:USER_CITY];
    [defaults setObject:@"" forKey:USER_STATE];
    [defaults setObject:@"" forKey:USER_ZIP_CODE];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
}

#pragma mark - Segue Support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ElectionDetailViewControllerSegue"]) {
        NSDictionary *payload = (NSDictionary *)sender;
        int row = (int)[(NSIndexPath *)[payload objectForKey:@"IndexPath"] row];
        BOOL forContact = [[payload objectForKey:@"ForContact"] boolValue];
        ElectionDetailViewController *edvc = segue.destinationViewController;
        edvc.electionIndex = row;
        
        if (forContact) {
            edvc.forContacts = true;
            edvc.elections = [[NSArray alloc] init];
            edvc.otherElections = self.otherElections;
        } else {
            edvc.forContacts = false;
            edvc.elections = self.elections;
            edvc.otherElections = [[NSArray alloc] init];
        }
    }
}

#pragma mark - UITableView DataSource & Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 217;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 217;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL forContact = !yourElectionsSelected;
    NSDictionary *payload = @{
                              @"IndexPath"  : indexPath,
                              @"ForContact" : [NSNumber numberWithBool:forContact]
                              };
    [self performSegueWithIdentifier:@"ElectionDetailViewControllerSegue" sender:payload];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (yourElectionsSelected) {
        return self.electionCells[indexPath.row];
    } else {
        return self.otherElectionCells[indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (yourElectionsSelected) {
        return self.electionCells.count;
    } else {
        return self.otherElectionCells.count;
    }
}

#pragma mark - ElectionCardViewDelegate

- (void)electionCardViewStatusButtonTappedMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IMPORTANT"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert
                       animated:true
                     completion:nil];
    
    //[self displayToastWithMessage:@"Please enter valid email and password" backgroundColor:[UIColor globalFailureColor]];
}

@end
