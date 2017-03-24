//
//  TableViewHeaderView.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewHeaderViewDelegate <NSObject>

- (void)tableHeaderViewRefreshButtonTapped;

@end


@interface TableViewHeaderView : UIView

@property (nonatomic, strong) id<TableViewHeaderViewDelegate> delegate;

- (instancetype)init;

@end
