//
//  ElectionDetailViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "ContactListView.h"
#import "DBViewController.h"
#import "DetailCardView.h"

@class Election;
@class OtherElection;

@interface ElectionDetailViewController : DBViewController <ContactListViewDelegate, DetailCardViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic) int electionIndex;
@property (nonatomic) BOOL forContacts;
@property (nonatomic, strong) NSArray<Election *> *elections;
@property (nonatomic, strong) NSArray<OtherElection *> *otherElections;

@end
