//
//  LoginViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>

#import "AddressViewController.h"
#import "DBViewController.h"
#import "iCarousel.h"

@interface LoginViewController : DBViewController <iCarouselDataSource, iCarouselDelegate, FBSDKLoginButtonDelegate, AddressViewControllerDelegate>

@end
