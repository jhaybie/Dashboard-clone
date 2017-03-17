//
//  FirstViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "HomeViewController.h"
#import "Constant.h"
#import "Election.h"
#import "ElectionCardCell.h"
#import "ElectionCardView.h"
#import "ElectionDetailViewController.h"
#import "GlobalAPI.h"
#import "LoginViewController.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *electionCards;
@property (strong, nonatomic) NSMutableArray<UIColor *> *colors;

@property (strong, nonatomic) NSArray<Election *> *elections;

@end

@implementation HomeViewController

#pragma mark - Override Methods

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
    
    self.colors = [[NSMutableArray alloc] init];
    [self.colors addObject:[UIColor dbBlue1]];
    [self.colors addObject:[UIColor dbBlue2]];
    [self.colors addObject:[UIColor dbBlue3]];
    [self.colors addObject:[UIColor dbBlue4]];
    [self.colors addObject:[UIColor dbBlue3]];
    [self.colors addObject:[UIColor dbBlue2]];
    
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlValueChanged)
                    forControlEvents:UIControlEventValueChanged];
    
    [self loadUserCardView];
    
    [self getElections];
}

#pragma mark - Private Methods

- (UIColor *)colorForIndex:(NSInteger)row {
    NSInteger colorIndex = (row + 1) % self.colors.count;
    return self.colors[colorIndex];
}

- (void)getElections {
    [GlobalAPI getElections:^(NSArray<Election *> *elections) {
        self.elections = [[NSArray alloc] initWithArray:elections];
        [self processElections];
    } failure:^(NSInteger statusCode) {
        //
    }];
}

- (void)processElections {
    self.electionCards = [[NSMutableArray alloc] init];
    CGRect evFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 36, 220);
    
    for (NSInteger i = 0; i < self.elections.count; i++) {
        Election *election = self.elections[i];
        ElectionCardView *ecv = [[ElectionCardView alloc] initWithElection:election];
        ecv.frame = evFrame;
        ecv.positionView.backgroundColor = [self colorForIndex:i];
        [self.electionCards addObject:ecv];
    }
    [self.tableView reloadData];
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
             NSLog(@"Gathered the following info from your logged in user: %@ email: %@ birthday: %@, profilePhotoURL: %@",
                   result, result[@"email"], result[@"birthday"], result[@"picture"][@"data"][@"url"]);
             
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
    [UIView animateWithDuration:0.15f animations:^{
        self.tableView.alpha = 1;
    } completion:^(BOOL finished) {
        // TODO: reload tableview with elections near you
        [UIView animateWithDuration:0.15f animations:^{
            self.tableView.alpha = 0;
        } completion:^(BOOL finished) {
            self.tableView.alpha = 1;
        }];
    }];
}

- (void)presentElectionsNearYourContacts {
    [UIView animateWithDuration:0.15f animations:^{
        self.tableView.alpha = 1;
    } completion:^(BOOL finished) {
        // TODO: reload tableview with elections near your contacts
        [UIView animateWithDuration:0.15f animations:^{
            self.tableView.alpha = 0;
        } completion:^(BOOL finished) {
            self.tableView.alpha = 1;
        }];
    }];
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
        ElectionDetailViewController *edvc = segue.destinationViewController;
        edvc.electionIndex = (int)((NSIndexPath *)sender).row;
        edvc.elections = self.elections;
    }
}

#pragma mark - UITableView DataSource & Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ElectionDetailViewControllerSegue" sender:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:self.electionCards[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.electionCards.count;
}

@end
