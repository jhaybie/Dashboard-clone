//
//  TableViewHeaderView.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "TableViewHeaderView.h"

@implementation TableViewHeaderView

#pragma mark - Init Methods

- (instancetype)init {
    self = [super init];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 120);
    
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)addButtonTapped:(id)sender {
    [self.delegate addButtonTapped];
}

@end
