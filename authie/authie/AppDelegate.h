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
#import "MasterViewController.h"
#import "MenuViewController.h"
#import "ThreadViewController.h"
#import "ContactsViewController.h"
#import "InviteViewController.h"
#import "PrivateKeyViewController.h"
#import "DailyViewController.h"
#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SelectContactViewController.h"
#import "AuthorizeContactViewController.h"
#import "UACustomPushNotificationDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, REFrostedViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) ThreadViewController *threadViewController;
@property (strong, nonatomic) MenuViewController *leftDrawer;
@property (strong, nonatomic) ContactsViewController *contactsViewController;
@property (strong, nonatomic) InviteViewController *inviteViewController;
@property (strong, nonatomic) PrivateKeyViewController *privateKeyViewController;
@property (strong, nonatomic) DailyViewController *dailyViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) RegisterViewController *registerViewController;
@property (strong, nonatomic) SelectContactViewController *selectContactViewController;
@property (strong, nonatomic) AuthorizeContactViewController *authorizeContactViewController;
@property (strong, nonatomic) UACustomPushNotificationDelegate *notificationDelegate;

@end
