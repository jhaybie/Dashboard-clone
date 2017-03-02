//
//  DBSegmentedControl.h
//  RiseMovement
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBSegmentedControl : UISegmentedControl

- (void)showActivityIndicatorForIndex:(int)segmentIndex;
- (void)hideActivityIndicatorForIndex:(int)segmentIndex segmentTitles:(NSArray<NSString *> *)segmentTitles;

@end
