//
//  ElectionCardView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionCardView.h"

@interface ElectionCardView()

@end

@implementation ElectionCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.clipsToBounds = true;
    }
    return self;
}

@end
