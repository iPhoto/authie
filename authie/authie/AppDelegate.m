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
#import <REFrostedViewController.h>
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

@implementation AppDelegate
@synthesize threadViewController, contactsViewController, privateKeyViewController, dashViewController, loginViewController, registerViewController, selectContactViewController, authorizeContactViewController, notificationDelegate,
    aboutViewController, drawer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *znavigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)znavigationController.topViewController;
    }
    
        
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
    [UAirship setLogLevel:UALogLevelNone];
    
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
    
    UACustomPushNotificationDelegate *notes = [[UACustomPushNotificationDelegate alloc] init];
    notificationDelegate = notes;
    [UAPush shared].pushNotificationDelegate = notificationDelegate;
    
    
    // set font for all nav controllers
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont systemFontOfSize:12] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    
    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:dashViewController];
    [navController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    MenuViewController * leftDrawer = [[MenuViewController alloc] initWithStyle:UITableViewStylePlain];
    self.leftDrawer = leftDrawer;
    
    NSDictionary *new_font = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor], NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:12.0], NSFontAttributeName, nil];
    
    [navController.navigationBar setTitleTextAttributes:new_font];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    

    REFrostedViewController *drawerController;
    drawerController = [[REFrostedViewController alloc] initWithContentViewController:navController menuViewController:self.leftDrawer];
    drawerController.direction = REFrostedViewControllerDirectionLeft;
    drawerController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    drawerController.menuViewSize = CGSizeMake(200, self.window.frame.size.height);
    drawerController.delegate = self;
    drawer = drawerController;
    
    
    
//    UIColor *appTint = self.window.tintColor;
//    
//    [UIButton appearance].tintColor = appTint;
//    [[UIButton appearance] setTitleColor:appTint
//                                forState:UIControlStateNormal];
//    [UISwitch appearance].tintColor = appTint;
//    [UISwitch appearance].onTintColor = appTint;
    
    [self.window setRootViewController:drawerController];
    
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
    
    
    
    // Override point for customization after application launch.
    return YES;
}


- (void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController
{
//    NSLog(@"willShowMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController
{
//    NSLog(@"didShowMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
//    NSLog(@"willHideMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController
{
//    NSLog(@"didHideMenuViewController");
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

    // clear badge count on all app opens
    [[UAPush shared] resetBadge];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"didReceiveRemoteNotification");
    
    [[RODItemStore sharedStore] loadThreads];
    
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].pushNotificationDelegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
