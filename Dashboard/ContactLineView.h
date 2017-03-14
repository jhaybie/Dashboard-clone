//
//  ContactLineView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Contact;
@class DBCheckboxButton;

@protocol ContactLineViewDelegate <NSObject>

- (void)checkBoxButtonTapped:(DBCheckboxButton *)sender;
- (void)emailButtonTapped:(id)sender;
- (void)smsButtonTapped:(id)sender;
- (void)phoneButtonTapped:(id)sender;

@end

@interface ContactLineView : UIView

@property (nonatomic, strong) id<ContactLineViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet DBCheckboxButton *checkbox;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *smsButton;
@property (strong, nonatomic) IBOutlet UIButton *phoneButton;

- (instancetype)initWithContact:(Contact *)contact index:(int)index;

@end
