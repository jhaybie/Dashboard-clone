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
    if (self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 230);
        self.frame = frame;
        self.clipsToBounds = true;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect evFrame = CGRectMake(0, 0, self.cardView.frame.size.width, self.cardView.frame.size.height);
        electionCardView.frame = evFrame;
        [self.cardView addSubview:electionCardView];
    }
    return self;
}

@end
