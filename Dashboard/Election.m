//
//  Election.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "Election.h"
#import "MTLValueTransformer.h"
#import "Race.h"

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
             @"electionID"              : @"Info.ExternalId",
             @"state"                   : @"Info.State",
             @"electionName"            : @"Info.Name",
             @"electionDate"            : @"Info.ElectionDate",
             @"electionMonthDateOnly"   : @"Info.ElectionDateMonthOnly",
             @"isPrimary"               : @"Info.Primary",
             @"isCounty"                : @"Info.County",
             @"isLower"                 : @"Info.Lower",
             @"isUpper"                 : @"Info.Upper",
             @"isCongress"              : @"Info.Congress",
             @"isStatewide"             : @"Info.Statewide",
             @"isCancelled"             : @"Info.Cancelled",
             @"isComplete"              : @"Info.Complete",
             @"isAllMail"               : @"Info.AllMail",
             @"voterRegURLString"       : @"Info.VoterRegLink",
             @"electionDateTimesString" : @"Info.ElectionDateTimes",
             @"pollingPlaceURLString"   : @"Info.PollingPlaceLink",
             @"earlyVotinDatesString"   : @"Info.EarlyVotingDates",
             @"earlyVotingTimesString"  : @"Info.EarlyVotingTimes",
             @"earlyVotingURLString"    : @"Info.EarlyVotingLink",
             @"absenteeVotingURLString" : @"Info.AbsenteeVotingLink",
             @"absenteeVotingDeadlines" : @"Info.AbsenteeVotingDeadlines",
             @"races"                   : @"Races",
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)electionDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)racesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[Race class]];
}

#pragma mark - Private Methods

- (NSString *)displayName {
    if ([self.electionName.lowercaseString containsString:@"primary"]) {
        return [NSString stringWithFormat:@"Primary Election in %@", self.state.uppercaseString];
    } else if ([self.electionName.lowercaseString containsString:@"special"]) {
        return [NSString stringWithFormat:@"Special Election in %@", self.state.uppercaseString];
    } else if ([self.electionName.lowercaseString containsString:@"general"]) {
        return [NSString stringWithFormat:@"General Election in %@", self.state.uppercaseString];
    } else {
        return self.electionName;
    }
}

@end
