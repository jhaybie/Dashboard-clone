//
//  DetailCardView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/16/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailCardViewDelegate <NSObject>

- (void)detailCardViewStatusButtonTappedMessage:(NSString *)message;

@end

@class Race;

@interface DetailCardView : UIView

@property (strong, nonatomic) id<DetailCardViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *cityImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;
@property (strong, nonatomic) IBOutlet UIView *positionView;
@property (strong, nonatomic) IBOutlet UILabel *electionInLabel;
@property (strong, nonatomic) IBOutlet UIButton *statusButton;

- (instancetype)initWithRace:(Race *)race forDate:(NSDate *)electionDate;

@end
