//
//  UIColor+DBColors.h
//  RiseMovement
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DBColors)

+ (UIColor *)dbBlue1;
+ (UIColor *)dbBlue2;
+ (UIColor *)dbBlue3;
+ (UIColor *)dbBlue4;

+ (UIColor *)globalActiveColor;
+ (UIColor *)globalPassiveColor;
+ (UIColor *)globalDarkColor;
+ (UIColor *)globalPendingColor;
+ (UIColor *)globalSuccessColor;
+ (UIColor *)globalFailureColor;
+ (UIColor *)progressBarGray;
+ (UIColor *)wellrightBlue;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

- (UIColor *)darkerColor;
- (UIColor *)lighterColor;

@end
