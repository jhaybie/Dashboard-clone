//
//  ElectionDetailViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/2/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ContactListView.h"

@class Election;

@interface ElectionDetailViewController : UIViewController <ContactListViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) int electionIndex;
@property (nonatomic, strong) NSArray<Election *> *elections;

@end
