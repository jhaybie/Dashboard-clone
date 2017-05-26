//
//  Election.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class Race;

@interface Election : MTLModel <MTLJSONSerializing>

@property (nonatomic) int electionID;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *electionName;
@property (nonatomic, strong) NSDate *electionDate;

@property (nonatomic, strong) id electionMonthDateOnly;

@property (nonatomic) BOOL isPrimary;
@property (nonatomic) BOOL isCounty;
@property (nonatomic) BOOL isLower;
@property (nonatomic) BOOL isUpper;
@property (nonatomic) BOOL isCongress;
@property (nonatomic) BOOL isStatewide;
@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isComplete;
@property (nonatomic) BOOL isAllMail;
@property (nonatomic, strong) NSString *voterRegURLString;
@property (nonatomic, strong) NSString *electionDateTimesString;
@property (nonatomic, strong) NSString *pollingPlaceURLString;
@property (nonatomic, strong) NSString *earlyVotinDatesString;
@property (nonatomic, strong) NSString *earlyVotingTimesString;
@property (nonatomic, strong) NSString *earlyVotingURLString;
@property (nonatomic, strong) NSString *absenteeVotingURLString;
@property (nonatomic, strong) NSString *absenteeVotingDeadlines;

@property (nonatomic, strong) NSArray<Race *> *races;

@end
