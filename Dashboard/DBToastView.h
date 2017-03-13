//
//  DBToastView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBToastViewDelegate <NSObject>

- (void)toastCloseButtonTapped;

@end

@interface DBToastView : UIView

@property (nonatomic, strong) id<DBToastViewDelegate> delegate;

- (instancetype)initWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor;

@end
