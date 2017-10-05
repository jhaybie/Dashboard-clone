//
//  SettingsViewController.h
//  Dashboard
//
//  Created by Ching Parungao on 08/24/2017.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "UIColor+DBColors.h"
#import "DBViewController.h"
#import "GlobalAPI.h"

@class UserCardView;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)didDismissViewController:(UIViewController *)viewController;

@end

@interface SettingsViewController : DBViewController <UITextFieldDelegate>

@property (strong, nonatomic) id<SettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) UserCardView *cardView;

@end
