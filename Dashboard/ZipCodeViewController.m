//
//  ZipCodeViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ZipCodeViewController.h"
#import "Constant.h"
#import "UserCardView.h"

@interface ZipCodeViewController ()

@property (strong, nonatomic) IBOutlet UIView *userCardView;
@property (strong, nonatomic) IBOutlet UITextField *zipcodeTextField;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@end

@implementation ZipCodeViewController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
    self.cardView.frame = frame;
    [self.userCardView addSubview:self.cardView];
    
    // Done button on keyboard
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    UIBarButtonItem *keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(doneButtonTapped:)];
    keyboardDoneButton.enabled = false;
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:keyboardDoneButton, nil]];
    self.zipcodeTextField.inputAccessoryView = self.keyboardToolbar;
    [self.zipcodeTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_ZIP_CODE]) {
        self.zipcodeTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ZIP_CODE];
        [self textFieldDidChange:self.zipcodeTextField];
    }
    
    [self.zipcodeTextField becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)doneButtonTapped:(UITapGestureRecognizer *)sender {
    [self.zipcodeTextField resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.zipcodeTextField.text forKey:USER_ZIP_CODE];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZIP_CODE_UPDATED object:nil];
    
    [self.delegate didDismissViewController:self];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidChange:(UITextField *)textField {
    BOOL enabled = (textField.text.length == 5);
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        item.enabled = enabled;
    }
}

@end
