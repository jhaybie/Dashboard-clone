//
//  AddressViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "AddressViewController.h"
#import "Constant.h"
#import "UserCardView.h"

@interface AddressViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addressViewTopVerticalHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *label1VerticalHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *label2VerticalHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textField1VerticalHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textField2VerticalHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textField3VerticalHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textField4VerticalHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cardViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIView *userCardView;
@property (strong, nonatomic) IBOutlet UITextField *streetTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateTextField;
@property (strong, nonatomic) IBOutlet UITextField *zipcodeTextField;

@property (strong, nonatomic) UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardSkipButton;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@end

@implementation AddressViewController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.cardView != nil) {
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
        self.cardView.frame = frame;
        [self.userCardView addSubview:self.cardView];
        self.addressViewTopVerticalHeightConstraint.constant = 4;
    } else {
        self.addressViewTopVerticalHeightConstraint.constant = 40;
        self.cardViewHeightConstraint.constant = 0;
    }
    
    // Adjust spacing for devices
    int offset = 0;
    if (IS_IPHONE_4_7_INCH) {
        offset = 4;
    } else if (IS_IPHONE_5_5_INCH) {
        offset = 7;
    }
    self.addressViewTopVerticalHeightConstraint.constant += offset * 5;
    self.label1VerticalHeightConstraint.constant += offset;
    self.label2VerticalHeightConstraint.constant += offset;
    self.textField1VerticalHeightConstraint.constant += offset;
    self.textField2VerticalHeightConstraint.constant += offset;
    self.textField3VerticalHeightConstraint.constant += offset;
    self.textField4VerticalHeightConstraint.constant += offset;
    // Done button on keyboard
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(doneButtonTapped:)];
    self.keyboardDoneButton.enabled = false;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    self.keyboardSkipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip for now"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(skipButtonTapped:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:self.keyboardDoneButton, flexibleSpace, self.keyboardSkipButton, nil]];
    
    self.streetTextField.inputAccessoryView = self.keyboardToolbar;
    self.cityTextField.inputAccessoryView = self.keyboardToolbar;
    self.stateTextField.inputAccessoryView = self.keyboardToolbar;
    self.zipcodeTextField.inputAccessoryView = self.keyboardToolbar;
    
    [self.streetTextField addTarget:self
                             action:@selector(textFieldDidChange:)
                   forControlEvents:UIControlEventEditingChanged];
    [self.cityTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    [self.stateTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    [self.zipcodeTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]) {
        self.streetTextField.text = [defaults objectForKey:USER_STREET];
        self.cityTextField.text = [defaults objectForKey:USER_CITY];
        self.stateTextField.text = [[defaults objectForKey:USER_STATE] uppercaseString];
        self.zipcodeTextField.text = [defaults objectForKey:USER_ZIP_CODE];
        [self textFieldDidChange:self.zipcodeTextField];
    }
    
    [self.streetTextField becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)doneButtonTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:true];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"True" forKey:USER_ADDRESS_EXISTS];
    [defaults setObject:self.streetTextField.text forKey:USER_STREET];
    [defaults setObject:self.cityTextField.text forKey:USER_CITY];
    [defaults setObject:self.stateTextField.text forKey:USER_STATE];
    [defaults setObject:self.zipcodeTextField.text forKey:USER_ZIP_CODE];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
    
    [self.delegate didDismissViewController:self];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)skipButtonTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:true];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"False" forKey:USER_ADDRESS_EXISTS];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
    
    [self.delegate didDismissViewController:self];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidChange:(UITextField *)textField {
    BOOL enabled = false;
    if (self.streetTextField.text.length > 0
        && self.cityTextField.text.length > 0
        && self.stateTextField.text.length == 2
        && self.zipcodeTextField.text.length == 5) {
        
        enabled = true;
    }
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        if (item == self.keyboardDoneButton) {
            item.enabled = enabled;
        }
    }
}

@end
