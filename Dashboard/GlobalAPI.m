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
#import "Election.h"
#import "Race.h"

@import Contacts;

@implementation GlobalAPI

+ (NSString *)apiKey {
    return [NSString stringWithFormat:@"Bearer %@", API_KEY];
}

+ (void)getAddressBookValidContactsForced:(BOOL)forced
                                  success:(void (^)(NSArray<Contact *> *contacts))success
                                  failure:(void (^)(NSString *message))failure {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:CONTACTS_IMPORTED] isEqualToString:@"False"] || forced) {
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
                                                                                                  CNContactThumbnailImageDataKey,
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
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDict = [[NSMutableDictionary alloc] init];
    
    if ([[prefs objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]) {
        paramDict = @{
                      @"search_type" : @"zip",
                      @"zip5"        : [prefs objectForKey:USER_ZIP_CODE],
                      @"zip4"        : @"",
                      @"state"       : [prefs objectForKey:USER_STATE],
                      };
    } else {
        paramDict = @{
                          @"search_type" : @"zip",
                          @"zip5"        : @"29851",
                          @"zip4"        : @"3162",
                          @"state"       : @"SC",
                          };
    }

    
    [manager POST:urlString
       parameters:paramDict
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *dataDumpDict = [responseObject objectForKey:@"Elections"];
              NSArray *tempElections = [[NSArray alloc] initWithArray:[dataDumpDict objectForKey:@"Elections"]];
              
              if ([tempElections isKindOfClass:[NSNull class]]) {
                  tempElections = [[NSArray alloc] init];
              }
              
              // TODO: specify class contained within elections
              NSMutableArray *elections = [[NSMutableArray alloc] init];
              for (NSDictionary *electionDict in tempElections) {
                  NSError *error = nil;
                  Election *election = [MTLJSONAdapter modelOfClass:[Election class]
                                                 fromJSONDictionary:electionDict
                                                              error:&error];
                  [elections addObject:election];
              }
              success(elections);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              failure(response.statusCode);
          }];
}

+ (void)getElectionsForContact:(Contact *)contact
                       success:(void (^)(NSArray<Election *> *elections))success
                       failure:(void (^)(NSInteger statusCode))failure {
    
    NSString *addressString = [NSString stringWithFormat:@"%@, %@ %@", contact.street, contact.city, contact.state];
    addressString = [addressString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/election?search_type=address&address=%@", BASE_URL, addressString];
    
    NSString *token = [self apiKey];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *dataDumpDict = [responseObject objectForKey:@"Elections"];
              
              if ([[dataDumpDict objectForKey:@"Elections"] isKindOfClass:[NSNull class]]) {
                  success([[NSArray alloc] init]);
              } else {
                  NSArray *tempElections = [[NSArray alloc] initWithArray:[dataDumpDict objectForKey:@"Elections"]];
                  
                  if ([tempElections isKindOfClass:[NSNull class]]) {
                      tempElections = [[NSArray alloc] init];
                  }
                  
                  // TODO: specify class contained within elections
                  NSMutableArray *elections = [[NSMutableArray alloc] init];
                  for (NSDictionary *electionDict in tempElections) {
                      NSError *error = nil;
                      Election *election = [MTLJSONAdapter modelOfClass:[Election class]
                                                     fromJSONDictionary:electionDict
                                                                  error:&error];
                      [elections addObject:election];
                  }
                  success(elections);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              failure(response.statusCode);
          }];
}

+ (void)getRandomElectionsSuccess:(void (^)(NSArray<Election *> *elections))success
                          failure:(void (^)(NSInteger statusCode))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/random", BASE_URL];
    
    NSString *token = [self apiKey];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *dataDumpDict = [responseObject objectForKey:@"Elections"];
             NSArray *tempElections = [[NSArray alloc] initWithArray:[dataDumpDict objectForKey:@"Elections"]];
             
             if ([tempElections isKindOfClass:[NSNull class]]) {
                 tempElections = [[NSArray alloc] init];
             }
             
             // TODO: specify class contained within elections
             NSMutableArray *elections = [[NSMutableArray alloc] init];
             for (NSDictionary *electionDict in tempElections) {
                 NSError *error = nil;
                 Election *election = [MTLJSONAdapter modelOfClass:[Election class]
                                                fromJSONDictionary:electionDict
                                                             error:&error];
                 [elections addObject:election];
             }
             success(elections);
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
