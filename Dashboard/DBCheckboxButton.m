//
//  DBCheckboxButton.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBCheckboxButton.h"

@implementation DBCheckboxButton

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
    self.isChecked = !self.isChecked;
    UIImage *buttonImage = (self.isChecked) ? self.checkedImage : self.uncheckedImage;
    [self setImage:buttonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setCheckedImage:(UIImage *)checkedImage {
    _checkedImage = checkedImage;
    [self setNeedsLayout];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    UIImage *buttonImage = (isChecked) ? self.checkedImage : self.uncheckedImage;
    [self setImage:buttonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setUncheckedImage:(UIImage *)uncheckedImage {
    _uncheckedImage = uncheckedImage;
    [self setNeedsLayout];
}

- (void)setDefaultValues {
    [self addTarget:self
             action:@selector(buttonToggled)
   forControlEvents:UIControlEventTouchUpInside];
}

@end
