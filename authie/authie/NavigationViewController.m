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
#import "RODMessage.h"
#import "MessagesViewController.h"
#import "WireViewController.h"
#import "CameraViewController.h"

@interface NavigationViewController ()

@property (strong, readwrite, nonatomic) REMenu *menu;

@property (strong, nonatomic) REMenuItem *homeItem;
@property (strong, nonatomic) REMenuItem *messagesItem;

@end

@implementation NavigationViewController
@synthesize homeItem, messagesItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (REUIKitIsFlatMode()) {
        [self.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
        self.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.backgroundColor = [UIColor blackColor];
        self.navigationBar.barTintColor = [UIColor blackColor];
    }
        
    __typeof (self) __weak weakSelf = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    int unread = [[RODItemStore sharedStore] unreadMessages];
    
    REMenuItem *wireItem = [[REMenuItem alloc] initWithTitle:@"The Wire"
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"eye-white-v1"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          WireViewController *controller = appDelegate.wireViewController;
                                                          
                                                          [controller setDoGetThreadsOnView:YES];
                                                          
                                                          [weakSelf setViewControllers:@[controller] animated:NO];
                                                                                                                    
                                                      }];
    
    homeItem = [[REMenuItem alloc] initWithTitle:@"Dash"
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"house-v5-white"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);

                                                          DashViewController *controller = appDelegate.dashViewController;
                                                          
                                                          [controller setDoGetThreadsOnView:YES];
                                                          
                                                          [weakSelf setViewControllers:@[controller] animated:NO];
                                                                                                                    
                                                      }];
    
    if(unread > 0) {
        [homeItem setImage:[UIImage imageNamed:@"house-v6-white-new-msg"]];
    }

    messagesItem = [[REMenuItem alloc] initWithTitle:@"Messages"
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"messages-white-v1"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             MessagesViewController *controller = appDelegate.messagesViewController;
                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    

    
    messagesItem.badge = [NSString stringWithFormat:@"%i", unread];

//    REMenuItem *addItem = [[REMenuItem alloc] initWithTitle:@"Add"
//                                                        subtitle:nil
//                                                           image:[UIImage imageNamed:@"add-v1-white"]
//                                                highlightedImage:nil
//                                                          action:^(REMenuItem *item) {
//
//                                                              DashViewController *controller = appDelegate.dashViewController;
//                                                              
//                                                              [weakSelf setViewControllers:@[controller] animated:NO];
//                                                              
//                                                              [controller addContact];
//                                                          }];
    

    REMenuItem *caItem = [[REMenuItem alloc] initWithTitle:@"Camera"
                                                   subtitle:nil
                                                      image:[UIImage imageNamed:@"add-v1-white"]
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {

                                                         CameraViewController *controller = [[CameraViewController alloc] init];
                                                         
                                                         [weakSelf setViewControllers:@[controller] animated:NO];
                                                         
                                                     }];
    
    REMenuItem *privateKeyItem = [[REMenuItem alloc] initWithTitle:@"Settings"
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"key-v3-white"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             PrivateKeyViewController *controller = appDelegate.privateKeyViewController;
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
    
    wireItem.tag = 0;
    homeItem.tag = 1;
    messagesItem.tag = 2;
    privateKeyItem.tag = 4;
 
    self.menu = [[REMenu alloc] initWithItems:@[homeItem, wireItem, privateKeyItem]];
    
    // Background view
    //
//    self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.menu.backgroundView.backgroundColor = [UIColor blackColor];
//
//    self.menu.backgroundColor = [UIColor blackColor];
//    
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
    
    [self.menu setTextColor:[UIColor whiteColor]];
    
    //self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showMenu:(id)sender
{
    int unread = [[RODItemStore sharedStore] unreadMessages];
    if(unread > 0) {
        [homeItem setImage:[UIImage imageNamed:@"house-v6-white-new-msg"]];
        messagesItem.badge = [NSString stringWithFormat:@"%i", unread];
        NSLog(@"Show menu called, unread: %i", unread);
    } else {
        [homeItem setImage:[UIImage imageNamed:@"house-v5-white"]];
        messagesItem.badge = nil;
    }
    
    [self toggleMenu];
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
}

@end
