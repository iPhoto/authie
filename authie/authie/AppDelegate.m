//
//  AppDelegate.m
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "DetailViewController.h"
#import "NavigationController.h"
#import "MasterViewController.h"
#import <REFrostedViewController.h>
#import "ThreadViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RegisterViewController.h"
#import "ContactsViewController.h"
#import "TestFlight.h"
#import "GAI.h"

@implementation AppDelegate
@synthesize masterViewController, threadViewController, contactsViewController, privateKeyViewController, inviteViewController, dailyViewController, profileViewController, loginViewController, registerViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *znavigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)znavigationController.topViewController;
    }
    

    if(SYSTEM_VERSION_GREATER_THAN(@"7.0") ) { 
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
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
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-47064407-1"];

    MasterViewController *master = [[MasterViewController alloc] init];
    masterViewController = master;
    
    ThreadViewController *thread = [[ThreadViewController alloc] init];
    threadViewController = thread;
    
    ContactsViewController *contacts = [[ContactsViewController alloc] init];
    contactsViewController = contacts;
    
    PrivateKeyViewController *private = [[PrivateKeyViewController alloc] init];
    privateKeyViewController = private;
    
    InviteViewController *invite = [[InviteViewController alloc] init];
    inviteViewController = invite;
    
    ProfileViewController *profile = [[ProfileViewController alloc] init];
    profileViewController = profile;
    
    LoginViewController *login = [[LoginViewController alloc] init];
    loginViewController = login;
    
    DailyViewController *daily = [[DailyViewController alloc] init];
    dailyViewController = daily;
    
    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:masterViewController];
    navController.navigationBar.tintColor = [UIColor blackColor];
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
    drawerController.delegate = self;
    [self.window setRootViewController:drawerController];
    
    if([RODItemStore sharedStore].authie.registered == 0) {
        // show register handle screen

        RegisterViewController *rvc = [[RegisterViewController alloc] init];
        registerViewController = rvc;
        [self.masterViewController.navigationController pushViewController:rvc animated:YES];
        
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
