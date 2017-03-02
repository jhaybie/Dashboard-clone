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
}

- (void)setDefaultValues {
    //self.layer.cornerRadius = self.frame.size.height / 2;
    
    //UIImage *buttonImage = (self.isChecked) ? self.checkedImage : self.uncheckedImage;
    //[self setImage:buttonImage forState:UIControlStateNormal];
    [self addTarget:self
             action:@selector(buttonToggled)
   forControlEvents:UIControlEventTouchUpInside];
}

@end
