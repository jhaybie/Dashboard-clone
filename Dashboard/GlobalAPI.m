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

+ (NSString *)authToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:AUTH_TOKEN];
    if (token.length > 0) {
        return [NSString stringWithFormat:@"Bearer %@", token];
    } else {
        return [self apiKey];
    }
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
                                                                 //&& contact.emailAddresses.count > 0
                                                                 && contact.postalAddresses.count > 0) {
                                                                 
                                                                 for (int i = 0; i < contact.postalAddresses.count; i++) {
                                                                     CNLabeledValue *address = contact.postalAddresses[i];
                                                                     if (address.label == CNLabelHome) {
                                                                         [contacts addObject:contact];
                                                                         break;
                                                                     }
                                                                 }
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *street = [prefs objectForKey:USER_STREET];
    NSString *city = [prefs objectForKey:USER_CITY];
    NSString *state = [prefs objectForKey:USER_STATE];
    NSString *zip = [prefs objectForKey:USER_ZIP_CODE];
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@ %@", street, city, state, zip];
    addressString = [addressString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/election?search_type=address&address=%@", BASE_URL, addressString];
    
    NSString *token = [self authToken];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    NSMutableIndexSet* codes = [[NSMutableIndexSet alloc] init];
//    [codes addIndex:200];
//    [codes addIndex:500];
//    [codes addIndex:400];
//    manager.responseSerializer.acceptableStatusCodes = codes;

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
                 
                 NSMutableArray *elections = [[NSMutableArray alloc] init];
                 for (NSDictionary *electionDict in tempElections) {
                     NSError *error = nil;
                     Election *election = [MTLJSONAdapter modelOfClass:[Election class]
                                                    fromJSONDictionary:electionDict
                                                                 error:&error];
                     [elections addObject:election];
                 }
                 
                 for (Election *election in elections) {
                     for (Race *race in election.races) {
                         race.isConfirmed = election.isComplete;
                     }
                 }
                 
                 NSMutableArray *results = [GlobalAPI sortElections:elections];
                 success(results);
             }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 404) {
            success([[NSArray alloc] init]);
        } else {
            failure(response.statusCode);
        }
    }];
}

+ (void)getElectionsForContact:(Contact *)contact
                       success:(void (^)(NSArray<Election *> *elections))success
                       failure:(void (^)(NSInteger statusCode))failure {
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@ %@", contact.street, contact.city, contact.state, contact.zip];
    addressString = [addressString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    addressString = [addressString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%20"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/election?search_type=address&address=%@", BASE_URL, addressString];
    
    NSString *token = [self authToken];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"%@", urlString);
    
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
                  
                  NSMutableArray *elections = [[NSMutableArray alloc] init];
                  for (NSDictionary *electionDict in tempElections) {
                      NSError *error = nil;
                      Election *election = [MTLJSONAdapter modelOfClass:[Election class]
                                                     fromJSONDictionary:electionDict
                                                                  error:&error];
                      [elections addObject:election];
                  }
                  
                  for (Election *election in elections) {
                      for (Race *race in election.races) {
                          race.isConfirmed = election.isComplete;
                      }
                  }
                  
                  NSMutableArray *results = [GlobalAPI sortElections:elections];
                  success(results);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              failure(response.statusCode);
          }];
}

+ (void)getRandomElectionsSuccess:(void (^)(NSArray<Election *> *elections))success
                          failure:(void (^)(NSInteger statusCode))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/random", BASE_URL];
    
    NSString *token = [self authToken];
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
             
             for (Election *election in elections) {
                 for (Race *race in election.races) {
                     race.isConfirmed = election.isComplete;
                 }
             }
             
             NSMutableArray *results = [GlobalAPI sortElections:elections];
             success(results);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             failure(response.statusCode);
         }];
}

+ (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
               success:(void (^)(void))success
               failure:(void (^)(NSString *message))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/login?grant_type=password&username=%@&password=%@&client_id=%@&client_secret=%@", AUTH_URL, email, password, CLIENT_ID, CLIENT_SECRET];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:urlString
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"Successful!");
              NSDictionary *sessionDict = responseObject;
              
              if ([[sessionDict objectForKey:@"error"] isEqualToString:@"access_denied"]) {
                  failure(@"Invalid username or password");
              } else {
                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                  NSString *authToken = [sessionDict objectForKey:@"access_token"];
                  NSString *refreshToken = [sessionDict objectForKey:@"refresh_token"];
                  
                  [prefs setObject:@"YES" forKey:IS_SESSION_ACTIVE];
                  [prefs setObject:authToken forKey:AUTH_TOKEN];
                  [prefs setObject:refreshToken forKey:REFRESH_TOKEN];
                  success();
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              failure(@"Error connecting to server");
          }];
}

+ (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                  success:(void (^)(void))success
                  failure:(void (^)(NSString *message))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/register?username=%@&password=%@&client_id=%@&client_secret=%@/", AUTH_URL, email, password, CLIENT_ID, CLIENT_SECRET];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:urlString
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [GlobalAPI loginWithEmail:email
                               password:password
                                success:^{
                                    success();
                                } failure:^(NSString *message) {
                                    failure(@"There was an error registering your account");
                                }];
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              if (response.statusCode == 400) {
                  failure(@"This email is already registered");
              } else {
                  failure(@"There was an error registering your account");
              }
          }];
}

+ (void)registerWithFacebookEmail:(NSString *)email
                           userID:(NSString *)userID
                  success:(void (^)(void))success
                  failure:(void (^)(NSString *message))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/register?username=%@&password=%@&client_id=%@&client_secret=%@/", AUTH_URL, email, userID, CLIENT_ID, CLIENT_SECRET];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:urlString
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [GlobalAPI loginWithEmail:email
                               password:userID
                                success:^{
                                    success();
                                } failure:^(NSString *message) {
                                    failure(@"There was an error registering your account");
                                }];
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              if (response.statusCode == 400) {
                  [GlobalAPI loginWithEmail:email
                                   password:userID
                                    success:^{
                                        success();
                                    } failure:^(NSString *message) {
                                        failure(@"There was an error registering your account");
                                    }];
              } else {
                  failure(@"There was an error registering your account");
              }
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

+ (NSMutableArray<Election *> *)sortElections:(NSMutableArray<Election *> *)elections {
    NSArray *sortedCollection = [elections sortedArrayUsingComparator:^NSComparisonResult(Election *option1, Election *option2) {
        return [option2.electionDate compare:option1.electionDate];
    }];
    return [[NSMutableArray alloc] initWithArray:sortedCollection];
}

@end
