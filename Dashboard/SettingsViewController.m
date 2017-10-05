//
//  SettingsViewController.m
//  Dashboard
//
//  Created by Ching Parungao on 08/24/2017.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constant.h"
#import "UserCardView.h"

@interface SettingsViewController ()

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
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;


@property (strong, nonatomic) UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardSkipButton;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@end

@implementation SettingsViewController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([FBSDKAccessToken currentAccessToken]) {
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
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(saveButtonTapped:)];
    self.keyboardDoneButton.enabled = false;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    self.keyboardSkipButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(skipButtonTapped:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:self.keyboardDoneButton, flexibleSpace, self.keyboardSkipButton, nil]];
    
    self.firstNameTextField.inputAccessoryView=self.keyboardToolbar;
    self.lastNameTextField.inputAccessoryView=self.keyboardToolbar;
    
    self.streetTextField.inputAccessoryView = self.keyboardToolbar;
    self.cityTextField.inputAccessoryView = self.keyboardToolbar;
    self.stateTextField.inputAccessoryView = self.keyboardToolbar;
    self.zipcodeTextField.inputAccessoryView = self.keyboardToolbar;
    
    [self.firstNameTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];
    [self.lastNameTextField addTarget:self
                               action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingChanged];
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
    
    
    
    
//    CALayer *divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, self.firstNameTextField.frame.size.width, 1);
//    [self.firstNameTextField.layer addSublayer:divider];
//    
//    divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, self.firstNameTextField.frame.size.width, 1);
//    [self.lastNameTextField.layer addSublayer:divider];
//    
//    
//    divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, self.firstNameTextField.frame.size.width, 1);
//    [self.streetTextField.layer addSublayer:divider];
//    
//    divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, self.firstNameTextField.frame.size.width, 1);
//    [self.stateTextField.layer addSublayer:divider];
//    
//    divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, 90, 1);
//    [self.zipcodeTextField.layer addSublayer:divider];
//    
//    
//    divider = [CALayer layer];
//    divider.borderColor = [UIColor whiteColor].CGColor;
//    divider.borderWidth = 1;
//    divider.frame = CGRectMake(0, self.firstNameTextField.frame.size.height-5, self.firstNameTextField.frame.size.width, 1);
//    [self.cityTextField.layer addSublayer:divider];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.firstNameTextField.text= [defaults objectForKey:USER_FIRST_NAME];
    self.lastNameTextField.text= [defaults objectForKey:USER_LAST_NAME];
    self.cityTextField.text = [defaults objectForKey:@"user_city"];
    
    if ([[defaults objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]) {
        
        self.streetTextField.text = [defaults objectForKey:USER_STREET];
        self.cityTextField.text = [defaults objectForKey:USER_CITY];
        self.stateTextField.text = [[defaults objectForKey:USER_STATE] uppercaseString];
        self.zipcodeTextField.text = [defaults objectForKey:USER_ZIP_CODE];
        [self textFieldDidChange:self.zipcodeTextField];
    }
    
    [self.firstNameTextField becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)saveButtonTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:true];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.streetTextField.text.length > 0
        && self.cityTextField.text.length > 0
        && self.stateTextField.text.length == 2
        && self.zipcodeTextField.text.length == 5) {
        [defaults setObject:@"True" forKey:USER_ADDRESS_EXISTS];
        [defaults setObject:self.streetTextField.text forKey:USER_STREET];
        [defaults setObject:self.cityTextField.text forKey:USER_CITY];
        [defaults setObject:self.stateTextField.text forKey:USER_STATE];
        [defaults setObject:self.zipcodeTextField.text forKey:USER_ZIP_CODE];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDRESS_UPDATED object:nil];
        [self displayToastWithMessage:@"Address Sucessfully saved" backgroundColor:[UIColor globalSuccessColor]];
        
        [GlobalAPI logEventInFirebase:@"analytics_settings" descriptionFieldName:@"type" description:@"address"];
    }
    
    if (self.firstNameTextField.text.length>0 || self.lastNameTextField.text>0)
    {
        [defaults setObject:self.lastNameTextField.text forKey:USER_LAST_NAME];
        [defaults setObject:self.firstNameTextField.text forKey:USER_FIRST_NAME];
        [GlobalAPI logEventInFirebase:@"analytics_settings" descriptionFieldName:@"type" description:@"name"];
        [self displayToastWithMessage:@"First and Last Name Sucessfully saved" backgroundColor:[UIColor globalSuccessColor]];
    }
    
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

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if (range.length + range.location > textField.text.length) {
        return false;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 2;
}

- (void)textFieldDidChange:(UITextField *)textField {
    BOOL enabled = false;
    if (self.streetTextField.text.length > 0
        && self.cityTextField.text.length > 0
        && self.stateTextField.text.length == 2
        && self.zipcodeTextField.text.length == 5) {
        
        enabled = true;
    }
    
    if (textField == self.firstNameTextField || textField == self.lastNameTextField)
    {
        enabled=true;
    }
    
    
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        if (item == self.keyboardDoneButton) {
            item.enabled = enabled;
        }
    }
}

@end
