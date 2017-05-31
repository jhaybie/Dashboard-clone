//
//  GlobalAPI.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <Foundation/Foundation.h>

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

+ (void)presentAddressBookErrorDialog;

+ (void)saveContacts:(NSArray<Contact *> *)contacts;

+ (NSMutableArray<Election *> *)sortElections:(NSMutableArray<Election *> *)elections;

@end
