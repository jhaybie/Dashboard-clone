//
//  DBNagView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/16/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBNagViewDelegate <NSObject>

- (void)enterAddressButtonTapped:(id)sender;

@end

@interface DBNagView : UIView

@property (strong, nonatomic) id<DBNagViewDelegate> delegate;

- (instancetype)initWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor;

@end
