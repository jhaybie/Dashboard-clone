//
//  DBCheckboxButton.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/27/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCheckboxButton : UIButton

@property (nonatomic) BOOL isChecked;
@property (strong, nonatomic) UIImage *checkedImage;
@property (strong, nonatomic) UIImage *uncheckedImage;

@end
