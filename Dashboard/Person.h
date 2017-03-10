//
//  Person.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class Election;

@interface Person : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *previous;
@property (nonatomic, strong) NSString *next;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSArray <Election *> *elections;

@end
