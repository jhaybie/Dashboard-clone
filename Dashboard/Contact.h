//
//  Contact.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import Contacts;

@interface Contact : NSObject

@property (nonatomic, strong) NSString *contactID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isInvited;

/// Returns a contact object. Returns nil if contact has no home address,
/// phones, and email addresses.
- (instancetype)initWithContact:(CNContact *)contact;

@end
