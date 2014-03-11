//
//  AppDelegate.m
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "NavigationController.h"
#import "ThreadViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RegisterViewController.h"
#import "ContactsViewController.h"
#import "TestFlight.h"
#import "GAI.h"
#import "SelectContactViewController.h"
#import "AuthorizeContactViewController.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import <SignalR-ObjC/SignalR.h>
#import "RODHandle.h"
#import "GAITrackedViewController.h"
#import "NavigationViewController.h"
#import "MessagesViewController.h"

@implementation AppDelegate
@synthesize threadViewController, contactsViewController, privateKeyViewController, dashViewController, loginViewController, registerViewController, selectContactViewController, authorizeContactViewController, notificationDelegate, aboutViewController, navigationViewController, messagesViewController, wireViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
            
    // test flighty
    [TestFlight takeOff:@"e0b1dd9c-b710-4223-8aa8-b68350a2da33"];

    // urchin

    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    // Initialize tracker.
    id<GAITracker> tracker = nil;
    
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-47064407-1"];

    // urbanairship
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
    // You can also programmatically override the plist values:
    // config.developmentAppKey = @"YourKey";
    // etc.
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    [UAirship setLogLevel:UALogLevelDebug];
    
    config.detectProvisioningMode = YES;
    
    // Request a custom set of notification types
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert);
    
    
    ThreadViewController *thread = [[ThreadViewController alloc] init];
    threadViewController = thread;
    
    AuthorizeContactViewController *authorize = [[AuthorizeContactViewController alloc] init];
    authorizeContactViewController = authorize;

    SelectContactViewController *select = [[SelectContactViewController alloc] init];
    selectContactViewController = select;
    
    ContactsViewController *contacts = [[ContactsViewController alloc] init];
    contactsViewController = contacts;
    
    PrivateKeyViewController *private = [[PrivateKeyViewController alloc] init];
    privateKeyViewController = private;
    
    DashViewController *dash = [[DashViewController alloc] init];
    dashViewController = dash;
    dashViewController.doGetThreadsOnView = YES;
    
    LoginViewController *login = [[LoginViewController alloc] init];
    loginViewController = login;
    
    AboutViewController *about = [[AboutViewController alloc] init];
    aboutViewController = about;
    
    WireViewController *wire = [[WireViewController alloc] init];
    wireViewController = wire;
    
    UACustomPushNotificationDelegate *notes = [[UACustomPushNotificationDelegate alloc] init];
    notificationDelegate = notes;
    [UAPush shared].pushNotificationDelegate = notificationDelegate;
    
    
    // set font for all nav controllers
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [titleBarAttributes setValue:[UIFont systemFontOfSize:12] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    
    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:dashViewController];
    
    [navController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [navController.navigationBar setTintColor:[UIColor blackColor]];
    
    NSDictionary *new_font = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor], NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:12.0], NSFontAttributeName, nil];
    
    [navController.navigationBar setTitleTextAttributes:new_font];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
    NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:dashViewController];
    navigationViewController = nav;
    
    self.window.rootViewController = navigationViewController;

    
//    [self.window setRootViewController:drawerController];
    
    if([RODItemStore sharedStore].authie.registered == 0) {
        // show register handle screen

        RegisterViewController *rvc = [[RegisterViewController alloc] init];
        registerViewController = rvc;
        [self.dashViewController.navigationController pushViewController:rvc animated:YES];
        
    } else {
        // check login status
        // try to log in if not logged in

        [[RODItemStore sharedStore] checkLoginStatus];
        
    }
    
    
    [[UAPush shared] setAutobadgeEnabled:YES];
    [[UAPush shared] resetBadge];//zero badge
    

    // setting up background fetching
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    [[RODItemStore sharedStore] loadThreads:false];
    
    
}

- (void)                application:(UIApplication *)application
  performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    [[RODItemStore sharedStore] loadMessages:completionHandler];
    [[RODItemStore sharedStore] unreadMessages];    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
