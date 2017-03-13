//
//  DBToggleTextButton.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBToggleTextButton.h"
#import "UIColor+DBColors.h"

@implementation DBToggleTextButton

#pragma mark - Init Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

#pragma mark - Private Methods

- (void)buttonToggled {
    if (!self.isSelected) {
        self.isSelected = true;
    }
}

- (void)setDefaultValues {
    [self addTarget:self
             action:@selector(buttonToggled)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)setIsSelected:(BOOL)isSelected {
    UIColor *backgroundColor = (isSelected) ? [UIColor dbBlue2] : [UIColor buttonDeselectedGray];
    UIColor *textColor = (isSelected) ? [UIColor whiteColor] : [UIColor darkGrayColor];
    
    self.backgroundColor = backgroundColor;
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

@end
