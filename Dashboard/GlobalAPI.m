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
        ///*
        
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
            
            
            NSMutableArray<Contact *> *filteredContacts = [[NSMutableArray alloc] init];
            
            BOOL fetched = [store enumerateContactsWithFetchRequest:request
                                                              error:&fetchError
                                                         usingBlock:^(CNContact *contact, BOOL *stop) {
                                                             if (contact.phoneNumbers.count > 0
                                                                 
                                                                 && contact.postalAddresses.count > 0) {
                                                                 
                                                                 
                                                                 for (int i = 0; i < contact.postalAddresses.count; i++) {
                                                                     CNLabeledValue *address = contact.postalAddresses[i];
                                                                     if (address.label == CNLabelHome|| [address.label isEqualToString:@"_$!<Home>!$_"]) {
                                                                         Contact *cleanedContact = [[Contact alloc] initWithContact:contact];
                                                                         if (cleanedContact)
                                                                             [filteredContacts addObject:cleanedContact];
                                                                         break;
                                                                     }
                                                                 }
                                                             }
                                                         }];
            if (!fetched) {
                failure(fetchError.description);
                [defaults setObject:@[] forKey:ALL_CONTACTS];
            }
            
            
            
            [defaults setObject:@"True" forKey:CONTACTS_IMPORTED];
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:filteredContacts] forKey:ALL_CONTACTS];
            success([[NSArray alloc] initWithArray:filteredContacts]);
            
        }];
        //*/
    } else {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusAuthorized) {
            NSData *data = [defaults objectForKey:ALL_CONTACTS];
            NSArray<Contact *> *allContacts = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
            success(allContacts);
        } else {
            failure(@"Permissions");
        }
        
    }}

+ (void)getElections:(void (^)(NSArray<Election *> *elections))success
             failure:(void (^)(NSInteger statusCode))failure {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *street = [prefs objectForKey:USER_STREET];
    NSString *city = [prefs objectForKey:USER_CITY];
    NSString *state = [prefs objectForKey:USER_STATE];
    NSString *zip = [prefs objectForKey:USER_ZIP_CODE];
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@ %@ USA", street, city, state, zip];
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
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@ %@ USA", contact.street, contact.city, contact.state, contact.zip];
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
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/login?grant_type=password&username=%@&password=%@&client_id=%@&client_secret=%@", AUTH_URL, email, password, CLIENT_ID, CLIENT_SECRET];
    
    //curl -X POST "https://auth-dot-rise-team-tool-qa.appspot.com/login" -d "grant_type=password&username=info@apps.newfounders.us&client_id=123456&client_secret=secret123456&password=garbage”
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/login", AUTH_URL];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            email, @"username",
                            CLIENT_ID, @"client_id",
                            CLIENT_SECRET, @"client_secret",
                            password, @"password",
                            nil];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString
       parameters:params
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
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/register?username=%@&password=%@&client_id=%@&client_secret=%@/", AUTH_URL, email, password, CLIENT_ID, CLIENT_SECRET];

    
    //curl -X POST "https://auth-dot-rise-team-tool-qa.appspot.com/register" -d "username=founder1%40test.com&password=testpass&client_id=123456&client_secret=secret123456"
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/register", AUTH_URL];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"username",
                            password, @"password",
                            CLIENT_ID, @"client_id",
                            CLIENT_SECRET, @"client_secret",
                            nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString
       parameters:params
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
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/register?username=%@&password=%@&client_id=%@&client_secret=%@/", AUTH_URL, email, userID, CLIENT_ID, CLIENT_SECRET];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/register", AUTH_URL];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"username",
                            @"12345678", @"password",
                            CLIENT_ID, @"client_id",
                            CLIENT_SECRET, @"client_secret",
                            nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success();
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
              if (response.statusCode == 400) {
                failure(@"There was an error registering your account");
              }
              else {
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
    /*
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
    */
}

+ (NSMutableArray<Election *> *)sortElections:(NSMutableArray<Election *> *)elections {
    NSArray *sortedCollection = [elections sortedArrayUsingComparator:^NSComparisonResult(Election *option1, Election *option2) {
        return [option2.electionDate compare:option1.electionDate];
    }];
    return [[NSMutableArray alloc] initWithArray:sortedCollection];
}

#pragma mark - Private Firebase
+ (void)registerWithFirebase:(NSString*)email andPassword:(NSString*)password
{
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 if (error) {
                                     NSLog(@"%@ created", error.localizedDescription);
                                     return;
                                 }
                                 NSLog(@"%@ created", user.email);
                             }];
    
}
+ (void)registerWithFirebaseViaFacebook:(NSString*)email
{
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
    
    // This will register user in Authentication Table of Firebase
    if ([FIRAuth auth].currentUser) {
        [[FIRAuth auth]
         .currentUser linkWithCredential:credential
         completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
             NSLog(@"Account already linked");
         }];
    } else {
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      NSLog(@"Account Created");
                                  }];
    }
}

+ (void)registerThisProfileToFirebase:(NSDictionary*)profileDictionary
{
    if ([FIRAuth auth].currentUser.uid==nil)return;
    
    //This will save user profile in Users table of Firebase
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"users"]  child:[FIRAuth auth].currentUser.uid]
     observeSingleEventOfType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if (![snapshot exists]) {
             
             // create buyer profile using facebook profile
             [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"users"] child:[FIRAuth auth].currentUser.uid]
              setValue:@{
                         @"firstName" : profileDictionary[@"first_name"],
                         @"lastName" : profileDictionary[@"last_name"],
                         SMS_COUNTER: [NSNumber numberWithInteger:0],
                         EMAIL_COUNTER: [NSNumber numberWithInteger:0],
                         CALL_COUNTER: [NSNumber numberWithInteger:0]
                         }];
             
         } else {
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             NSString *count_str= snapshot.value[CALL_COUNTER];
             ;
             [defaults setObject:[NSNumber numberWithInt:[count_str intValue]] forKey:CALL_COUNTER];
             count_str = snapshot.value[SMS_COUNTER];
             [defaults setObject:[NSNumber numberWithInt:[count_str intValue]] forKey:SMS_COUNTER];
             count_str = snapshot.value[EMAIL_COUNTER];
             [defaults setObject:[NSNumber numberWithInt:[count_str intValue]] forKey:EMAIL_COUNTER];
             
             
         }
     }];
    
}
+ (void)updateProfileInFirebase:(NSDictionary*)profileDictionary
{
    if ([FIRAuth auth].currentUser.uid==nil)return;
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"users"] child:[FIRAuth auth].currentUser.uid]
     updateChildValues:profileDictionary];
}

+ (void)logEventInFirebase:(NSString*)event descriptionFieldName:(NSString*)descriptionName description:(NSString*)description
{
    if ([FIRAuth auth].currentUser.uid==nil)return;
    NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:event] childByAutoId].key;
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:event] child:key]
     updateChildValues:@{@"userid":[FIRAuth auth].currentUser.uid,
                         @"datetime": [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterShortStyle],
                         descriptionName: description
                         }];
}


@end


@implementation StripeAPIClient:NSObject

static StripeAPIClient *sharedClient = nil;

+ (StripeAPIClient *) sharedClient
{
    if (sharedClient == nil)
    {
        sharedClient = [[self alloc]init];
    }
    return sharedClient;
}
/*
 -(void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion
 {
 NSString *urlString = [NSString stringWithFormat:@"%@/keys?api_version=%@", DONATE_URL, apiVersion];
 NSString *Bearer=[[NSUserDefaults standardUserDefaults] objectForKey:AUTH_TOKEN];
 
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
 [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",Bearer] forHTTPHeaderField:@"Authorization"];
 
 [manager GET:urlString
 parameters:nil
 progress:nil
 success:^(NSURLSessionDataTask *task, id responseObject) {
 completion(responseObject, nil);
 } failure:^(NSURLSessionDataTask *task, NSError *error) {
 completion(nil, error);
 }];
 }
 */

- (void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion {
    
    NSURL *url = [[NSURL URLWithString:HEROKU_BASE_URL] URLByAppendingPathComponent:@"ephemeral_keys"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    [manager POST:url.absoluteString
       parameters:@{@"api_version": STRIPE_VERSION}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              completion(responseObject, nil);
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              completion(nil, error);
          }];
}


-(void)completeCharge:(STPPaymentResult*)_result amount:(NSInteger)amount shippingAddress: (STPAddress*) shippingAddres shippingMethod: (PKShippingMethod*) shippingMethod completion:(void (^)(void))completion {
    NSURL *url = [[NSURL URLWithString:HEROKU_BASE_URL] URLByAppendingPathComponent:@"charge"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url.absoluteString
       parameters:@{@"source": _result.source.stripeID, @"amount":[NSNumber numberWithInteger:amount]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              completion();
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              completion();
          }];
    
}

-(void)submitTokenToBackend:(STPToken*)token completion:(void (^)(void))completion {
    NSURL *url = [[NSURL URLWithString:HEROKU_BASE_URL] URLByAppendingPathComponent:@"charge"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url.absoluteString
       parameters:@{@"source": token.tokenId,@"amount":[NSNumber numberWithInteger:123456]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              completion();
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              completion();
          }];
    
}

-(void)createPaymentChargeUsingSourceAndParams:(STPSource*)source amount:(NSInteger)amount completion:(void (^)(void))completion {
    NSURL *url = [[NSURL URLWithString:HEROKU_BASE_URL] URLByAppendingPathComponent:@"charge"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url.absoluteString
       parameters:@{@"source": source.stripeID, @"amount":[NSNumber numberWithInteger:amount]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              completion();
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              completion();
          }];
    
}

@end
