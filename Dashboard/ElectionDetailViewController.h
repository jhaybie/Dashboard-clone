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

@class Election;

@interface ElectionDetailViewController : DBViewController <ContactListViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic) int electionIndex;
@property (nonatomic, strong) NSArray<Election *> *elections;

@end
