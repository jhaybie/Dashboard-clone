//
//  ElectionCardView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/1/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "ElectionCardView.h"
#import "Election.h"

@interface ElectionCardView()

@end

@implementation ElectionCardView

- (instancetype)initWithElection:(Election *)election {
    if ((self = [super init])) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ElectionCardView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        self.positionLabel.text = election.positionName;
        
        UIImage *image1 = [UIImage imageNamed:@"background-1"];
        UIImage *image2 = [UIImage imageNamed:@"background-2"];
        UIImage *image3 = [UIImage imageNamed:@"background-3"];
        UIImage *image4 = [UIImage imageNamed:@"background-4"];
        
        NSArray<UIImage *> *images = @[image1, image2, image3, image4];
        int i = arc4random() % 4;
        
        self.cityImageView.image = image1;//images[i];
        
        NSString *locationString = (election.location.length == 0) ? @"" : election.location;
        NSString *commaString = (locationString.length == 0) ? @"" : @", ";
        NSString *stateString = (election.state.length == 0) ? @"" : election.state;
//        locationString = (stateString.length == 0) ? locationString : [NSString stringWithFormat:@"%@, ", locationString];
        self.cityStateLabel.text = [NSString stringWithFormat:@"%@%@%@", locationString, commaString, stateString];
    }
    return self;
}

@end
