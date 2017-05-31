//
//  ElectionCardView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ElectionCardViewDelegate <NSObject>

- (void)electionCardViewStatusButtonTappedMessage:(NSDictionary *)messageDict;

@end

@class Race;

@interface ElectionCardView : UIView

@property (nonatomic, strong)id<ElectionCardViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIImageView *cityImageView;
@property (strong, nonatomic) IBOutlet UIView *electionLabelView;
@property (strong, nonatomic) IBOutlet UILabel *electionInLabel;
@property (strong, nonatomic) IBOutlet UILabel *electionTimeLabel;

@property (strong, nonatomic) IBOutlet UIButton *statusButton;

@property (strong, nonatomic) IBOutlet UIView *badgeView;
@property (strong, nonatomic) IBOutlet UILabel *badgeCountLabel;

@property (strong, nonatomic) IBOutlet UIView *positionView;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;

- (instancetype)initWithRace:(Race *)race forDate:(NSDate *)electionDate forContact:(BOOL)forContact contactCount:(int)contactCount preferredWidth:(CGFloat)width;

@end
