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
#import "ElectionCardView.h"
#import "ElectionDetailViewController.h"
#import "OtherElection.h"
#import "GlobalAPI.h"
#import "LoginViewController.h"
#import "Race.h"
#import "SCLAlertView.h"
#import "SectionHeaderView.h"
#import "SVProgressHUD.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cardViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *electionCards;
@property (strong, nonatomic) NSMutableArray<UIColor *> *colors;

@property (strong, nonatomic) NSArray<Election *> *elections;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTopHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UILabel *emptyTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *emptyTextView;
@property (strong, nonatomic) IBOutlet UIImageView *permissionImageView;

@property (strong, nonatomic) NSMutableArray<ElectionCardCell *> *electionCells;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray <Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<OtherElection *> *otherElections;
@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *otherElectionCards;
@property (strong, nonatomic) NSMutableArray<ElectionCardCell *> *otherElectionCells;

@property (strong, nonatomic) UIView *grantPermissionView;


@property (nonatomic) BOOL otherElectionsLoaded;
@end

@implementation HomeViewController
BOOL yourElectionsSelected = true;
BOOL isFirstLoad = true;
BOOL permissionDenied = true;

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
        
    if (![FBSDKAccessToken currentAccessToken]
        && ![[[NSUserDefaults standardUserDefaults] objectForKey:IS_SESSION_ACTIVE] isEqualToString:@"YES"]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        lvc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:lvc
                           animated:true
                         completion:^{
                             NSLog(@"Done!");
                             
                             // TODO: load saved credentials here
                         }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.segmentedControl.selectedSegmentIndex = 0;
        [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstLoad = true;
    self.shouldShowNagView = true;
    self.otherElectionsLoaded = false;
    
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
                            action:@selector(refresh)
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadUserCardView];
    if (isFirstLoad) {
        isFirstLoad = false;
        [self getElections];
        //[self getContactList];
    }
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
                                             selector:@selector(refresh)
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

- (void)getContactListCompletion:(void (^)(void))completed {
    [self.segmentedControl setEnabled:false forSegmentAtIndex:1];
    [self.segmentedControl setTitle:@"LOADING..." forSegmentAtIndex:1];
    self.contacts = [[NSArray alloc] init];
    
    [GlobalAPI getAddressBookValidContactsForced:false
                                         success:^(NSArray<Contact *> *contacts) {
                                             permissionDenied = false;
                                             self.contacts = contacts;
                                             
                                             [self processContactsCompletion:^{
                                                 completed();
                                             }];
                                             
                                         } failure:^(NSString *message) {
                                             permissionDenied = true;
                                             [self.segmentedControl setEnabled:true forSegmentAtIndex:1];
                                             [self.segmentedControl setTitle:@"NEAR YOUR CONTACTS" forSegmentAtIndex:1];
                                             completed();
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
//                NSString *message = [NSString stringWithFormat:@"Oops! Something broke. Please try again, so sorry! (%ld.1)", (long)statusCode];
//                [self displayToastWithMessage:message backgroundColor:[UIColor globalFailureColor]];
            });
        }];
    } else {
        [GlobalAPI getRandomElectionsSuccess:^(NSArray<Election *> *elections) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            self.elections = [[NSArray alloc] initWithArray:elections];
            [self processElections];
            //[self getContactList];
        } failure:^(NSInteger statusCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
//                NSString *message = [NSString stringWithFormat:@"Oops! Something broke. Please try again, so sorry! (%ld.0)", (long)statusCode];
//                [self displayToastWithMessage:message backgroundColor:[UIColor globalFailureColor]];
            });
        }];
    }
}

- (void)processContactsCompletion:(void (^)(void))completion {
    self.otherElections = [[NSMutableArray alloc] init];
    self.otherElectionCards = [[NSMutableArray alloc] init];
    self.otherElectionCells = [[NSMutableArray alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    
    [SVProgressHUD show];
    
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
//            NSString *message = [NSString stringWithFormat:@"Oops! Something broke. Please try again, so sorry! (%ld.2)", (long)statusCode];
//            [self displayToastWithMessage:message backgroundColor:[UIColor globalFailureColor]];
        }];
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.otherElectionsLoaded = true;
        [self processOtherElections];
        completion();
    });
}

- (void)enableContactSegment {
    [self.segmentedControl setEnabled:true forSegmentAtIndex:1];
    [self.segmentedControl setTitle:@"NEAR YOUR CONTACTS" forSegmentAtIndex:1];
    [self.segmentedControl setNeedsDisplay];
}

- (void)processElections {
    //[self updateMapViewTab];
    [[NSNotificationCenter defaultCenter] postNotificationName:YOUR_ELECTIONS_RECEIVED
                                                        object:nil
                                                      userInfo:@{
                                                                 @"YourElections" : self.elections
                                                                 }];
    if (self.elections.count > 0) {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
    } else {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)processOtherElections {
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_ELECTIONS_RECEIVED
                                                        object:nil
                                                      userInfo:@{
                                                                 @"OtherElections" : self.otherElections
                                                                 }];
    [self performSelectorOnMainThread:@selector(enableContactSegment)
                           withObject:nil
                        waitUntilDone:false];
}

- (void)updateMapViewTab {
    if (self.elections.count == 0 && self.otherElections.count == 0) {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
        [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:false];
    } else {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
        [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:true];
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
             
             
             [self registerThisEmailForFacebook:result];
             
             
             UserCardView *cardView = [[UserCardView alloc] initWithImageURL:result[@"picture"][@"data"][@"url"]
                                                                        name:result[@"name"]
                                                                   cityState:result[@"location"][@"name"]
                                                                  emailCount:0
                                                                    smsCount:0
                                                                  phoneCount:0];
             
             CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
             cardView.frame = frame;
             
             
             [cardView.menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
             
             [self.cardView addSubview:cardView];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.cardViewHeightConstraint.constant = 80;
             });
         }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cardViewHeightConstraint.constant = 0;
            [self showMenuButton];
        });
    }
}

- (void)presentElectionsNearYou {
    self.emptyTitleLabel.text = yourEmptyTitleString;
    self.emptyTextView.text = yourEmptyTextViewString;
    
    yourElectionsSelected = true;
    if (self.elections.count > 0) {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
        self.permissionImageView.hidden = true;
        self.tableView.alpha = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [UIView animateWithDuration:0.25f animations:^{
            self.tableView.alpha = 1;
        } completion:^(BOOL finished) {
            //[self.tableView reloadData];
        }];
    } else {
        self.tableView.hidden = true;
        self.emptyView.hidden = false;
        self.permissionImageView.hidden = true;
    }
}

- (void)presentElectionsNearYourContacts {
    yourElectionsSelected = false;

    if (self.otherElectionsLoaded == false) {
        self.otherElections = [[NSMutableArray alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            self.segmentedControl.selectedSegmentIndex = 1;
            self.emptyTitleLabel.text = contactsEmptyTitleString;
            self.emptyTextView.text = contactsEmptyTextViewString;
            [self.tableView reloadData];
        });
        
        [self getContactListCompletion:^{
            
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if (status != CNAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                self.tableView.hidden = true;
                self.emptyView.hidden = true;
                self.permissionImageView.hidden = false;
            } else if (self.otherElections.count > 0) {
                self.tableView.hidden = false;
                self.emptyView.hidden = true;
                self.permissionImageView.hidden = true;
                self.tableView.alpha = 0;
                [UIView animateWithDuration:0.25f animations:^{
                    
                    [self.tableView reloadData];
                    self.tableView.alpha = 1;
                } completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }];
            } else {
                self.tableView.hidden = true;
                self.emptyView.hidden = false;
                self.permissionImageView.hidden = true;
            }
        }];
    } else {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status != CNAuthorizationStatusAuthorized) {
            self.tableView.hidden = true;
            self.emptyView.hidden = true;
            self.permissionImageView.hidden = false;
        } else if (self.otherElections.count > 0) {
            self.tableView.hidden = false;
            self.emptyView.hidden = true;
            self.permissionImageView.hidden = true;
            self.tableView.alpha = 0;
            [UIView animateWithDuration:0.25f animations:^{
                
                [self.tableView reloadData];
                self.tableView.alpha = 1;
            } completion:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }];
        } else {
            self.tableView.hidden = true;
            self.emptyView.hidden = false;
            self.permissionImageView.hidden = true;
        }
    }
    
}

- (void)registerTableViewCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"ElectionCardCell" bundle:nil]
         forCellReuseIdentifier:@"ElectionCardCell"];
}

- (void)refresh {
    self.otherElectionsLoaded = false;
    self.elections = [[NSMutableArray alloc] init];
    self.otherElections = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    yourElectionsSelected = true;
    [self getElections];
//    if (!permissionDenied) {
//        [self getContactListCompletion:^{
//            //
//        }];
//    }
}

- (void)segmentedControlValueChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: // Near You
            [self presentElectionsNearYou];
            break;
        case 1: // Near Your Contacts
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([[defaults objectForKey:CONTACTS_IMPORTED] isEqualToString:@"False"])
            {
                [self addGrantContactPermissionView];
            }
            else
                [self presentElectionsNearYourContacts];
        }
            break;

        default:
            break;
    }
}
#pragma mark - Tutorial View Methods
-(void)addGrantContactPermissionView
{
    self.grantPermissionView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *grantPermissionImageView;
    UIButton *grantPermissionButton;
    UIButton *skipGrantPermissionButton;
    
    
    grantPermissionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"john-hancock"]];
    grantPermissionImageView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    
    grantPermissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [grantPermissionButton addTarget:self action:@selector(grantPermissionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [grantPermissionButton setFrame:CGRectMake(grantPermissionImageView.frame.origin.x, self.view.frame.size.height-100, self.view.frame.size.width, 80)];
    [grantPermissionButton setBackgroundColor:[UIColor colorWithHexString:@"#29ABE2"]];
    [grantPermissionButton setTitle:@"Grant Contacts Permissions" forState:UIControlStateNormal];
    [grantPermissionButton.titleLabel setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightRegular]];
    
    
    skipGrantPermissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipGrantPermissionButton addTarget:self action:@selector(skipGrantPermissionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [skipGrantPermissionButton setFrame:CGRectMake(grantPermissionImageView.frame.size.width-180, grantPermissionImageView.frame.origin.y, 200, 100)];
    [skipGrantPermissionButton setBackgroundColor:[UIColor clearColor]];
    [skipGrantPermissionButton setTitle:@"Skip for Now" forState:UIControlStateNormal];
    [skipGrantPermissionButton.titleLabel setFont:[UIFont italicSystemFontOfSize:18.0f]];
    
    UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(grantPermissionImageView.frame.size.width/2-(grantPermissionImageView.frame.size.width/3), self.view.frame.size.height-300, grantPermissionImageView.frame.size.width/1.5, 100)];
    [shareLabel setText:@"Share elections with friends and family"];
    [shareLabel setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightSemibold]];
    [shareLabel setNumberOfLines:0];
    [shareLabel setBaselineAdjustment:YES];
    [shareLabel setAdjustsFontSizeToFitWidth:YES];
    [shareLabel setClipsToBounds:YES];
    [shareLabel setBackgroundColor:[UIColor clearColor]];
    [shareLabel setTextColor:[UIColor whiteColor]];
    [shareLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *shareLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(grantPermissionImageView.frame.size.width/2-(grantPermissionImageView.frame.size.width/2.4), self.view.frame.size.height-230, grantPermissionImageView.frame.size.width/1.2, 100)];
    [shareLabel2 setText:@"EveryElection helps you keep your social network socially responsible"];
    [shareLabel2 setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightLight]];
    [shareLabel2 setNumberOfLines:0];
    [shareLabel2 setBaselineAdjustment:YES];
    [shareLabel2 setAdjustsFontSizeToFitWidth:YES];
    [shareLabel2 setClipsToBounds:YES];
    [shareLabel2 setBackgroundColor:[UIColor clearColor]];
    [shareLabel2 setTextColor:[UIColor whiteColor]];
    [shareLabel2 setTextAlignment:NSTextAlignmentJustified];
    
    
    [self.tabBarController.tabBar setHidden:YES];
    
    [self.grantPermissionView addSubview:grantPermissionImageView];
    [self.grantPermissionView addSubview:grantPermissionButton];
    [self.grantPermissionView addSubview:skipGrantPermissionButton];
    [self.grantPermissionView addSubview:shareLabel];
    [self.grantPermissionView addSubview:shareLabel2];
    [self.view addSubview:self.grantPermissionView];
    
}

-(void)removeGrantContactPermissionView
{
    [self.grantPermissionView removeFromSuperview];
    
}

-(void)grantPermissionButtonClicked:(id)sender
{
    [self.tabBarController.tabBar setHidden:NO];
    [self removeGrantContactPermissionView];
    [self presentElectionsNearYourContacts];
}

-(void)skipGrantPermissionButtonClicked:(id)sender
{
    [self.grantPermissionView removeFromSuperview];
    [self.tabBarController.tabBar setHidden:NO];
    self.segmentedControl.selectedSegmentIndex=0;
    [self presentElectionsNearYou];
}


#pragma mark - IBActions

- (IBAction)emailLogoutButtonTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
    [defaults setObject:@"" forKey:USER_STREET];
    [defaults setObject:@"" forKey:USER_CITY];
    [defaults setObject:@"" forKey:USER_STATE];
    [defaults setObject:@"" forKey:USER_ZIP_CODE];
    [defaults setObject:@"NO" forKey:IS_SESSION_ACTIVE];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
    if ([FBSDKAccessToken currentAccessToken]) {
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    }
    LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    lvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:lvc
                       animated:true
                     completion:^{
                         NSLog(@"Done!");
                         
                         // TODO: load saved credentials here
                     }];
}

- (IBAction)refreshButtonTapped:(id)sender {
    [self refresh];
}

#pragma mark - Facebook SDK Delegate Methods

- (void)userFBLoginStatusChanged {
    if (![FBSDKAccessToken currentAccessToken]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
        [defaults setObject:@"" forKey:USER_STREET];
        [defaults setObject:@"" forKey:USER_CITY];
        [defaults setObject:@"" forKey:USER_STATE];
        [defaults setObject:@"" forKey:USER_ZIP_CODE];
        [defaults setObject:@"" forKey:AUTH_TOKEN];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
        
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
    [defaults setObject:@"" forKey:AUTH_TOKEN];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
}

#pragma mark - Segue Support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ElectionDetailViewControllerSegue"]) {
        NSDictionary *payload = (NSDictionary *)sender;
        NSIndexPath *indexPath = (NSIndexPath *)[payload objectForKey:@"IndexPath"];
        BOOL forContact = [[payload objectForKey:@"ForContact"] boolValue];
        ElectionDetailViewController *edvc = segue.destinationViewController;
        edvc.electionIndex = indexPath;
        
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (yourElectionsSelected) {
        return self.elections.count;
    } else {
        return self.otherElections.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 217-50-20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 217-50-20;
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
        Election *election = self.elections[indexPath.section];
        Race *race = election.races[indexPath.row];
        ElectionCardView *ecv = [[ElectionCardView alloc] initWithRace:race
                                                               forDate:nil
                                                            forContact:false contactCount:0
                                                        preferredWidth:[[UIScreen mainScreen] bounds].size.width - 16];
        ecv.delegate = self;
        ecv.positionView.backgroundColor = [self colorForIndex:indexPath.row];
        
        ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:ecv];
        return cell;
    } else {
        OtherElection *oe = self.otherElections[indexPath.section];
        Race *race = oe.election.races[indexPath.row];
        ElectionCardView *ecv = [[ElectionCardView alloc] initWithRace:race
                                                               forDate:nil
                                                            forContact:true
                                                          contactCount:(int)oe.contacts.count
                                                        preferredWidth:[[UIScreen mainScreen] bounds].size.width - 16];
        ecv.positionView.backgroundColor = [self colorForIndex:indexPath.row];
        
        ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:ecv];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60+5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (yourElectionsSelected) {
        return self.elections[section].races.count;
    } else {
        return self.otherElections[section].election.races.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (yourElectionsSelected) {
        SectionHeaderView *shv = [[SectionHeaderView alloc] initWithTitle:[self.elections[section] displayName]andElectionDate:[self.elections[section] electionDate]];
        return shv;
    } else {
        SectionHeaderView *shv = [[SectionHeaderView alloc] initWithTitle:[self.otherElections[section].election displayName]andElectionDate:[self.otherElections[section].election electionDate]];
        return shv;
    }
    
    
    
}

#pragma mark - ElectionCardViewDelegate

- (void)electionCardViewStatusButtonTappedMessage:(NSDictionary *)messageDict {
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
                     completion:nil];
    
    //[self displayToastWithMessage:@"Please enter valid email and password" backgroundColor:[UIColor globalFailureColor]];
}
-(void)showMenuButton
{
    self.cardViewHeightConstraint.constant = 50;

    UIButton *menuButton;
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setFrame:CGRectMake(0, 0, 30, 50)];
    [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [self.cardView addSubview:menuButton];
//    self.nagView.menuButton.hidden=NO;
//    [self.nagView.menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
//    
}

-(void)registerThisEmailForFacebook:(id) result
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"RegisterEmailFB"];
    BOOL didAsk =[[defaults objectForKey:@"DidAskRegisterEmailFB"] boolValue];
    if (didAsk==NO)
        if (email==nil)
        {
            [defaults setObject:result[USER_FIRST_NAME] forKey:USER_FIRST_NAME];
            [defaults setObject:result[USER_LAST_NAME] forKey:USER_LAST_NAME];
            [defaults setObject:result[@"location"][@"name"] forKey:@"user_city"];
            
            
            [GlobalAPI registerWithFacebookEmail:result[@"email"]
                                          userID:result[@"email"]
                                         success:^{
                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                             [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"DidAskRegisterEmailFB"];
                                             [defaults setObject:result[@"email"] forKey:@"RegisterEmailFB"];
                                         } failure:^(NSString *message) {
                                             
                                             [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"DidAskRegisterEmailFB"];
                                             [defaults setObject:result[@"email"] forKey:@"RegisterEmailFB"];
                                         }];
            
        }
    
}
@end
