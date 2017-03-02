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

@property (strong, nonatomic) IBOutlet UIView *cardView;

- (instancetype)initWithElectionCardView:(UIView *)electionCardView;

@end
