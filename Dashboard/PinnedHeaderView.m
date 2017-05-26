//
//  PinnedHeaderView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "PinnedHeaderView.h"

@implementation PinnedHeaderView

- (instancetype)initWithPosition:(NSString *)position {
    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 63);
    
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"PinnedHeaderView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.positionLabel.text = position;
    }
    return self;
}

@end
