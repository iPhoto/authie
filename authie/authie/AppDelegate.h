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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) REFrostedViewController *drawer;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) NavigationController *navigationController;
@property (strong, nonatomic) MasterViewController *masterViewController;

@end
