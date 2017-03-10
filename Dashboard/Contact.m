//
//  Contact.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Contact.h"

@implementation Contact

#pragma mark - Init Methods

- (instancetype)initWithContact:(CNContact *)contact {
    self = [super init];
    if (self) {
        self.firstName = contact.givenName;
        self.lastName = contact.familyName;
        
        self.street = @"";
        self.city = @"";
        self.state = @"";
        self.zip = @"";
        
        self.contactID = contact.identifier;
        
        for (int i = 0; i < contact.postalAddresses.count; i++) {
            CNLabeledValue *address = contact.postalAddresses[i];
            if (address.label == CNLabelHome) {
                NSArray *addresses = (NSArray*)[contact.postalAddresses valueForKey:@"value"];
                CNPostalAddress *homeAddress = addresses[i];
                self.street = homeAddress.street;
                self.city = homeAddress.city;
                self.state = homeAddress.state;
                self.zip = homeAddress.postalCode;

            }
        }
        
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

        self.phone = @"";
        for (CNLabeledValue *number in contact.phoneNumbers) {
            if (number.label == CNLabelPhoneNumberMain) {
                NSString *phoneString = [(CNPhoneNumber *)(number.value) stringValue];
                NSString *cleanedPhoneString = [[phoneString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
                self.phone = cleanedPhoneString;
            }
        }
        
        self.mobile = @"";
        for (CNLabeledValue *number in contact.phoneNumbers) {
            if (number.label == CNLabelPhoneNumberMobile || number.label == CNLabelPhoneNumberiPhone) {
                NSString *phoneString = [(CNPhoneNumber *)(number.value) stringValue];
                 NSString *cleanedPhoneString = [[phoneString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
                self.mobile = cleanedPhoneString;
                self.phone = cleanedPhoneString; // Replace landline if mobile number is found
            }
        }
        
        self.email = @"";
        for (CNLabeledValue *email in contact.emailAddresses) {
            NSString *emailString = email.value;
            self.email = emailString;
            break; // Getting the first email in the list -- FOR NOW
        }
        
    }
    if ((self.firstName.length == 0 && self.lastName.length == 0)
        || (self.city.length == 0 && self.state.length == 0 && self.zip.length == 0
        && self.phone.length == 0
        && self.mobile.length == 0
        && self.email.length == 0)) {
        return nil;
    } else {
        return self;
    }
}

@end
