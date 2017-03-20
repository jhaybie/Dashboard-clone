//
//  GlobalAPI.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "GlobalAPI.h"
#import "AFNetworking.h"
#import "Constant.h"
#import "Contact.h"
#import "Person.h"

@import Contacts;

@implementation GlobalAPI

+ (NSString *)apiKey {
    return [NSString stringWithFormat:@"Bearer %@", API_KEY];
}

+ (void)getAddressBookValidContactsSuccess:(void (^)(NSArray<Contact *> *contacts))success
                                   failure:(void (^)(NSString *message))failure {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:CONTACTS_IMPORTED] isEqualToString:@"False"]) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
            [GlobalAPI presentAddressBookErrorDialog];
            failure(@"Permissions");
        }
        
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            // make sure the user granted us access
            
            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GlobalAPI presentAddressBookErrorDialog];
                    failure(@"Permissions");
                });
                return;
            }
            
            NSMutableArray *contacts = [NSMutableArray array];
            
            NSError *fetchError;
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[
                                                                                                  CNContactIdentifierKey,
                                                                                                  CNContactPhoneNumbersKey,
                                                                                                  CNContactPostalAddressesKey,
                                                                                                  CNContactEmailAddressesKey,
                                                                                                  CNContactBirthdayKey,
                                                                                                  CNContactImageDataAvailableKey,
                                                                                                  CNContactImageDataKey,
                                                                                                  [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]
                                                                                                  ]];
            
            BOOL fetched = [store enumerateContactsWithFetchRequest:request
                                                              error:&fetchError
                                                         usingBlock:^(CNContact *contact, BOOL *stop) {
                                                             if (contact.phoneNumbers.count > 0
                                                                 || contact.emailAddresses.count > 0
                                                                 || contact.postalAddresses.count > 0) {
                                                                 
                                                                 [contacts addObject:contact];
                                                             }
                                                         }];
            if (!fetched) {
                failure(fetchError.description);
                [defaults setObject:@[] forKey:ALL_CONTACTS];
            }
            
            NSMutableArray<Contact *> *filteredContacts = [[NSMutableArray alloc] init];
            
            for (CNContact *contact in contacts) {
                Contact *cleanedContact = [[Contact alloc] initWithContact:contact];
                if (cleanedContact) {
                    [filteredContacts addObject:cleanedContact];
                }
            }
            [defaults setObject:@"True" forKey:CONTACTS_IMPORTED];
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:filteredContacts] forKey:ALL_CONTACTS];
            success([[NSArray alloc] initWithArray:filteredContacts]);
        }];
    } else {
        NSData *data = [defaults objectForKey:ALL_CONTACTS];
        NSArray<Contact *> *allContacts = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        success(allContacts);
    }
}

+ (void)getElections:(void (^)(NSArray<Election *> *elections))success
             failure:(void (^)(NSInteger statusCode))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/election", BASE_URL];
    
    NSString *token = [self apiKey];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSError *error = nil;
             NSDictionary *dict = [responseObject objectForKey:@"people"];
             Person *person = [MTLJSONAdapter modelOfClass:[Person class]
                                        fromJSONDictionary:dict
                                                     error:&error];
             success(person.elections);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             failure(response.statusCode);
         }];
    
}

+ (void)saveContacts:(NSArray<Contact *> *)contacts {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"True" forKey:CONTACTS_IMPORTED];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:contacts] forKey:ALL_CONTACTS];
}

#pragma mark - AddressBook UIAlertController Dialog Method

+ (void)presentAddressBookErrorDialog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                   message:@"Dashboard requires access to your Address Book."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Go to Settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                   options:@{}
                                                                         completionHandler:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                     animated:true
                                                                                   completion:nil];
}

@end
