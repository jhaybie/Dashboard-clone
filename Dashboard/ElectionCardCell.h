//
//  ElectionCardCell.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ElectionCardView;

@interface ElectionCardCell : UITableViewCell

@property (strong, nonatomic) IBOutlet ElectionCardView *cardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cardViewHeightConstraint;

- (instancetype)initWithElectionCardView:(UIView *)electionCardView;

@end
