//
//  UserCardView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCardView : UIView

- (instancetype)initWithImageURL:(NSURL *)imageURL
                            name:(NSString *)name
                       cityState:(NSString *)cityState
                      emailCount:(int)emailCount
                        smsCount:(int)smsCount
                      phoneCount:(int)phoneCount;

@end
