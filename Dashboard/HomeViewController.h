//
//  FirstViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "DBViewController.h"
#import "ElectionCardView.h"

@interface HomeViewController : DBViewController <ElectionCardViewDelegate, FBSDKLoginButtonDelegate, UITableViewDataSource, UITableViewDelegate>

@end

