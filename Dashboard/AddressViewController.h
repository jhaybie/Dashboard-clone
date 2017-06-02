//
//  AddressViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>

@class UserCardView;

@protocol AddressViewControllerDelegate <NSObject>

- (void)didDismissViewController:(UIViewController *)viewController;

@end

@interface AddressViewController : UIViewController

@property (strong, nonatomic) id<AddressViewControllerDelegate> delegate;
@property (strong, nonatomic) UserCardView *cardView;

@end
