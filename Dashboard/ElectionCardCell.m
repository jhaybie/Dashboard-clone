//
//  ElectionCardCell.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionCardCell.h"
#import "ElectionCardView.h"

@implementation ElectionCardCell

- (instancetype)initWithElectionCardView:(UIView *)electionCardView {
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 217);
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        //self.frame = frame;
        self.clipsToBounds = true;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        CGRect evFrame = CGRectMake(0, 0, self.cardView.frame.size.width, electionCardView.frame.size.height);
        electionCardView.frame = evFrame;
        [self.cardView addSubview:electionCardView];
        [self.cardView layoutIfNeeded];
        [self layoutIfNeeded];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
}

@end
