//
//  ContactListView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ContactListView.h"
#import "Contact.h"
#import "ContactLineView.h"

@implementation ContactListView

#pragma mark - Init Methods

- (instancetype)initWithContacts:(NSArray<Contact *> *)contacts {
    int width = [[UIScreen mainScreen] bounds].size.width - 48;
    int height = 0;
    CGRect frame = CGRectMake(0, 0, width, 40 * contacts.count);
    
    if (self = [super initWithFrame:frame]) {
        for (int i = 0; i < contacts.count; i++) {
            Contact *contact = contacts[i];
            ContactLineView *clv = [[ContactLineView alloc] initWithContact:contact index:i];
            CGRect frame = CGRectMake(0, height, width, 40);
            clv.frame = frame;
            height += 40;
            clv.delegate = self;
            [self addSubview:clv];
        }
        
        self.frame = CGRectMake(0, 0, width, height);
    }
    return self;
}

#pragma mark - ContactLineView Delegate Methods

- (void)checkBoxButtonTapped:(DBCheckboxButton *)sender {
    [self.delegate checkBoxButtonTapped:sender];
}

- (void)emailButtonTapped:(id)sender {
    [self.delegate emailButtonTapped:sender];
}

- (void)smsButtonTapped:(id)sender {
    [self.delegate smsButtonTapped:sender];
}

- (void)phoneButtonTapped:(id)sender {
    [self.delegate phoneButtonTapped:sender];
}

@end
