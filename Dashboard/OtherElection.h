//
//  OtherElection.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/23/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;
@class Election;

@interface OtherElection : NSObject

@property (nonatomic, strong) Election *election;
@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;

@end
