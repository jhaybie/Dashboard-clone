//
//  Candidate.m
//  Dashboard
//
//  Created by Jhaybie Basco on 5/26/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Candidate.h"

@implementation Candidate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // model_property_name : json_field_name
    return @{
             @"firstName"                     : @"FirstName",
             @"middleName"                    : @"MiddleName",
             @"lastName"                      : @"LastName",
             @"suffix"                        : @"Suffix",
             @"party"                         : @"Party",
             @"electionID"                    : @"ElectionId",
             @"externalID"                    : @"ExternalId",
             @"raceID"                        : @"RaceId",
             @"congressional"                 : @"Congressional",
             @"raceString"                    : @"Race",
             @"numberOfSeats"                 : @"NumSeats",
             @"county"                        : @"County",
             @"city"                          : @"City",
             @"state"                         : @"State",
             @"infoSource"                    : @"InfoSource",
             @"specialDistrictString"         : @"SpecialDistrict",
             @"stateLegislativeDistrictUpper" : @"StateLegislativeDistrictUpper",
             @"stateLegislativeDistrictLower" : @"StateLegislativeDistrictLower",
             @"isRecall"                      : @"Recall",
             @"isIncumbent"                   : @"Incumbant",
             @"isStatewide"                   : @"Statewide",
             };
}

@end
