//
//  LoginViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "LoginViewController.h"
#import "Constant.h"
#import "DBCheckboxButton.h"
#import "Election.h"
#import "GlobalAPI.h"
#import "SVProgressHUD.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *loginViewTopSpacingHeightConstraint;

@property (strong, nonatomic) IBOutlet iCarousel *carouselView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet DBCheckboxButton *rememberMeButton;
@property (strong, nonatomic) IBOutlet UILabel *rememberMeLabel;

@property (strong, nonatomic) NSMutableArray<UIImage *> *carouselImages;

//@property (strong, nonatomic) RegisterView *registerView;

@end

@implementation LoginViewController
NSTimer *carouselTimer;

#pragma mark - Override Methods

- (void)dealloc {
    self.carouselView.delegate = nil;
    self.carouselView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adjust spacing for devices
    int offset = 30;
    if (IS_IPHONE_4_7_INCH) {
        offset = 70;
    } else if (IS_IPHONE_5_5_INCH) {
        offset = 90;
    }
    self.loginViewTopSpacingHeightConstraint.constant = offset;
    
    [self configureCarousel];
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlValueChanged)
                    forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFBLoginStatusChanged)
                                                 name:FBSDKProfileDidChangeNotification
                                               object:nil];
    self.facebookLoginButton.delegate = self;
    self.facebookLoginButton.readPermissions = @[@"email", @"public_profile", @"user_birthday", @"user_friends", @"user_location"];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:true];
    
    [self.rememberMeButton setIsChecked:false];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    carouselTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                     target:self
                                                   selector:@selector(advanceCarousel)
                                                   userInfo:nil
                                                    repeats:true];
    self.confirmPasswordTextField.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [carouselTimer invalidate];
    carouselTimer = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateScrollViewContentSize];
}

#pragma mark - Private Methods

- (void)advanceCarousel {
    long index = (self.carouselView.currentItemIndex == self.carouselImages.count) ? 0 : self.carouselView.currentItemIndex + 1;
    [self.carouselView scrollToItemAtIndex:index animated:true];
}

- (void)configureCarousel {
    // TODO: replace with server-returned images
    UIImage *image0 = [UIImage imageNamed:@"sample-logo-0"];
    UIImage *image1 = [UIImage imageNamed:@"sample-logo-1"];
    UIImage *image2 = [UIImage imageNamed:@"sample-logo-2"];
    UIImage *image3 = [UIImage imageNamed:@"sample-logo-3"];
    UIImage *image4 = [UIImage imageNamed:@"sample-logo-4"];
    UIImage *image5 = [UIImage imageNamed:@"sample-logo-5"];
    UIImage *image6 = [UIImage imageNamed:@"sample-logo-6"];
    UIImage *image7 = [UIImage imageNamed:@"sample-logo-7"];
    UIImage *image8 = [UIImage imageNamed:@"sample-logo-8"];
    UIImage *image9 = [UIImage imageNamed:@"sample-logo-9"];
    
    self.carouselImages = [[NSMutableArray alloc] init];
    [self.carouselImages addObject:image0];
    [self.carouselImages addObject:image1];
    [self.carouselImages addObject:image2];
    [self.carouselImages addObject:image3];
    [self.carouselImages addObject:image4];
    [self.carouselImages addObject:image5];
    [self.carouselImages addObject:image6];
    [self.carouselImages addObject:image7];
    [self.carouselImages addObject:image8];
    [self.carouselImages addObject:image9];
    
    self.carouselView.type = iCarouselTypeLinear;
    
    self.carouselView.userInteractionEnabled = false;
    
    [self.carouselView reloadData];
}

- (void)presentLoginView {
    self.loginViewTopSpacingHeightConstraint.constant += 30;
    [self.view endEditing:true];
    self.confirmPasswordTextField.hidden = true;
    self.rememberMeButton.hidden = false;
    self.rememberMeLabel.hidden = false;
    self.loginButton.hidden = false;
    self.registerButton.hidden = true;
    self.confirmPasswordTextField.text = @"";
}

- (void)presentRegisterView {
    self.loginViewTopSpacingHeightConstraint.constant -= 30;
    [self.view endEditing:true];
    self.confirmPasswordTextField.hidden = false;
    self.rememberMeButton.hidden = true;
    self.rememberMeLabel.hidden = true;
    self.loginButton.hidden = true;
    self.registerButton.hidden = false;
    self.confirmPasswordTextField.text = @"";
}

- (void)segmentedControlValueChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: // Login
            [self presentLoginView];
            break;
        case 1: // Register
            [self presentRegisterView];
            break;
        default:
            break;
    }
}

- (void)updateScrollViewContentSize {
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.scrollView.contentSize = contentRect.size;
}

- (void)userFBLoginStatusChanged {
    if ([FBSDKAccessToken currentAccessToken]){
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                           parameters:@{@"fields" : @"first_name, last_name, picture.width(540).height(540), email, name, id, gender, birthday, permissions, location, friends"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Login error: %@", [error localizedDescription]);
                 return;
             }
             NSLog(@"Gathered the following info from your logged in user: %@ email: %@ birthday: %@, profilePhotoURL: %@",
                   result, result[@"email"], result[@"birthday"], result[@"picture"][@"data"][@"url"]);
             
             
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:result[@"picture"][@"data"][@"url"] forKey:USER_IMAGE_URL];
             [defaults setObject:result[@"name"] forKey:USER_FULL_NAME];
             [defaults setObject:result[@"location"][@"name"] forKey:USER_LOCATION];
             
//             [GlobalAPI registerWithFacebookEmail:result[@"email"]
//                                           userID:result[@"id"]
//                                          success:^{
                                              AddressViewController *avc = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
                                              avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                              UserCardView *cardView = [[UserCardView alloc] initWithImageURL:result[@"picture"][@"data"][@"url"]
                                                                                                         name:result[@"name"]
                                                                                                    cityState:result[@"location"][@"name"]
                                                                                                   emailCount:0
                                                                                                     smsCount:0
                                                                                                   phoneCount:0];
                                              avc.cardView = cardView;
                                              avc.delegate = self;
             
                                              [self presentViewController:avc
                                                                 animated:true
                                                               completion:nil];
//                                          } failure:^(NSString *message) {
//                                              //
//                                          }];
         }];
    }
}

#pragma mark - iCarousel Delegate Methods

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    if(option == iCarouselOptionWrap){
        return YES;
    }
    return value;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if (view == nil) {
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width / 2 * 1.10, 200);
        view = [[UIImageView alloc] initWithFrame:frame];
        ((UIImageView *)view).image = self.carouselImages[index];
        view.contentMode = UIViewContentModeCenter;
    } else {
        ((UIImageView *)view).image = self.carouselImages[index];
    }
    return view;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.carouselImages.count;
}

#pragma mark - IBActions

- (IBAction)loginButtonTapped:(id)sender {
    if (self.emailTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        [self displayToastWithMessage:@"Please enter valid email and password" backgroundColor:[UIColor globalFailureColor]];
    } else {
        [SVProgressHUD show];
        [GlobalAPI loginWithEmail:self.emailTextField.text
                         password:self.passwordTextField.text
                          success:^{
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [SVProgressHUD dismiss];
                              });
                              //[self dismissViewControllerAnimated:true completion:nil];
                              AddressViewController *avc = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
                              avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                              avc.cardView = nil;
                              avc.delegate = self;
                              
                              [self presentViewController:avc
                                                 animated:true
                                               completion:nil];
                          } failure:^(NSString *message) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [SVProgressHUD dismiss];
                              });
                              [self displayToastWithMessage:message backgroundColor:[UIColor globalFailureColor]];
                          }];
    }
}

- (IBAction)registerButtonTapped:(id)sender {
    if (self.emailTextField.text.length == 0) {
        [self displayToastWithMessage:@"Please enter your email" backgroundColor:[UIColor globalFailureColor]];
    } else if (self.passwordTextField.text.length == 0) {
        [self displayToastWithMessage:@"Please enter a password" backgroundColor:[UIColor globalFailureColor]];
    } else if (self.passwordTextField.text.length > 0 && ![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        [self displayToastWithMessage:@"Passwords do not match" backgroundColor:[UIColor globalFailureColor]];
    } else {
        [SVProgressHUD show];
        [GlobalAPI registerWithEmail:self.emailTextField.text
                            password:self.passwordTextField.text
                             success:^{
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SVProgressHUD dismiss];
                                 });
                                 //[self dismissViewControllerAnimated:true completion:nil];
                                 AddressViewController *avc = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
                                 avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                 avc.cardView = nil;
                                 avc.delegate = self;
                                 
                                 [self presentViewController:avc
                                                    animated:true
                                                  completion:nil];
                             } failure:^(NSString *message) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SVProgressHUD dismiss];
                                 });
                                 [self displayToastWithMessage:message backgroundColor:[UIColor globalFailureColor]];
                             }];
    }
}

- (IBAction)tAndCButtonTapped:(id)sender {
    NSURL *donateURL = [NSURL URLWithString:@"http://www.riseparty.org/terms_and_conditions"];
    
    [[UIApplication sharedApplication] openURL:donateURL
                                       options:@{}
                             completionHandler:nil];
}

#pragma mark - Facebook SDK Delegate Methods

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

-   (void)loginButton:(FBSDKLoginButton *)loginButtonv
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    
}

#pragma mark - AddressViewController Delegate Method

- (void)didDismissViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[AddressViewController class]]) {
        [self dismissViewControllerAnimated:false completion:nil];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

@end
