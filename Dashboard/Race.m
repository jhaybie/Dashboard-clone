//
//  Race.m
//  Dashboard
//
//  Created by Jhaybie Basco on 5/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Race.h"
#import "MTLValueTransformer.h"

@implementation Race

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // model_property_name : json_field_name
    return @{
             @"raceID"                        : @"Info.ExternalId",
             @"electionID"                    : @"Info.ElectionId",
             @"state"                         : @"Info.State",
             @"infoSource"                    : @"Info.InfoSource",
             @"county"                        : @"Info.County",
             @"city"                          : @"Info.City",
             @"specialDistrict"               : @"Info.SpecialDistrict",
             @"stateLegislativeDistrictLower" : @"Info.StateLegislativeDistrictLower",
             @"stateLegislativeDistrictUpper" : @"Info.StateLegislativeDistrictUpper",
             @"congressional"                 : @"Info.Congressional",
             @"statewide"                     : @"Info.Statewide",
             @"recall"                        : @"Info.Recall",
             @"raceName"                      : @"Info.Race",
             @"numberOfSeats"                 : @"Info.NumSeats",
             
             //@"candidates"                    : @"Candidatates"
             };
}

#pragma mark - JSON Transformers

//+ (NSValueTransformer *)candidatesJSONTransformer {
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[NSNull class]];
//}

@end
