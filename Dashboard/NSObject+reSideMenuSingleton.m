//
//  NSObject+reSideMenuSingleton.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 05/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "NSObject+reSideMenuSingleton.h"


@interface reSideMenuSingleton()
@end


@implementation reSideMenuSingleton:NSObject



static reSideMenuSingleton *manager = nil;

+ (reSideMenuSingleton *)sharedManager
{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}

+ (reSideMenuSingleton *)restartSharedManager
{
    manager = [[self alloc] init];
    
    return manager;
}
- (id)init
{
    self = [super init];
    
    if (self) {
        self._mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.vc = [self._mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeNav"];
        
        
        MenuViewController *leftMenuViewController = [[MenuViewController alloc] init];
        self.sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:self.vc leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
        
        self.sideMenuViewController.backgroundImage= [UIImage imageNamed:@"background-1"];
        
        
    }
    return self;
}


@end
