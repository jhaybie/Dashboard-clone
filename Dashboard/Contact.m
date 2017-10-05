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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.contactID forKey:@"ContactID"];
    
    [aCoder encodeObject:self.firstName forKey:@"FirstName"];
    [aCoder encodeObject:self.lastName forKey:@"LastName"];
    [aCoder encodeObject:self.street forKey:@"Street"];
    [aCoder encodeObject:self.city forKey:@"City"];
    [aCoder encodeObject:self.state forKey:@"State"];
    [aCoder encodeObject:self.zip forKey:@"Zip"];
    
    [aCoder encodeObject:self.phone forKey:@"Phone"];
    [aCoder encodeObject:self.mobile forKey:@"Mobile"];
    [aCoder encodeObject:self.email forKey:@"Email"];
    [aCoder encodeObject:self.profileImage forKey:@"ProfileImage"];
    
    [aCoder encodeBool:self.isSelected forKey:@"IsSelected"];
    [aCoder encodeBool:self.isInvited forKey:@"IsInvited"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _contactID = [aDecoder decodeObjectForKey:@"ContactID"];
        
        _firstName = [aDecoder decodeObjectForKey:@"FirstName"];
        _lastName = [aDecoder decodeObjectForKey:@"LastName"];
        _street = [aDecoder decodeObjectForKey:@"Street"];
        _city = [aDecoder decodeObjectForKey:@"City"];
        _state = [aDecoder decodeObjectForKey:@"State"];
        _zip = [aDecoder decodeObjectForKey:@"Zip"];
        
        _phone = [aDecoder decodeObjectForKey:@"Phone"];
        _mobile = [aDecoder decodeObjectForKey:@"Mobile"];
        _email = [aDecoder decodeObjectForKey:@"Email"];
        _profileImage = [aDecoder decodeObjectForKey:@"ProfileImage"];
        
        _isSelected = [aDecoder decodeBoolForKey:@"IsSelected"];
        _isInvited = [aDecoder decodeBoolForKey:@"IsInvited"];
    }
    return self;
}

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
        if (contact.imageDataAvailable) {
            self.profileImage = [UIImage imageWithData:contact.thumbnailImageData];
        }
        
        for (int i = 0; i < contact.postalAddresses.count; i++) {
            CNLabeledValue *address = contact.postalAddresses[i];
            if (address.label == CNLabelHome || [address.label isEqualToString:@"_$!<Home>!$_"]) {
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
            if (number.label == CNLabelPhoneNumberMain || [number.label isEqualToString:@"_$!<Home>!$_"]) {
                NSString *phoneString = [(CNPhoneNumber *)(number.value) stringValue];
                NSString *cleanedPhoneString = [[phoneString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
                self.phone = cleanedPhoneString;
                break;
            }
        }
        
        self.mobile = @"";
        for (CNLabeledValue *number in contact.phoneNumbers) {
            if (number.label == CNLabelPhoneNumberMobile || number.label == CNLabelPhoneNumberiPhone|| [number.label isEqualToString:@"_$!<Mobile>!$_"]|| [number.label isEqualToString:@"_$!<iPhone>!$_"]) {
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
        
        self.isSelected = false;
        self.isInvited = false;
    }
    
    if (     (self.city.length == 0 ) ||
        self.phone.length == 0
        || self.mobile.length == 0
        || self.email.length == 0)    {
        
        return nil;
    } else {
        return self;
    }
    
}

@end

