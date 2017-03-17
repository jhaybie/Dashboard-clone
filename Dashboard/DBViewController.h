//
//  DBViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBNagView.h"
#import "AddressViewController.h"
#import "DBToastView.h"

@interface DBViewController : UIViewController <AddressViewControllerDelegate, DBNagViewDelegate, DBToastViewDelegate>

@property (nonatomic, strong) DBNagView *nagView;
@property (nonatomic) BOOL shouldShowNagView;

- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor;

@end
