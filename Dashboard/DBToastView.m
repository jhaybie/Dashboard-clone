//
//  DBToastView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBToastView.h"

@interface DBToastView()

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation DBToastView

- (instancetype)initWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    int width = [[UIScreen mainScreen] bounds].size.width;
    int height = 80;
    CGRect frame = CGRectMake(0, 0, width, height);
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DBToastView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.backgroundView.backgroundColor = backgroundColor;
        self.messageLabel.text = message;
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)toastCloseButtonTapped:(id)sender {
    [self.delegate toastCloseButtonTapped];
}

@end
