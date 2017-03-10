//
//  UserCardView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "UserCardView.h"
#import "UIImageView+WebCache.h"

@interface UserCardView()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityStateLabel;
// TODO: add outlets for email, sms and phone labels

@end

@implementation UserCardView

- (instancetype)initWithImageURL:(NSURL *)imageURL
                            name:(NSString *)name
                       cityState:(NSString *)cityState
                      emailCount:(NSInteger)emailCount
                        smsCount:(NSInteger)smsCount
                      phoneCount:(NSInteger)phoneCount {
    
    if ((self = [super init])) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"UserCardView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        CGRect frame = [UIScreen mainScreen].bounds;
        self.frame = frame;
        self.clipsToBounds = true;
        
        [self.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder-user-icon"]];
        self.nameLabel.text = name;
        self.cityStateLabel.text = cityState;
        // TODO: assign emailCount, smsCount and phoneCount to their repsective labels
    }
    return self;
}

@end
