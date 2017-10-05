//
//  GlobalAPI.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stripe.h"
#import "NSObject+FIRDatabaseSingleton.h"
@import FBSDKCoreKit;
@import FBSDKLoginKit;

@class Contact;
@class Election;

@interface GlobalAPI : NSObject

+ (void)getAddressBookValidContactsForced:(BOOL)forced
                                  success:(void (^)(NSArray<Contact *> *contacts))success
                                  failure:(void (^)(NSString *message))failure;

+ (void)getElections:(void (^)(NSArray<Election *> *elections))success
             failure:(void (^)(NSInteger statusCode))failure;

+ (void)getElectionsForContact:(Contact *)contact
                       success:(void (^)(NSArray<Election *> *elections))success
                       failure:(void (^)(NSInteger statusCode))failure;

+ (void)getRandomElectionsSuccess:(void (^)(NSArray<Election *> *elections))success
                          failure:(void (^)(NSInteger statusCode))failure;

+ (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
               success:(void (^)(void))success
               failure:(void (^)(NSString *message))failure;

+ (void)presentAddressBookErrorDialog;

+ (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                  success:(void (^)(void))success
                  failure:(void (^)(NSString *message))failure;

+ (void)registerWithFacebookEmail:(NSString *)email
                           userID:(NSString *)userID
                          success:(void (^)(void))success
                          failure:(void (^)(NSString *message))failure;

+ (void)saveContacts:(NSArray<Contact *> *)contacts;

+ (NSMutableArray<Election *> *)sortElections:(NSMutableArray<Election *> *)elections;

+ (void)registerWithFirebase:(NSString*)email andPassword:(NSString*)password;
+ (void)registerWithFirebaseViaFacebook:(NSString*)email;
+ (void)registerThisProfileToFirebase:(NSDictionary*)profileDictionary;
+ (void)updateProfileInFirebase:(NSDictionary*)profileDictionary;
+ (void)logEventInFirebase:(NSString*)event descriptionFieldName:(NSString*)descriptionName description:(NSString*)description;


@end


@interface StripeAPIClient :NSObject<STPEphemeralKeyProvider>
+ (StripeAPIClient *) sharedClient;
-(void)completeCharge:(STPPaymentResult*)_result amount:(NSInteger)amount shippingAddress: (STPAddress*) shippingAddres shippingMethod: (PKShippingMethod*) shippingMethod completion:(void (^)(void))completion;

-(void)submitTokenToBackend:(STPToken*)token completion:(void (^)(void))completion;
-(void)createPaymentChargeUsingSourceAndParams:(STPSource*)source amount:(NSInteger)amount completion:(void (^)(void))completion;

@end

