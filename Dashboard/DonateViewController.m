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
#import "SCLAlertView.h"
#import "SVProgressHUD.h"

@interface DonateViewController ()

@property (strong, nonatomic) IBOutlet UITextField *donationTextField;

@property (strong, nonatomic) IBOutlet UIStackView *stackView1;
@property (strong, nonatomic) IBOutlet UIStackView *stackView2;

@property (strong, nonatomic) IBOutlet UIButton *donateButton;
@property (weak, nonatomic) IBOutlet UITextField *occupationTextField;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *donateViewTopVerticalHeightConstraint;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@property(strong, nonatomic)STPPaymentContext *paymentContext;


@end

@implementation DonateViewController


BOOL firstDonateTry = true; // FOR TESTING ONLY -- REMOVE WHEN DONATE FEATURE IS IMPLEMENTED


STPCustomerContext *customerContext;
STPPaymentCardTextField *paymentField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adjust spacing for devices
    int offset = 0;
    int paymentFieldOffset = 160;
    if (IS_IPHONE_4_7_INCH) {
        offset = 40;
    } else if (IS_IPHONE_5_5_INCH) {
        offset = 60;
        paymentFieldOffset = 180;
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
    
    
    paymentField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-self.occupationTextField.frame.size.width)/2,_occupationTextField.frame.origin.y  + paymentFieldOffset, self.occupationTextField.frame.size.width, 44)];
    paymentField.backgroundColor= [UIColor whiteColor];
    
    self.occupationTextField.delegate=self;
    
    UILabel *paymentLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-500)/2,  paymentField.frame.origin.y-60, 500, 100)];
    [paymentLabel setText:@"Enter Credit Card Number"];
    [paymentLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular]];
    [paymentLabel setNumberOfLines:0];
    [paymentLabel setBaselineAdjustment:YES];
    [paymentLabel setAdjustsFontSizeToFitWidth:YES];
    [paymentLabel setClipsToBounds:YES];
    [paymentLabel setBackgroundColor:[UIColor clearColor]];
    [paymentLabel setTextColor:[UIColor whiteColor]];
    [paymentLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    //[self.view addSubview:paymentLabel];
    //[self.view addSubview:paymentField];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - IBActions

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

- (IBAction)donateButtonTapped:(id)sender {
    
    
    [self tempDonateNowButtonTapped:nil];
    return;
    
    if (paymentField.isValid==NO)
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"Error" subTitle:@"Please check your Credit Card information" closeButtonTitle:@"OK" duration:0.0f]; // Error
        return;
    }
    if ([self.occupationTextField.text isEqualToString:@""])
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"Error" subTitle:@"Your occupation and employer info is required" closeButtonTitle:@"OK" duration:0.0f]; // Error
        return;
    }
    [SVProgressHUD show];
    self.donateButton.enabled=NO;
    
    [self.donationTextField resignFirstResponder];
    
    customerContext = [[STPCustomerContext alloc] initWithKeyProvider:[StripeAPIClient sharedClient]];
    
    self.paymentContext = [[STPPaymentContext alloc] initWithCustomerContext:customerContext];
    
    
    self.paymentContext.delegate = self;
    self.paymentContext.hostViewController = self;
    
    int amount = [[self.donationTextField.text stringByReplacingOccurrencesOfString: @"$" withString:@""] intValue];
    
    self.paymentContext.paymentAmount =amount;
    
    
}


#pragma mark - Stripe Delegates

-(void)paymentContextDidChange:(STPPaymentContext *)paymentContext
{
    if (self.paymentContext.paymentAmount!=0)
    {
        STPSourceParams *sourceParams = [STPSourceParams cardParamsWithCard:paymentField.cardParams];
        
        [[STPAPIClient sharedClient] createSourceWithParams:sourceParams completion:^(STPSource *source, NSError *error) {
            if (source.flow == STPSourceFlowNone
                && source.status == STPSourceStatusChargeable) {
                [[StripeAPIClient sharedClient] createPaymentChargeUsingSourceAndParams:source amount:self.paymentContext.paymentAmount*100 completion:^(void){
                    
                    [SVProgressHUD dismiss];
                    [paymentField clear];
                    [self.occupationTextField setText:@""];
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    self.donateButton.enabled=YES;
                    [alert showInfo:self title:@"Success!!!" subTitle:@"Thank you for your donation" closeButtonTitle:@"Done" duration:0.0f];
                }];
                
            }
        }];
    }
    
    
    NSLog(@"Did Change %ld",self.paymentContext.paymentAmount);
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFailToLoadWithError:(NSError *)error {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self title:@"Error" subTitle:error.description closeButtonTitle:@"OK" duration:0.0f]; // Error
    // Show the error to your user, etc.
    [SVProgressHUD dismiss];
    self.donateButton.enabled=YES;
    [self.occupationTextField resignFirstResponder];
}

- (void)paymentContext:(STPPaymentContext *)paymentContext
didCreatePaymentResult:(STPPaymentResult *)paymentResult
            completion:(STPErrorBlock)completion {
    [[StripeAPIClient sharedClient]completeCharge:paymentResult amount:paymentContext.paymentAmount shippingAddress:paymentContext.shippingAddress shippingMethod:nil completion:^(void){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showInfo:self title:@"Success!" subTitle:@"Thank you for your donation" closeButtonTitle:@"Done" duration:0.0f]; // Info
        
        
    }];
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    NSLog(@"Card number: %@ Exp Month: %@ Exp Year: %@ CVC: %@", textField.cardParams.number, @(textField.cardParams.expMonth), @(textField.cardParams.expYear), textField.cardParams.cvc);
    self.donateButton.hidden =textField.isValid;
    
}

- (void)paymentContext:(STPPaymentContext *)paymentContext
   didFinishWithStatus:(STPPaymentStatus)status
                 error:(NSError *)error {
    switch (status) {
        case STPPaymentStatusSuccess:
            break;
        case STPPaymentStatusError:
            break;
        case STPPaymentStatusUserCancellation:
            return; // Do nothing
    }
}

@end
