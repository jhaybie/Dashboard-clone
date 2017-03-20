//
//  ContactCell.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DBCheckboxButton.h"

@class Contact;

@protocol ContactCellDelegate <NSObject>

- (void)checkBoxButtonTapped:(id)sender;
- (void)inviteButtonTapped:(id)sender;

@end

@interface ContactCell : UITableViewCell

@property (nonatomic, strong) id<ContactCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet DBCheckboxButton *checkBoxButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;

- (instancetype)initWithContact:(Contact *)contact
                       selected:(BOOL)selected
                        invited:(BOOL)invited
                          index:(long)index;

@end
