//
//  UIColor+DBColors.m
//  RiseMovement
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "UIColor+DBColors.h"

@implementation UIColor (DBColors)

+ (UIColor *)dbBlue1 {
    return [UIColor colorWithHex:0x29ABE2];
}

+ (UIColor *)dbBlue2 {
    return [UIColor colorWithHex:0x1F80AA];
}

+ (UIColor *)dbBlue3 {
    return [UIColor colorWithHex:0x155671];
}

+ (UIColor *)dbBlue4 {
    return [UIColor colorWithHex:0x0A2B39];
}

+ (UIColor *)globalActiveColor {
    return [UIColor colorWithHex:0xE6E6E6];
}

+ (UIColor *)globalPassiveColor {
    return [UIColor colorWithHex:0x333333];
}

+ (UIColor *)globalDarkColor {
    return [UIColor colorWithHex:0x1A1A1A];
}

+ (UIColor *)globalPendingColor {
    return [UIColor colorWithHex:0xED951C];
}

+ (UIColor *)globalSuccessColor {
    return [UIColor colorWithHex:0x22B573];
}

+ (UIColor *)globalFailureColor {
    return [UIColor colorWithHex:0xE44757];
}

+ (UIColor *)progressBarGray {
    return [UIColor colorWithHex:0x4D4D4D];
}

+ (UIColor *)wellrightBlue {
    return [UIColor colorWithHex:0x6991CB];
}

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    const char *cStr = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

- (UIColor *)lighterColorRemoveSaturation:(CGFloat)removeS
                              resultAlpha:(CGFloat)alpha {
    CGFloat h,s,b,a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:MAX(s - removeS, 0.0)
                          brightness:b
                               alpha:alpha == -1? a:alpha];
    }
    return nil;
}

- (UIColor *)darkerColor {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

- (UIColor *)lighterColor {
    return [self lighterColorRemoveSaturation:0.25
                                  resultAlpha:-1];
}

@end
