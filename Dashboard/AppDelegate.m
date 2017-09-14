//
//  AppDelegate.m
//  Dashboard
//
//  Created by Jhaybie Basco on 2/25/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"
#import "SVProgressHUD.h"
#import "UIColor+DBColors.h"
#import "Stripe.h"
#import "NSObject+reSideMenuSingleton.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register Facebook required classes
    [FBSDKLoginButton class];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    // Register Google Maps SDK API Key
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    
    // Stripe API initialization
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:STRIPE_PUB_KEY];

    
    // Configure tabBarController appearance
    [[UITabBar appearance] setBarTintColor:[UIColor globalDarkColor]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:@"#7ECCED"]];
    NSDictionary *selectedAttributes = @{
                                         NSFontAttributeName            : [UIFont systemFontOfSize:12 weight:UIFontWeightBold],
                                         NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#7ECCED"]
                                         };
    NSDictionary *normalAttributes = @{
                                       NSFontAttributeName            : [UIFont systemFontOfSize:12 weight:UIFontWeightLight],
                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                       };
    [[UITabBarItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:USER_ADDRESS_EXISTS]) {
        [defaults setObject:@"False" forKey:USER_ADDRESS_EXISTS];
    }
    if (![defaults objectForKey:CONTACTS_IMPORTED]) {
        [defaults setObject:@"False" forKey:CONTACTS_IMPORTED];
    }
    [defaults removeObjectForKey:@"RegisterEmailFB"];
    
    [self configureSVProgressHUD];
    
    [reSideMenuSingleton sharedManager];
    [self.window setRootViewController:[[reSideMenuSingleton sharedManager]sideMenuViewController]];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
    // Add any custom logic here.
    return handled;
} 


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)configureSVProgressHUD {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

@end
