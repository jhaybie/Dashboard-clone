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

@end

@implementation ContactsViewController

#pragma mark - Override Methods

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
    [self displayContactListForcedReload:false];
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
    
    [GlobalAPI saveContacts:self.contacts];
}

#pragma mark - Private Methods

- (void)displayContactListForcedReload:(BOOL)forcedReload {
    [SVProgressHUD show];
    [GlobalAPI getAddressBookValidContactsForced:forcedReload
                                         success:^(NSArray<Contact *> *contacts) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];
                                             });
                                             self.contacts = contacts;
                                             
                                             [self.tableView reloadData];
                                         } failure:^(NSString *message) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];
                                             });
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

- (void)registerTableViewCells {
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil]
         forCellReuseIdentifier:@"ContactCell"];
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
        
        [self presentViewController:messageController
                           animated:true
                         completion:nil];
    }
}

#pragma mark - TableViewHeaderView Delegate Method

- (void)tableHeaderViewRefreshButtonTapped {
    [self.refreshControl endRefreshing];
    self.contacts = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self displayContactListForcedReload:true];
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

@end
