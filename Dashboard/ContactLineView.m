//
//  ContactLineView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ContactLineView.h"
#import "Contact.h"
#import "DBCheckboxButton.h"

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
        
        [self.emailButton setImage:[UIImage imageNamed:@"icon-contact-email"] forState:UIControlStateNormal];
        [self.emailButton setImage:[UIImage imageNamed:@"icon-contact-email-inactive"] forState:UIControlStateDisabled];
        
        [self.phoneButton setImage:[UIImage imageNamed:@"icon-contact-phone"] forState:UIControlStateNormal];
        [self.phoneButton setImage:[UIImage imageNamed:@"icon-contact-phone-inactive"] forState:UIControlStateDisabled];

        [self.smsButton setImage:[UIImage imageNamed:@"icon-contact-sms"] forState:UIControlStateNormal];
        [self.smsButton setImage:[UIImage imageNamed:@"icon-contact-sms-inactive"] forState:UIControlStateDisabled];
        
        UIApplication *application = [UIApplication sharedApplication];
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        
        self.checkbox.tag = index;
        
        self.emailButton.enabled = (contact.email.length > 0);
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
