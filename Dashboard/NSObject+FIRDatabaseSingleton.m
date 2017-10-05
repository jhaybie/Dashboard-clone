//
//  NSObject+FIRDatabaseSingleton.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 16/09/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "NSObject+FIRDatabaseSingleton.h"



@interface FIRDatabaseSingleton()
@end

@implementation FIRDatabaseSingleton:NSObject
static FIRDatabaseSingleton *manager = nil;


+ (FIRDatabaseSingleton *)sharedManager
{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}

+ (FIRDatabaseSingleton *)restartSharedManager
{
    manager = [[self alloc] init];
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.mainFirebaseReference=[[FIRDatabase database] reference];
        self.storageRef = [[FIRStorage storage] reference];
    }
    return self;
}

@end
