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
BOOL isToastVisible = false;
NSTimer *timer;

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Private Methods

- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    CGRect startFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 80);
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
