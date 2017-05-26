//
//  WRGMSMarker.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@class Race;
@class Contact;

@interface WRGMSMarker : GMSMarker

@property (nonatomic) BOOL forContacts;
@property (nonatomic, strong) Race *race;
@property (nonatomic, strong) NSArray<Contact *> *contacts;
@property (nonatomic, strong) NSDate *date;

@end
