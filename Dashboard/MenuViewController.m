//
//  DEMOMenuViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (nonatomic, strong) DBToastView *toastView;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            [self.sideMenuViewController setContentViewController:[[reSideMenuSingleton sharedManager] vc] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
        case 1:
        {
            [self showSettingsView];
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
        case 2:
        {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.tintTopCircle = NO;
            alert.iconTintColor = [UIColor colorWithHexString:@"#1F80AA"];
            alert.useLargerIcon = NO;
            alert.cornerRadius = 13.0f;
            
            SCLTextView *textField = [alert addTextField:@"Old Password"];
            SCLTextView *newPasswordTextField = [alert addTextField:@"New Password"];
            SCLTextView *newPasswordConfirmTextField = [alert addTextField:@"Confirm Password"];
            
            
            [alert addButton:@"Change" actionBlock:^(void) {
                [self changePasswordOf:textField.text withNewPassword:newPasswordTextField.text confirmWithPassword:newPasswordConfirmTextField.text];
            }];
            
            [alert addButton:@"Close" actionBlock:^(void) {
                [self.sideMenuViewController hideMenuViewController];
            }];
            [alert showCustom:self image:[UIImage imageNamed:@"icon-password"] color:[UIColor colorWithHexString:@"#1F80AA"] title:nil subTitle:@"To change your password, enter your old password followed by your new password" closeButtonTitle:nil duration:0.0f];
            
            
            
            
        }
            break;
        case 3:
        {
            [self.sideMenuViewController setContentViewController:[[reSideMenuSingleton sharedManager] vc] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            [self logout];
            
            
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Home",@"Settings",@"Password", @"Log Out"];
    NSArray *images = @[@"xicon-home",@"xicon-settings",@"xicon-changepassword", @"xleft-arrow"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

-(void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
    [defaults setObject:@"" forKey:USER_STREET];
    [defaults setObject:@"" forKey:USER_CITY];
    [defaults setObject:@"" forKey:USER_STATE];
    [defaults setObject:@"" forKey:USER_ZIP_CODE];
    [defaults setObject:@"NO" forKey:IS_SESSION_ACTIVE];
    [defaults removeObjectForKey:@"RegisterEmailFB"];
    [defaults removeObjectForKey:@"HasRegisterEmailFB"];
    
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

-(void)showSettingsView
{
    SettingsViewController *avc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *imageURL = [NSURL URLWithString:[defaults objectForKey:USER_IMAGE_URL]];
    NSString *fullName = [defaults objectForKey:USER_FULL_NAME];
    NSString *location = [defaults objectForKey:USER_LOCATION];
    
    UserCardView *cardView = [[UserCardView alloc] initWithImageURL:imageURL
                                                               name:fullName
                                                          cityState:location
                                                         emailCount:0
                                                           smsCount:0
                                                         phoneCount:0];
    avc.cardView = cardView;
    //    avc.delegate = self;
    cardView.menuButton.hidden=YES;
    
    [self presentViewController:avc
                       animated:true
                     completion:nil];
}
-(void)changePasswordOf:(NSString*)oldPassword withNewPassword:(NSString*)newPassword confirmWithPassword:(NSString*)confirmPassword
{
    if (oldPassword.length==0 || newPassword.length==0 || confirmPassword==0)
    {
        [self displayToastWithMessage:@"Please enter your password" backgroundColor:[UIColor globalFailureColor]];
    }
    else if (![newPassword isEqualToString:confirmPassword])
    {
        [self displayToastWithMessage:@"New password does not match with the confirmation password" backgroundColor:[UIColor globalFailureColor]];
    }
    else if (newPassword.length<8)
    {
        [self displayToastWithMessage:@"Passwords should be at least 8 characters" backgroundColor:[UIColor globalFailureColor]];
    }
    else
    {
        [self displayToastWithMessage:@"Change Password Sucessful" backgroundColor:[UIColor globalSuccessColor]];
    }
}

@end
