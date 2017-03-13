//
//  DBViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBViewController.h"

@interface DBViewController ()

@property (nonatomic, strong) DBToastView *toastView;

@end

@implementation DBViewController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Private Methods

- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    CGRect startFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 80);
    CGRect endFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
    
    self.toastView = [[DBToastView alloc] initWithMessage:message backgroundColor:backgroundColor];
    self.toastView.frame = startFrame;
    self.toastView.delegate = self;
    [self.view addSubview:self.toastView];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.toastView.frame = endFrame;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(toastCloseButtonTapped)
                   withObject:self
                   afterDelay:5.0f];
    }];
}

#pragma mark - DBToastView Delegate Methods

- (void)toastCloseButtonTapped {
    CGRect endFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 60);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.toastView.frame = endFrame;
    } completion:^(BOOL finished) {
        [self.toastView removeFromSuperview];
    }];
}

@end
