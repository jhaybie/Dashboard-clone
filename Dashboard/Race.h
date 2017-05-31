//
//  Race.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class Candidate;

@interface Race : MTLModel <MTLJSONSerializing>

@property (nonatomic) int raceID;
@property (nonatomic) int electionID;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *infoSource;
@property (nonatomic, strong) NSString *county;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *specialDistrict;
@property (nonatomic) NSString *stateLegislativeDistrictLower;
@property (nonatomic) NSString *stateLegislativeDistrictUpper;
@property (nonatomic) int congressional;
@property (nonatomic) BOOL statewide;
@property (nonatomic) BOOL recall;
@property (nonatomic, strong) NSString *raceName;
@property (nonatomic) int numberOfSeats;
@property (nonatomic, strong) NSArray<Candidate *> *candidates;

@property (nonatomic) BOOL isConfirmed;

@end
