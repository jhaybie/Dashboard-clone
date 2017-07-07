//
//  ContactsViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ContactsViewController.h"
#import "Constant.h"
#import "Contact.h"
#import "ContactCell.h"
#import "GlobalAPI.h"
#import "SVProgressHUD.h"
#import "UIColor+DBColors.h"

@interface ContactsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray<Contact *> *contacts;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UIImageView *deniedImageView;

@property (strong, nonatomic) UIButton *grantPermissionButton;
@property (strong, nonatomic) UIButton *skipGrantPermissionButton;
@property (strong, nonatomic) UIImageView *grantPermissionImageView;

@end

@implementation ContactsViewController

#pragma mark - Override Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [GlobalAPI saveContacts:self.contacts];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    CGRect frame = self.tableView.frame;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor globalDarkColor];
    [self.tableView addSubview:grayView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    
    // Enable pull-to-refresh functionality
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(tableHeaderViewRefreshButtonTapped)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
 
    [self registerTableViewCells];
    //[self displayContactListForcedReload:false];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:CONTACTS_IMPORTED] isEqualToString:@"False"])
    {
        [self addGrantContactPermissionView];
    }
    else
    {
        [self displayContactListForcedReload:true];
    }

}

- (void)appWillResignActive:(NSNotification*)note {
    [GlobalAPI saveContacts:self.contacts];
}

- (void)appWillTerminate:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:CONTACTS_IMPORTED] isEqualToString:@"False"])
    {
        [GlobalAPI saveContacts:self.contacts];
    }
}
#pragma mark - Private Methods

- (void)displayContactListForcedReload:(BOOL)forcedReload {
    [SVProgressHUD show];
    [GlobalAPI getAddressBookValidContactsForced:forcedReload
                                         success:^(NSArray<Contact *> *contacts) {
                                             self.tableView.hidden = false;
                                             self.deniedImageView.hidden = true;
                                             self.contacts = contacts;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];
                                                 [self.tableView reloadData];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
                                             });
                                             
                                         } failure:^(NSString *message) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];
                                             });
                                             self.tableView.hidden = true;
                                             self.deniedImageView.hidden = false;
                                         }];
}

- (void)registerTableViewCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil]
         forCellReuseIdentifier:@"ContactCell"];
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

#pragma mark - CellContact Delegte Methods

- (void)checkBoxButtonTapped:(id)sender {
    DBCheckboxButton *button = sender;
    Contact *contact = self.contacts[button.tag];
    contact.isSelected = button.isChecked;
}

- (void)inviteButtonTapped:(id)sender {
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        DBCheckboxButton *button = sender;
        Contact *contact = self.contacts[button.tag];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        
        ContactCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.inviteButton.userInteractionEnabled = false;
        [cell.inviteButton setTitle:@"Invited" forState:UIControlStateNormal];
        cell.inviteButton.backgroundColor = [UIColor color4D4D4D];
        contact.isInvited = true;
        
        NSString *smsString = contact.mobile;
        
        NSArray *recipients = @[smsString];
        
        NSString *nameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FULL_NAME];
        NSString *message = [NSString stringWithFormat:@"%@ has invited you to join EveryElection and keep track of upcoming elections! newfounders.us", nameString];
        
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipients];
        [messageController setBody:message];
        
        messageController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        [self presentViewController:messageController
                           animated:true
                         completion:nil];
    }
}

#pragma mark - TableViewHeaderView Delegate Method

- (void)tableHeaderViewRefreshButtonTapped {
    [self.refreshControl endRefreshing];
    self.contacts = [[NSMutableArray alloc] init];
    [self displayContactListForcedReload:true];
    //[self.tableView reloadData];
}

#pragma mark - UITableView DataSource & Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.contacts[indexPath.row];
    BOOL selected = contact.isSelected;
    BOOL invited = contact.isInvited;
    ContactCell *cell = [[ContactCell alloc] initWithContact:self.contacts[indexPath.row]
                                                    selected:selected
                                                     invited:invited
                                                       index:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableViewHeaderView *headerView = [[TableViewHeaderView alloc] init];
    headerView.delegate = self;
    return headerView;
}
#pragma mark - Tutorial View Methods
-(void)addGrantContactPermissionView
{
    self.grantPermissionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_contact_permission"]];
    
    self.grantPermissionImageView.frame = CGRectMake(
                                                     self.grantPermissionImageView.frame.origin.x+5-5,
                                                     self.grantPermissionImageView.frame.origin.y+100, self.view.frame.size.width-10+10, self.view.frame.size.height-150);
    
    self.grantPermissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.grantPermissionButton addTarget:self action:@selector(grantPermissionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.grantPermissionButton setFrame:CGRectMake(self.grantPermissionImageView.frame.origin.x, self.view.frame.size.height-120, self.view.frame.size.width-10, 50)];
    [self.grantPermissionButton setBackgroundColor:[UIColor clearColor]];
    
    self.skipGrantPermissionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipGrantPermissionButton addTarget:self action:@selector(skipGrantPermissionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.skipGrantPermissionButton setFrame:CGRectMake(self.grantPermissionImageView.frame.size.width-180, self.grantPermissionImageView.frame.origin.y, 200, 40)];
    [self.skipGrantPermissionButton setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.grantPermissionImageView];
    [self.view addSubview:self.grantPermissionButton];
    [self.view addSubview:self.skipGrantPermissionButton];
    
}

-(void)removeGrantContactPermissionView
{
    [self.grantPermissionImageView removeFromSuperview];
    [self.grantPermissionButton removeFromSuperview];
    [self.skipGrantPermissionButton removeFromSuperview];
    
}

-(void)grantPermissionButtonClicked:(id)sender
{
    [self removeGrantContactPermissionView];
    [self displayContactListForcedReload:true];
}

-(void)skipGrantPermissionButtonClicked:(id)sender
{
    [self.grantPermissionImageView removeFromSuperview];
    [self.grantPermissionButton removeFromSuperview];
    [self.skipGrantPermissionButton removeFromSuperview];
}

@end
