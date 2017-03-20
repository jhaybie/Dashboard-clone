//
//  ContactCell.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ContactCell.h"
#import "Constant.h"
#import "Contact.h"
#import "UIColor+DBColors.h"

@interface ContactCell()

@property (strong, nonatomic) IBOutlet UIImageView *contactImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spacingConstraint1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spacingConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spacingConstraint3;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spacingConstraint4;



@end

@implementation ContactCell

- (instancetype)initWithContact:(Contact *)contact selected:(BOOL)selected invited:(BOOL)invited index:(long)index {
    if (self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ContactCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 90);
        self.frame = frame;
        self.clipsToBounds = true;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int offset = 0;
        if (IS_IPHONE_4_7_INCH) {
            offset = 5;
        } else if (IS_IPHONE_5_5_INCH) {
            offset = 10;
        }
        self.spacingConstraint1.constant += offset;
        self.spacingConstraint2.constant += offset;
        self.spacingConstraint3.constant += offset;
        self.spacingConstraint4.constant += offset;
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        
        NSString *city = contact.city;
        NSString *state = contact.state;
        NSString *separator = (contact.city.length == 0 || contact.state.length == 0) ? @"" : @", ";
        
        self.locationLabel.text = [NSString stringWithFormat:@"%@%@%@", city, separator, state];
        
        if (contact.profileImage) {
            self.contactImageView.image = contact.profileImage;
        }
        
        self.checkBoxButton.isChecked = selected;
        
        self.checkBoxButton.tag = (NSInteger)index;
        self.inviteButton.tag = (NSInteger)index;
        
        if (invited) {
            self.inviteButton.userInteractionEnabled = false;
            [self.inviteButton setTitle:@"Invited" forState:UIControlStateNormal];
            self.inviteButton.backgroundColor = [UIColor color4D4D4D];
        }
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)checkBoxButtonTapped:(id)sender {
    [self.delegate checkBoxButtonTapped:sender];
}

- (IBAction)inviteButtonTapped:(id)sender {
    [self.delegate inviteButtonTapped:sender];
}

@end
