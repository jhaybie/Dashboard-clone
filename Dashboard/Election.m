//
//  Election.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Election.h"
#import "MTLValueTransformer.h"

@implementation Election

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // model_property_name : json_field_name
    return @{
             @"officeName"             : @"OfficeName",
             @"positionName"           : @"PositionName",
             @"frequencyString"        : @"Frequency",
             @"nextYear"               : @"NextYear",
             @"numberOfSeats"          : @"NumSeats",
             @"isPrimary"              : @"Primary",
             @"primaryDate"            : @"PrimaryDate",
             @"generalDate"            : @"GeneralDate",
             @"generalDateDescription" : @"GeneralDateDesc",
             @"termLimitDescription"   : @"TermLimitDesc",
             @"termLimitYears"         : @"TermLimitYears",
             @"location"               : @"Location",
             @"state"                  : @"State",
             @"extra"                  : @"Extras",//NSNull.null, // ignore this for now
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)primaryDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)generalDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
