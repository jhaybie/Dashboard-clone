//
//  Candidate.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/26/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface Candidate : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *suffix;

@property (nonatomic, strong) NSString *party;

@property (nonatomic) int electionID;
@property (nonatomic) int externalID;
@property (nonatomic) int raceID;
@property (nonatomic) int congressional;

@property (nonatomic, strong) NSString *raceString;
@property (nonatomic) int numberOfSeats;

@property (nonatomic, strong) NSString *county;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *infoSource;

@property (nonatomic, strong) NSString *specialDistrictString;
@property (nonatomic, strong) NSString *stateLegislativeDistrictUpper;
@property (nonatomic, strong) NSString *stateLegislativeDistrictLower;

@property (nonatomic) BOOL isRecall;
@property (nonatomic) BOOL isIncumbent;
@property (nonatomic) BOOL isStatewide;



@end
