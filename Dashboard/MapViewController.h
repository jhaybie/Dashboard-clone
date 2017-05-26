//
//  MapViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "DBViewController.h"

@class Election;
@class OtherElection;

@interface MapViewController : DBViewController <GMSMapViewDelegate>

@property (nonatomic, strong) NSArray<Election *> *elections;
@property (nonatomic, strong) NSArray<OtherElection *> *otherElections;

@end
