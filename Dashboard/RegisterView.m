//
//  RegisterView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "RegisterView.h"

@implementation RegisterView

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"RegisterView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.clipsToBounds = true;
        [self setupDefaults];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupDefaults {
    // TODO: do stuff here
}

@end
