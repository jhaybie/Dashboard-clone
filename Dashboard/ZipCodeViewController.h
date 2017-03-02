//
//  ZipCodeViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserCardView;

@protocol ZipCodeViewControllerDelegate <NSObject>

- (void)didDismissViewController:(UIViewController *)viewController;

@end

@interface ZipCodeViewController : UIViewController

@property (strong, nonatomic) id<ZipCodeViewControllerDelegate> delegate;
@property (strong, nonatomic) UserCardView *cardView;

@end
