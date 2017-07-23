//
//  DonateViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBViewController.h"
#import "Stripe.h"
#import "GlobalAPI.h"

@interface DonateViewController : DBViewController<STPPaymentContextDelegate,UITextFieldDelegate>

@end

