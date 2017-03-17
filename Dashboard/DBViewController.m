//
//  DBViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBViewController.h"
#import "Constant.h"
#import "UIColor+DBColors.h"
#import "UserCardView.h"

@interface DBViewController ()

@property (nonatomic, strong) DBToastView *toastView;

@end

@implementation DBViewController

#pragma mark - Override Methods
BOOL isAddressEntered;
BOOL isToastVisible = false;
NSTimer *timer;

#pragma mark - Override Methods

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldShowNagView) {
        [self displayNagScreen];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup default behavior for nag view
    self.shouldShowNagView = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissNagView)
                                                 name:ADDRESS_UPDATED
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.nagView removeFromSuperview];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADDRESS_UPDATED
                                                  object:nil];
}

#pragma mark - Private Methods

- (void)dismissNagView {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]) {
        CGRect endFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, 100);
        [UIView animateWithDuration:0.5f animations:^{
            self.nagView.frame = endFrame;
        } completion:^(BOOL finished) {
            [self.nagView removeFromSuperview];
        }];
    }
}

- (void)displayNagScreen {
    CGRect startFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, 100);
    CGRect endFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - (self.tabBarController.tabBar.frame.size.height + 100), [[UIScreen mainScreen] bounds].size.width, 100);
    
    self.nagView = [[DBNagView alloc] initWithMessage:@"Address unknown. Displaying random elections"
                                      backgroundColor:[UIColor globalFailureColor]];
    self.nagView.frame = startFrame;
    self.nagView.delegate = self;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"False"]
        || ![[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS]) {
        
        [self.view addSubview:self.nagView];
        [self.view bringSubviewToFront:self.nagView];
        [UIView animateWithDuration:0.5f animations:^{
            self.nagView.frame = endFrame;
        }];
    }
}

- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    CGRect startFrame = CGRectMake(0, -80, [[UIScreen mainScreen] bounds].size.width, 80);
    CGRect endFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
    
    [timer invalidate];
    timer = nil;
    
    if (!isToastVisible) {
        isToastVisible = true;

        self.toastView = [[DBToastView alloc] initWithMessage:message backgroundColor:backgroundColor];
        self.toastView.frame = startFrame;
        self.toastView.delegate = self;
        [self.view addSubview:self.toastView];

        [UIView animateWithDuration:0.5f animations:^{
            self.toastView.frame = endFrame;
        } completion:^(BOOL finished) {
            timer = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                     target:self
                                                   selector:@selector(toastCloseButtonTapped)
                                                   userInfo:nil
                                                    repeats:true];
        }];
    } else { // current toast notification exists
        
        CGRect endFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 60);
        [UIView animateWithDuration:0.15f animations:^{
            self.toastView.frame = endFrame;
        } completion:^(BOOL finished) {
            isToastVisible = false;
            [self.toastView removeFromSuperview];
            
            [self displayToastWithMessage:message backgroundColor:backgroundColor];
        }];
    }
}

#pragma mark - AddressViewController Delegate Method

- (void)didDismissViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[AddressViewController class]]) {
        [self dismissViewControllerAnimated:false completion:nil];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

#pragma mark - DBNagView Delegate Methods

- (void)enterAddressButtonTapped:(id)sender {
    [self.view endEditing:true];
    AddressViewController *avc = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
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
    avc.delegate = self;
    
    [self presentViewController:avc
                       animated:true
                     completion:nil];
}

#pragma mark - DBToastView Delegate Methods

- (void)toastCloseButtonTapped {
    CGRect endFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 60);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.toastView.frame = endFrame;
    } completion:^(BOOL finished) {
        isToastVisible = false;
        [self.toastView removeFromSuperview];
    }];
}

@end
