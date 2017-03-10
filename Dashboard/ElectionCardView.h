//
//  ElectionCardView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Election;

@interface ElectionCardView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *cityImageView;
@property (strong, nonatomic) IBOutlet UIView *electionLabelView;
@property (strong, nonatomic) IBOutlet UILabel *electionInLabel;
@property (strong, nonatomic) IBOutlet UILabel *electionTimeLabel;

@property (strong, nonatomic) IBOutlet UIView *badgeView;
@property (strong, nonatomic) IBOutlet UILabel *badgeCountLabel;

@property (strong, nonatomic) IBOutlet UIView *positionView;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityStateLabel;

- (instancetype)initWithElection:(Election *)election;

@end
