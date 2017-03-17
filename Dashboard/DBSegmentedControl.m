//
//  DBSegmentedControl.m
//  RiseMovement
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBSegmentedControl.h"
#import "Constant.h"
#import "UIColor+DBColors.h"

@interface DBSegmentedControl()

@property (nonatomic,strong) UIView *underlineView;

@end

@implementation DBSegmentedControl

#pragma mark - Init Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setupDefaults];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupDefaults];
    }
    
    return self;
}

- (void)setupDefaults {
    // Adjust font size for devices
    CGFloat fontSize = 12;
    if (IS_IPHONE_4_7_INCH) {
        fontSize = 14;
    } else if (IS_IPHONE_5_5_INCH) {
        fontSize = 16;
    }
    
    NSDictionary *selectedAttributes = @{
                                         NSFontAttributeName            : [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold],
                                         NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#333333"]
                                         };
    NSDictionary *normalAttributes = @{
                                       NSFontAttributeName            : [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight],
                                       NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#999999"],
                                       };
    
    [self setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    [self setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    
    self.backgroundColor = [UIColor globalActiveColor];
    [self setBackgroundImage:[UIImage imageNamed:@"segment-deselected"]
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[UIImage imageNamed:@"segment-selected"]
                    forState:UIControlStateSelected
                  barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:[UIImage imageNamed:@"segment-side"]
      forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[UIImage imageNamed:@"segment-side"]
      forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateSelected
               barMetrics:UIBarMetricsDefault];
}

#pragma mark - Public Methods

- (void)showActivityIndicatorForIndex:(int)segmentIndex {
    [self setTitle:nil forSegmentAtIndex:segmentIndex];

    CGFloat height = self.frame.size.height;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width / 3;
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(width / 2, height / 2);
    [activityIndicatorView startAnimating];
    
    UIView *segmentView = [self.subviews objectAtIndex:segmentIndex];
    segmentView.userInteractionEnabled = false;
    [segmentView addSubview:activityIndicatorView];
}

- (void)hideActivityIndicatorForIndex:(int)segmentIndex segmentTitles:(NSArray<NSString *> *)segmentTitles {
    UIView *segmentView = [self.subviews objectAtIndex:segmentIndex];
    segmentView.userInteractionEnabled = true;
    for (UIView *view in segmentView.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
    [self setTitle:segmentTitles[segmentIndex] forSegmentAtIndex:segmentIndex];
}

@end
