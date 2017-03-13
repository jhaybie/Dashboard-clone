//
//  FirstViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "DBViewController.h"

@interface HomeViewController : DBViewController <FBSDKLoginButtonDelegate, UITableViewDataSource, UITableViewDelegate>


@end

