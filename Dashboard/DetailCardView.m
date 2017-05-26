//
//  DetailCardView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 5/16/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DetailCardView.h"
#import "Race.h"

@implementation DetailCardView

- (instancetype)initWithRace:(Race *)race forDate:(NSDate *)electionDate {
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200);
    if ((self = [super initWithFrame:frame])) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DetailCardView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.frame = frame;
        
        UIImage *image1 = [UIImage imageNamed:@"background-1"];
        UIImage *image2 = [UIImage imageNamed:@"background-2"];
        UIImage *image3 = [UIImage imageNamed:@"background-3"];
        UIImage *image4 = [UIImage imageNamed:@"background-4"];
        
        NSArray<UIImage *> *images = @[image1, image2, image3, image4];
        int i = arc4random() % 4;
        
        self.cityImageView.image = images[i];
        
        if ([electionDate timeIntervalSinceNow] < 0.0) {
            self.electionInLabel.text = @"ELECTION WAS";
            self.timeLeftLabel.text = [NSDateFormatter localizedStringFromDate:electionDate
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
            
            self.timeLeftLabel.text = [NSString stringWithFormat:@"%@%@%@%@", yearString, monthString, weekString, dayString];
        }
        
        self.positionLabel.text = [NSString stringWithFormat:@"%@ (%@)", race.raceName, race.state.uppercaseString];
        [self.positionLabel sizeToFit];
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)statusButtonTapped:(id)sender {
    if (![self.statusButton.titleLabel.text isEqualToString:@"Confirmed"]) {
        NSString *message = @"The data for this eleciton is subject to change and may not apply to your locale. Please check back as we get closer to the final date.";
        [self.delegate detailCardViewStatusButtonTappedMessage:message];
    }
}

@end
