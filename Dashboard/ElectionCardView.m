//
//  ElectionCardView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionCardView.h"
#import "Race.h"
#import "UIColor+DBColors.h"

@interface ElectionCardView()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeightConstraint;

@end

@implementation ElectionCardView

- (instancetype)initWithRace:(Race *)race
                     forDate:(NSDate *)electionDate
                  forContact:(BOOL)forContact
                contactCount:(int)contactCount
              preferredWidth:(CGFloat)width {
    
    CGRect frame = CGRectMake(0, 0, width, 217);
    
    
    if ((self = [super initWithFrame:frame])) {
        if (electionDate==nil)
        {
            self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardViewRev"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
            self.electionTimeLabel.hidden=YES;
            self.electionInLabel.hidden=YES;
            self.positionView.hidden=NO;
            [self.positionLabel setFrame:self.electionTimeLabel.frame];
            
        }
        else
            self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardView"
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
        
        self.badgeView.hidden = !forContact;
        
        self.badgeCountLabel.text = [NSString stringWithFormat:@"%i", contactCount];
        
        if (race.isConfirmed) {
            [self.statusButton setTitle:@"Confirmed" forState:UIControlStateNormal];
            [self.statusButton setBackgroundColor:[UIColor globalSuccessColor]];
        } else {
            [self.statusButton setTitle:@"Projected" forState:UIControlStateNormal];
            [self.statusButton setBackgroundColor:[UIColor globalFailureColor]];
        }
        
        if ([electionDate timeIntervalSinceNow] < 0.0) {
            self.electionInLabel.text = @"ELECTION WAS";
            self.electionTimeLabel.text = [NSDateFormatter localizedStringFromDate:electionDate
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
            
            self.electionTimeLabel.text = [NSString stringWithFormat:@"%@%@%@%@", yearString, monthString, weekString, dayString];
            [self.electionTimeLabel sizeToFit];
        }
        
        
        //[self.electionTimeLabel sizeToFit];
        //self.electionTimeLabel.preferredMaxLayoutWidth = [self.electionTimeLabel alignmentRectForFrame:self.electionTimeLabel.frame].size.width;
        
        self.positionLabel.text = [NSString stringWithFormat:@"%@ (%@)", race.raceName, race.state.uppercaseString];
        //[self.positionLabel sizeToFit];
        //self.positionLabel.preferredMaxLayoutWidth = [self.positionLabel alignmentRectForFrame:self.positionLabel.frame].size.width;
        
        //NSString *locationString = (!race.statewide) ? @"" : race.city;
        //NSString *commaString = (!race.statewide) ? @"" : @", ";
        //NSString *stateString = (race.state.length == 0) ? @"" : race.state;
        //self.cityStateLabel.text = [NSString stringWithFormat:@"%@%@%@", locationString, commaString, stateString];
        //[self.cityStateLabel sizeToFit];
        //self.cityStateLabel.preferredMaxLayoutWidth = [self.cityStateLabel alignmentRectForFrame:self.cityStateLabel.frame].size.width;
        
        //self.positionView.frame = CGRectMake(self.positionView.frame.origin.x, self.positionView.frame.origin.y, self.positionView.frame.size.width, 10 + self.positionLabel.frame.size.height/* + self.cityStateLabel.frame.size.height*/);
        
        //CGRect frame = self.frame;
        //self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.positionView.frame.size.height + 140);
        //self.backgroundViewHeightConstraint.constant = self.positionView.frame.size.height + 140;
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)statusButtonTapped:(id)sender {
    NSString *title = @"";
    NSString *message = @"";
    if (![self.statusButton.titleLabel.text isEqualToString:@"Confirmed"]) {
        title = @"Projected Election";
        message = @"The data for this election is subject to change and may not apply to your locale. Please check back as we get closer to the final date. Please see our terms and conditions for more details.";
    } else {
        title = @"Confirmed Election";
        message = @"We are reasonably confident that the information provided is accurate and complete. Please see our terms and conditions for more details.";
    }
    
    [self.delegate electionCardViewStatusButtonTappedMessage:@{ @"Title"   : title,
                                                                @"Message" : message
                                                                }];
}

@end
