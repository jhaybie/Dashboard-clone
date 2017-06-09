//
//  SectionHeaderView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 6/9/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "SectionHeaderView.h"

@interface SectionHeaderView()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SectionHeaderView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 60);
    
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.titleLabel.text = title;
    }
    return self;
}

@end
