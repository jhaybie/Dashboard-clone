//
//  ContactsViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "DBViewController.h"
#import "ContactCell.h"
#import "TableViewHeaderView.h"

@interface ContactsViewController : DBViewController <ContactCellDelegate, MFMessageComposeViewControllerDelegate, TableViewHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
