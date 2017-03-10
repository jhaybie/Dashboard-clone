//
//  Person.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Person.h"
#import "Election.h"
#import "MTLValueTransformer.h"

@implementation Person

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // model_property_name : json_field_name
    return @{
             @"previous"  : @"Prev",
             @"next"      : @"Next",
             @"token"     : @"Token",
             @"elections" : @"Elections",
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)electionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[Election class]];
}

@end
