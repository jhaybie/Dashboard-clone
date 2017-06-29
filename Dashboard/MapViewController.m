//
//  MapViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MapViewController.h"
#import "Constant.h"
#import "Contact.h"
#import "Election.h"
#import "ElectionCardView.h"
#import "ElectionDetailViewController.h"
#import "GlobalAPI.h"
#import "OtherElection.h"
#import "Race.h"
#import "UIColor+DBColors.h"
#import "WRGMSMarker.h"

@interface MapViewController()

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController
BOOL userAddressExists;

#pragma mark - Override Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADDRESS_UPDATED
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:YOUR_ELECTIONS_RECEIVED
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CONTACTS_ELECTIONS_RECEIVED
                                                  object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addressUpdated)
                                                 name:ADDRESS_UPDATED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayYourElections:)
                                                 name:YOUR_ELECTIONS_RECEIVED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayContactElections:)
                                                 name:CONTACTS_ELECTIONS_RECEIVED
                                               object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userAddressExists = ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]);
    
    self.shouldShowNagView = true;

    [self initializeMapView];
    [self loadYourElectionsInMapView];
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusAuthorized) {
        [self loadContactElectionsInMapView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadContactElectionsInMapView];
}

#pragma mark - Private Methods

- (void)addressUpdated {
    userAddressExists = ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS_EXISTS] isEqualToString:@"True"]);
    [self getElections];
}

- (void)displayContactElections:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSArray<OtherElection *> *otherElections = [dict objectForKey:@"OtherElections"];
    self.otherElections = otherElections;
    //[self loadContactElectionsInMapView];
}

- (void)displayYourElections:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSArray<Election *> *elections = [dict objectForKey:@"YourElections"];
    self.elections = elections;
    //[self loadYourElectionsInMapView];
}

- (NSIndexPath *)electionIndexForRace:(Race *)race forContacts:(BOOL)forContacts {
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    if (!forContacts) {
        for (int section = 0; section < self.elections.count; section++) {
            Election *election = self.elections[section];
            for (int row = 0; row < election.races.count; row++) {
                Race *raceToCompare = election.races[row];
                if (race.raceID == raceToCompare.raceID) {
                    indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }
    } else {
        for (int section = 0; section < self.otherElections.count; section++) {
            OtherElection *oe = self.otherElections[section];
            for (int row = 0; row < oe.election.races.count; row++) {
                Race *raceToCompare = oe.election.races[row];
                if (race.raceID == raceToCompare.raceID) {
                    indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }
    }
    return indexPath;
}

-(void)initializeMapView {
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = false;

    float zoom = 3;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.833333
                                                            longitude:-98.585522
                                                                 zoom:zoom];
    self.mapView.camera = camera;
}

- (void)loadContactElectionsInMapView {
    for (OtherElection *oe in self.otherElections) {
        for (Race *race in oe.election.races) {
            NSString *addressString = [NSString stringWithFormat:@"%@ %@", race.city, race.state];
            [self getCoordinatesFromAddressString:addressString
                                          forRace:race
                                          forDate:oe.election.electionDate
                                         contacts:oe.contacts];
        }
    }
}

- (void)loadYourElectionsInMapView {
    for (Election *election in self.elections) {
        for (Race *race in election.races) {
            NSString *addressString = [NSString stringWithFormat:@"%@ %@", race.city, race.state];
            [self getCoordinatesFromAddressString:addressString
                                          forRace:race
                                          forDate:election.electionDate
                                         contacts:nil];
        }
    }
}

- (void)loadMapViewWithCoordinates:(CLLocationCoordinate2D)coordinate forRace:(Race*) race forDate:(NSDate *)date contacts:(NSArray<Contact *> *)contacts {
    
    // Creates a marker in the center of the map.
    WRGMSMarker *marker = [[WRGMSMarker alloc] init];
    marker.icon = [UIImage imageNamed:@"icon-map-marker"];
    marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    marker.position = coordinate;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.title = race.raceName;
    marker.race = race;
    marker.date = date;
    marker.forContacts = (contacts.count > 0);
    marker.contacts = contacts;
    marker.map = self.mapView;
    
    //self.mapView.camera = [GMSCameraPosition cameraWithTarget:marker.position zoom:13];
}

- (void)getCoordinatesFromAddressString:(NSString *)addressString forRace:(Race *)race forDate:(NSDate *)date contacts:(NSArray<Contact *> *)contacts {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        CLLocation *location = placemark.location;
        CLLocationCoordinate2D coordinate = location.coordinate;
        [self loadMapViewWithCoordinates:coordinate
                                 forRace:race
                                 forDate:date
                                contacts:contacts];
    }];
}

#pragma mark - API Calls

- (void)getElections {
    [GlobalAPI getElections:^(NSArray<Election *> *elections) {
        self.elections = [[NSArray alloc] initWithArray:elections];
        for (Election *election in self.elections) {
            for (Race *race in election.races) {
                NSString *addressString = [NSString stringWithFormat:@"%@, %@ County, %@", race.city, race.county, race.state];
                [self getCoordinatesFromAddressString:addressString
                                              forRace:race
                                              forDate:election.electionDate
                                             contacts:nil];
            }
        }
    } failure:^(NSInteger statusCode) {
        //
    }];
}

#pragma mark - GMSMapView Delegate Methods

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(WRGMSMarker *)marker {
    ElectionDetailViewController *edvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ElectionDetailViewController"];
    edvc.electionIndex = [self electionIndexForRace:marker.race forContacts:marker.forContacts];
    edvc.elections = self.elections;
    edvc.forContacts = marker.forContacts;
    edvc.otherElections = self.otherElections;
    edvc.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:edvc
                       animated:true
                     completion:nil];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(WRGMSMarker *)marker {
    ElectionCardView *cardView = [[ElectionCardView alloc] initWithRace:marker.race
                                                                forDate:marker.date
                                                             forContact:marker.forContacts
                                                           contactCount:(int)marker.contacts.count
                                                         preferredWidth:[[UIScreen mainScreen] bounds].size.width - 80];
    return cardView;
}

@end
