//
//  NSObject+FIRDatabaseSingleton.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 16/09/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import Firebase;


@interface FIRDatabaseSingleton:NSObject


+ (id)sharedManager;
+ (id)restartSharedManager;
- (id)init;
@property (strong, nonatomic) FIRDatabaseReference *mainFirebaseReference;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@end
