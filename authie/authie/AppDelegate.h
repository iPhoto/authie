//
//  AppDelegate.h
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <REFrostedViewController.h>
#import "NavigationController.h"
#import "MenuViewController.h"
#import "ThreadViewController.h"
#import "ContactsViewController.h"
#import "InviteViewController.h"
#import "PrivateKeyViewController.h"
#import "DailyViewController.h"
#import "DashViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SelectContactViewController.h"
#import "AuthorizeContactViewController.h"
#import "UACustomPushNotificationDelegate.h"
#import <SignalR-ObjC/SignalR.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, REFrostedViewControllerDelegate, SRConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ThreadViewController *threadViewController;
@property (strong, nonatomic) MenuViewController *leftDrawer;
@property (strong, nonatomic) ContactsViewController *contactsViewController;
@property (strong, nonatomic) InviteViewController *inviteViewController;
@property (strong, nonatomic) PrivateKeyViewController *privateKeyViewController;
@property (strong, nonatomic) DailyViewController *dailyViewController;
@property (strong, nonatomic) DashViewController *dashViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) RegisterViewController *registerViewController;
@property (strong, nonatomic) SelectContactViewController *selectContactViewController;
@property (strong, nonatomic) AuthorizeContactViewController *authorizeContactViewController;
@property (strong, nonatomic) UACustomPushNotificationDelegate *notificationDelegate;
@property (strong, nonatomic) REFrostedViewController *drawer;

@property (strong, nonatomic) SRHubConnection *hubConnection;
@property (strong, nonatomic) SRHubProxy *hubProxy;

@property (strong, nonatomic) NSString *mostRecentGroupKey;

- (void)pushThreadWithGroupKey:(NSString *)group_key;


@end
