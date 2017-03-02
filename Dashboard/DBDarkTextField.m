//
//  DBDarkTextField.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBDarkTextField.h"
#import "UIColor+DBColors.h"

@implementation DBDarkTextField

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

- (void)setDefaultValues {
    self.textColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
}

- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:leftImage];
    leftImageView.frame = CGRectMake(0, 0, leftImageView.image.size.width + 16, leftImageView.image.size.height);
    leftImageView.contentMode = UIViewContentModeBottom;
    self.leftView = leftImageView;
    self.leftViewMode = UITextFieldViewModeAlways;
    [self setNeedsLayout];
}

- (void)setRightImage:(UIImage *)rightImage {
    _rightImage = rightImage;
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:rightImage];
    rightImageView.frame = CGRectMake(self.frame.size.width - rightImageView.image.size.width + 16, 0, rightImageView.image.size.width + 16, rightImageView.image.size.height);
    rightImageView.contentMode = UIViewContentModeBottom;
    self.rightView = rightImageView;
    self.rightViewMode = UITextFieldViewModeAlways;
    [self setNeedsLayout];
}

@end
