//
//  FirstViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "HomeViewController.h"
#import "Constant.h"
#import "ElectionCardCell.h"
#import "ElectionCardView.h"
#import "LoginViewController.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<ElectionCardView *> *electionCards;
@property (strong, nonatomic) NSMutableArray<UIColor *> *colors;

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
    
    [self loadFakeData];
}

#pragma mark - Private Methods

- (UIColor *)colorForIndex:(NSInteger)row {
    NSInteger colorIndex = (row + 1) % self.colors.count;
    return self.colors[colorIndex];
}

- (void)loadFakeData {
    self.electionCards = [[NSMutableArray alloc] init];
    CGRect evFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 36, 220);
    
    ElectionCardView *ev1 = [[ElectionCardView alloc] initWithFrame:evFrame];
    ev1.cityImageView.image = [UIImage imageNamed:@"sample-alabama"];
    ev1.positionLabel.text = @"Mayor";
    ev1.cityStateLabel.text = @"Birmingham, Alabama";
    ev1.badgeCountLabel.text = @"3";
    
    ElectionCardView *ev2 = [[ElectionCardView alloc] initWithFrame:evFrame];
    ev2.cityImageView.image = [UIImage imageNamed:@"sample-chicago"];
    ev2.positionLabel.text = @"City Council";
    ev2.cityStateLabel.text = @"Chicago, Illinois";
    ev2.badgeCountLabel.text = @"2";
    
    ElectionCardView *ev3 = [[ElectionCardView alloc] initWithFrame:evFrame];
    ev3.cityImageView.image = [UIImage imageNamed:@"sample-nyc"];
    ev3.positionLabel.text = @"Alderman";
    ev3.cityStateLabel.text = @"New York, New York";
    ev3.badgeCountLabel.text = @"5";
    
    [self.electionCards addObject:ev1];
    [self.electionCards addObject:ev2];
    [self.electionCards addObject:ev3];
    
    for (int i = 0; i < self.electionCards.count; i++) {
        self.electionCards[i].positionView.backgroundColor = [self colorForIndex:i];
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
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.alpha = 1;
    }];
}

- (void)presentElectionsNearYourContacts {
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.alpha = 0;
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
        [self loadUserCardView];
        [self loadFakeData];
    }
}

-   (void)loginButton:(FBSDKLoginButton *)loginButtonv
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"LoginButtonDidLogOut called");
}

#pragma mark - UITableView DataSource & Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ElectionCardCell";
    
    ElectionCardCell *cell = [[ElectionCardCell alloc] initWithElectionCardView:self.electionCards[indexPath.row]];
        
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.electionCards.count;
}

@end
