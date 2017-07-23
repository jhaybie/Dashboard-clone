//
//  SectionHeaderView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 6/9/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "SectionHeaderView.h"

@interface SectionHeaderView()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation SectionHeaderView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 60);
    
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.titleLabel.text = title;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andElectionDate:(NSDate*)electionDate{
    self = [super init];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 60);
    
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.titleLabel.text = title;
        
        if ([electionDate timeIntervalSinceNow] < 0.0) {
            self.subTitleLabel.text = [NSDateFormatter localizedStringFromDate:electionDate
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterNoStyle];
        } else {
            NSDate *today = [NSDate date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
            
            NSDateComponents *components = [gregorian components:units fromDate:today toDate:electionDate options:0];
            int years = (int)[components year];
            int months = (int)[components month];
            int days = (int)[components day];
            int weeks = days / 7;
            
            days = days % 7;
            
            NSString *yearString = @"";
            if (years == 0) {
                yearString = @"";
            } else if (years == 1) {
                yearString = @"1 year, ";
            } else {
                yearString = [NSString stringWithFormat:@"%i years, ", years];
            }
            
            NSString *monthString = @"";
            if (months == 0) {
                monthString = @"";
            } else if (months == 1) {
                monthString = @"1 month, ";
            } else {
                monthString = [NSString stringWithFormat:@"%i months, ", months];
            }
            
            NSString *weekString = @"";
            if (weeks == 0) {
                weekString = @"";
            } else if (weeks == 1) {
                weekString = @"1 week, ";
            } else {
                weekString = [NSString stringWithFormat:@"%i weeks, ", weeks];
            }
            
            NSString *dayString = @"1 day";
            if (days != 1) {
                dayString = [NSString stringWithFormat:@"%i days ", days];
            }
            
            self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@%@%@", yearString, monthString, weekString, dayString];
            [self.subTitleLabel sizeToFit];
        }
        
        
        
    }
    return self;
}
@end
