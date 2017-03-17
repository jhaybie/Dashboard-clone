//
//  MapViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MapViewController.h"
#import "Constant.h"
#import "Election.h"
#import "ElectionCardView.h"
#import "GlobalAPI.h"
#import "UIColor+DBColors.h"

@interface MapViewController ()

@end

@implementation MapViewController
BOOL userAddressExists;

#pragma mark - Override Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADDRESS_UPDATED
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userAddressExists = ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]);
    
    self.shouldShowNagView = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addressUpdated)
                                                 name:ADDRESS_UPDATED
                                               object:nil];
    
    [self getElections];
}

#pragma mark - Private Methods

- (void)addressUpdated {
    userAddressExists = ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]);
    [self getElections];
}

- (void)loadMapViewWithCoordinates:(CLLocationCoordinate2D)coordinate {
    float zoom = (userAddressExists) ? 13 : 3;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:zoom];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = false;
    mapView.delegate = self;
    mapView.frame = self.view.frame;
    [self.view insertSubview:mapView belowSubview:self.nagView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [UIImage imageNamed:@"icon-map-marker"];
    marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    marker.position = coordinate;
    //marker.title = @"You";
    //marker.snippet = @"Here";
    marker.map = mapView;
}

- (void)getCoordinatesFromAddressString:(NSString *)addressString {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        CLLocation *location = placemark.location;
        CLLocationCoordinate2D coordinate = location.coordinate;
        [self loadMapViewWithCoordinates:coordinate];
    }];
}

#pragma mark - API Calls

- (void)getElections {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fullAddress = @"";
    if (userAddressExists) {
        NSString *street = [defaults objectForKey:USER_STREET];
        NSString *city = [defaults objectForKey:USER_CITY];
        NSString *state = [defaults objectForKey:USER_STATE];
        NSString *zip = [defaults objectForKey:USER_ZIP_CODE];
        fullAddress = [NSString stringWithFormat:@"%@, %@ %@ %@", street, city, state, zip];
    } else {
        fullAddress = @"United States";
    }
    
    [GlobalAPI getElections:^(NSArray<Election *> *elections) {
        self.elections = [[NSArray alloc] initWithArray:elections];
        [self getCoordinatesFromAddressString:fullAddress];
    } failure:^(NSInteger statusCode) {
        //
    }];
}

#pragma mark - GMSMapView Delegate Methods

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    if (self.elections.count > 0) {
        ElectionCardView *cardView = [[ElectionCardView alloc] initWithElection:self.elections[0]];
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 48, cardView.frame.size.height);
        cardView.frame = frame;
        return cardView;
    } else {
        return nil;
    }
}

@end
