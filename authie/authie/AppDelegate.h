//
//  AppDelegate.h
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadViewController.h"
#import "ContactsViewController.h"
#import "PrivateKeyViewController.h"
#import "DashViewController.h"
#import "LoginViewController.h"
#import "AboutViewController.h"
#import "RegisterViewController.h"
#import "SelectContactViewController.h"
#import "AuthorizeContactViewController.h"
#import "UACustomPushNotificationDelegate.h"
#import <SignalR-ObjC/SignalR.h>
#import "NavigationViewController.h"
#import "MessagesViewController.h"
#import "WireViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SRConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ThreadViewController *threadViewController;
@property (strong, nonatomic) ContactsViewController *contactsViewController;
@property (strong, nonatomic) PrivateKeyViewController *privateKeyViewController;
@property (strong, nonatomic) DashViewController *dashViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) RegisterViewController *registerViewController;
@property (strong, nonatomic) SelectContactViewController *selectContactViewController;
@property (strong, nonatomic) AuthorizeContactViewController *authorizeContactViewController;
@property (strong, nonatomic) AboutViewController *aboutViewController;
@property (strong, nonatomic) UACustomPushNotificationDelegate *notificationDelegate;
@property (strong, nonatomic) NavigationViewController *navigationViewController;
@property (strong, nonatomic) MessagesViewController *messagesViewController;
@property (strong, nonatomic) WireViewController *wireViewController;

@end
