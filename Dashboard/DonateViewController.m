//
//  DonateViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DonateViewController.h"
#import "Constant.h"
#import "DBToggleTextButton.h"
#import "UIColor+DBColors.h"

@interface DonateViewController ()

@property (strong, nonatomic) IBOutlet UITextField *donationTextField;

@property (strong, nonatomic) IBOutlet UIStackView *stackView1;
@property (strong, nonatomic) IBOutlet UIStackView *stackView2;

@property (strong, nonatomic) IBOutlet UIButton *donateButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *donateViewTopVerticalHeightConstraint;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@end

@implementation DonateViewController
BOOL firstDonateTry = true; // FOR TESTING ONLY -- REMOVE WHEN DONATE FEATURE IS IMPLEMENTED


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adjust spacing for devices
    int offset = 0;
    if (IS_IPHONE_4_7_INCH) {
        offset = 40;
    } else if (IS_IPHONE_5_5_INCH) {
        offset = 60;
    }
    self.donateViewTopVerticalHeightConstraint.constant += offset;
    
    // Done button on keyboard
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    UIBarButtonItem *keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(doneButtonTapped:)];
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:keyboardDoneButton, nil]];
    self.donationTextField.inputAccessoryView = self.keyboardToolbar;
    [self.donationTextField addTarget:self
                               action:@selector(textFieldDidBeginEditing:)
                     forControlEvents:UIControlEventEditingDidBegin];
    [self.donationTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    [self.donationTextField addTarget:self
                               action:@selector(textFieldDidEndEditing:)
                     forControlEvents:UIControlEventEditingDidEnd];
    
    //[self.donationTextField becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)deselectOtherDonateButtons:(DBToggleTextButton *)sender {
    if (sender) {
        for (UIView *view in self.stackView1.subviews) {
            if ([view isKindOfClass:[DBToggleTextButton class]]) {
                DBToggleTextButton *button = (DBToggleTextButton *)view;
                if (button.tag != sender.tag) {
                    button.isSelected = false;
                }
            }
        }
        for (UIView *view in self.stackView2.subviews) {
            if ([view isKindOfClass:[DBToggleTextButton class]]) {
                DBToggleTextButton *button = (DBToggleTextButton *)view;
                if (button.tag != sender.tag) {
                    button.isSelected = false;
                }
            }
        }
    } else {
        for (UIView *view in self.stackView1.subviews) {
            if ([view isKindOfClass:[DBToggleTextButton class]]) {
                DBToggleTextButton *button = (DBToggleTextButton *)view;
                button.isSelected = false;
            }
        }
        for (UIView *view in self.stackView2.subviews) {
            if ([view isKindOfClass:[DBToggleTextButton class]]) {
                DBToggleTextButton *button = (DBToggleTextButton *)view;
                button.isSelected = false;
            }
        }
    }
}

- (void)doneButtonTapped:(UITapGestureRecognizer *)sender {
    [self.donationTextField resignFirstResponder];
    
    NSString *amountString = self.donationTextField.text;
    [amountString stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
    self.donationTextField.tag = amountString.intValue;
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.donationTextField.text = [self.donationTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.donationTextField.tag = textField.text.intValue;
    BOOL enabled = (textField.text.length > 0);
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        item.enabled = enabled;
    }
    self.donateButton.backgroundColor = (enabled) ? [UIColor dbBlue2] : [UIColor dbBlue2Disabled];
    self.donateButton.userInteractionEnabled = enabled;
    [self deselectOtherDonateButtons:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.donationTextField.tag = textField.text.intValue;
    self.donationTextField.text = [NSString stringWithFormat:@"$%i", textField.text.intValue];
}

#pragma mark - IBActions

- (IBAction)donateButtonTapped:(id)sender {
    [self.donationTextField resignFirstResponder];
    
    // BEGIN TEST CODE FOR DONATE
    if (firstDonateTry) {
        [self displayToastWithMessage:@"Transaction failed. Please try again." backgroundColor:[UIColor globalFailureColor]];
        firstDonateTry = false;
    } else {
        // KEEP THIS PART
        // TODO: donation payment processing goes here
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thank you!"
                                                                       message:@"We appreciate your contribution."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Place another donation"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Go to your Dashboard"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self.tabBarController setSelectedIndex:0];
                                                }]];
        
        [self presentViewController:alert
                           animated:true
                         completion:nil];
        // END KEEP THIS PART
        firstDonateTry = true;
    }
    // END TEST CODE FOR DONATE
}

- (IBAction)presetDonationButtonTapped:(DBToggleTextButton *)sender {
    [self.donationTextField resignFirstResponder];
    self.donateButton.backgroundColor = [UIColor dbBlue2];
    self.donateButton.userInteractionEnabled = true;
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        item.enabled = true;
    }
    int donationValue = (int)sender.tag;
    NSString *donationString = [NSString stringWithFormat:@"$%i", donationValue];
    self.donationTextField.text = donationString;
    self.donationTextField.tag = donationValue;
    [self deselectOtherDonateButtons:sender];
}

// TODO: delete method below when Donate feature is fully working
- (IBAction)tempDonateNowButtonTapped:(id)sender {
    NSURL *donateURL = [NSURL URLWithString:@"https://newfounders-riseparty.nationbuilder.com/donate"];
    
    [[UIApplication sharedApplication] openURL:donateURL
                                       options:@{}
                             completionHandler:nil];
}

@end
