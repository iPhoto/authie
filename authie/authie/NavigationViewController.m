//
//  NavigationViewController.m
//  REMenuExample
//
//  Created by Roman Efimov on 4/18/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//
//  Sample icons from http://icons8.com/download-free-icons-for-ios-tab-bar
//

#import "NavigationViewController.h"
#import "DashViewController.h"
#import "PrivateKeyViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "RODItemStore.h"
#import "RODAuthie.h"

@interface NavigationViewController ()

@property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation NavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (REUIKitIsFlatMode()) {
        [self.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1]];
        self.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationBar.tintColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
    }
    
    __typeof (self) __weak weakSelf = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Dash"
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"house-v5-white.png"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          DashViewController *controller = appDelegate.dashViewController;
                                                          [weakSelf setViewControllers:@[controller] animated:NO];
                                                      }];

    REMenuItem *messagesItem = [[REMenuItem alloc] initWithTitle:@"Messages"
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"messages-v1-white.png"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             PrivateKeyViewController *controller = appDelegate.privateKeyViewController;
                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    messagesItem.badge = [NSString stringWithFormat:@"%i", [[RODItemStore sharedStore].authie.allMessages count]];
    
    REMenuItem *privateKeyItem = [[REMenuItem alloc] initWithTitle:@"Private Key"
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"key-v3-white.png"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             PrivateKeyViewController *controller = appDelegate.privateKeyViewController;
                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    
    REMenuItem *aboutItem = [[REMenuItem alloc] initWithTitle:@"About"
                                                        subtitle:nil
                                                           image:[UIImage imageNamed:@"about-v3-white.png"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              AboutViewController *controller = appDelegate.aboutViewController;
                                                              [weakSelf setViewControllers:@[controller] animated:NO];
                                                          }];
    
    
    // You can also assign a custom view for any particular item
    // Uncomment the code below and add `customViewItem` to `initWithItems` array, for example:
    // self.menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem, customViewItem]]
    //
    /*
    UIView *customView = [[UIView alloc] init];
    customView.backgroundColor = [UIColor blueColor];
    customView.alpha = 0.4;
    REMenuItem *customViewItem = [[REMenuItem alloc] initWithCustomView:customView action:^(REMenuItem *item) {
        NSLog(@"Tap on customView");
    }];
    */
    
    homeItem.tag = 0;
    messagesItem.tag = 1;
    privateKeyItem.tag = 2;
    aboutItem.tag = 3;
 
    self.menu = [[REMenu alloc] initWithItems:@[homeItem, messagesItem, privateKeyItem, aboutItem]];
    
    // Background view
    //
    //self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];

    //self.menu.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    //self.menu.imageAlignment = REMenuImageAlignmentRight;
    //self.menu.closeOnSelection = NO;
    //self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    // Blurred background in iOS 7
    //
    //self.menu.liveBlur = YES;
    //self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    //self.menu.liveBlurTintColor = [UIColor redColor];
    
    //self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
}

- (void)showMenu:(id)sender
{
    [self toggleMenu];
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self];
}

@end
