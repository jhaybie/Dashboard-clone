//
//  LoginViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "DBViewController.h"
#import "iCarousel.h"
#import "ZipCodeViewController.h"

@interface LoginViewController : DBViewController <iCarouselDataSource, iCarouselDelegate, FBSDKLoginButtonDelegate, ZipCodeViewControllerDelegate>

@end
