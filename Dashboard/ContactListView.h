//
//  ContactListView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactLineView.h"

@class Contact;

@protocol ContactListViewDelegate <NSObject>

- (void)checkBoxButtonTapped:(DBCheckboxButton *)sender;
- (void)emailButtonTapped:(id)sender;
- (void)smsButtonTapped:(id)sender;
- (void)phoneButtonTapped:(id)sender;

@end

@interface ContactListView : UIView <ContactLineViewDelegate>

@property (nonatomic, strong) id<ContactListViewDelegate>delegate;

- (instancetype)initWithContacts:(NSArray<Contact *> *)contacts;

@end
