//
//  DBNagView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/16/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBNagView.h"
#import "Constant.h"

@interface DBNagView()

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation DBNagView

#pragma mark - Init Methods

- (instancetype)initWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    int width = [[UIScreen mainScreen] bounds].size.width;
    int height = 120;
    CGRect frame = CGRectMake(0, 0, width, height);
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DBNagView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.backgroundView.backgroundColor = backgroundColor;
        self.messageLabel.text = message;
        
        // Adjust font size for devices
        CGFloat fontSize = 13;
        if (!IS_IPHONE_4_INCH) {
            fontSize = 16;
        }
        [self.messageLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)enterAddressButtonTapped:(id)sender {
    [self.delegate enterAddressButtonTapped:sender];
}


@end
