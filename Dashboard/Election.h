//
//  Election.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface Election : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *officeName;
@property (nonatomic, strong) NSString *positionName;
@property (nonatomic, strong) NSString *frequencyString;
@property (nonatomic) NSInteger nextYear;
@property (nonatomic) NSInteger numberOfSeats;
@property (nonatomic) BOOL isPrimary;
@property (nonatomic, strong) NSDate *primaryDate;
@property (nonatomic, strong) NSDate *generalDate;
@property (nonatomic, strong) NSString *generalDateDescription;
@property (nonatomic, strong) NSString *termLimitDescription;
@property (nonatomic) NSInteger termLimitYears;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) id extra;

// Where are the candidate names?

@end
