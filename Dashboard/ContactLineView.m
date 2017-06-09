//
//  ContactLineView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ContactLineView.h"
#import "Constant.h"
#import "Contact.h"
#import "DBCheckboxButton.h"

@interface ContactLineView()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactTrailingConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineSpacingConstraint1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineSpacingConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineSpacingConstraint3;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineSpacingConstraint4;

@end

@implementation ContactLineView

#pragma mark - Init Methods

- (instancetype)initWithContact:(Contact *)contact index:(int)index {
    int width = [[UIScreen mainScreen] bounds].size.width - 48;
    int height = 40;
    CGRect frame = CGRectMake(0, 0, width, height);
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ContactLineView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        // Adjust spacing for devices
        int offset = 8;
        CGFloat fontSize = 12;
        if (IS_IPHONE_4_7_INCH) {
            offset = 16;
            fontSize = 14;
        } else if (IS_IPHONE_5_5_INCH) {
            offset = 20;
            fontSize = 16;
        }
        self.contactLeadingConstraint.constant += offset;
        self.contactTrailingConstraint.constant += offset;
        self.lineSpacingConstraint1.constant += offset;
        self.lineSpacingConstraint2.constant += offset;
        self.lineSpacingConstraint3.constant += offset;
        self.lineSpacingConstraint4.constant += offset;

        [self.nameLabel setFont:[UIFont systemFontOfSize:fontSize]];
        
        [self.emailButton setImage:[UIImage imageNamed:@"icon-contact-email"] forState:UIControlStateNormal];
        [self.emailButton setImage:[UIImage imageNamed:@"icon-contact-email-inactive"] forState:UIControlStateDisabled];
        
        [self.phoneButton setImage:[UIImage imageNamed:@"icon-contact-phone"] forState:UIControlStateNormal];
        [self.phoneButton setImage:[UIImage imageNamed:@"icon-contact-phone-inactive"] forState:UIControlStateDisabled];

        [self.smsButton setImage:[UIImage imageNamed:@"icon-contact-sms"] forState:UIControlStateNormal];
        [self.smsButton setImage:[UIImage imageNamed:@"icon-contact-sms-inactive"] forState:UIControlStateDisabled];
        
        UIApplication *application = [UIApplication sharedApplication];
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        
        self.checkbox.tag = index;
        
        if (contact.email.length > 0 && [MFMailComposeViewController canSendMail]) {
            self.emailButton.enabled = true;
        } else {
            self.emailButton.enabled = false;
        }
        self.emailButton.tag = index;
        
        if (contact.phone.length > 0 && [application canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            self.phoneButton.enabled = true;
        } else {
            self.phoneButton.enabled = false;
        }
        self.phoneButton.tag = index;
        
        if(contact.mobile.length > 0 && [MFMessageComposeViewController canSendText]) {
            self.smsButton.enabled = true;
        } else {
            self.smsButton.enabled = false;
        }
        self.smsButton.tag = index;
        
        if (!self.emailButton.enabled && !self.phoneButton.enabled && !self.smsButton.enabled) {
            self.checkbox.enabled = false;
            self.nameLabel.textColor = [UIColor lightGrayColor];
        }
        self.checkbox.isChecked = false;
    }
    return self;
}

#pragma mark - Private Methods

#pragma mark - IBActions

- (IBAction)checkboxButtonTapped:(DBCheckboxButton *)sender {
    [self.delegate checkBoxButtonTapped:sender];
}

- (IBAction)emailButtonTapped:(id)sender {
    [self.delegate emailButtonTapped:sender];
}

- (IBAction)smsButtonTapped:(id)sender {
    [self.delegate smsButtonTapped:sender];
}

- (IBAction)phoneButtonTapped:(id)sender {
    [self.delegate phoneButtonTapped:sender];
}

@end
