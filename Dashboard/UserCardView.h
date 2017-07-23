//
//  UserCardView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCardView : UIView
@property (strong, nonatomic) IBOutlet UIButton *menuButton;

- (instancetype)initWithImageURL:(NSURL *)imageURL
                            name:(NSString *)name
                       cityState:(NSString *)cityState
                      emailCount:(NSInteger)emailCount
                        smsCount:(NSInteger)smsCount
                      phoneCount:(NSInteger)phoneCount;

@end
