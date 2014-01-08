//
//  MenuViewController.h
//  authie
//
//  Created by Seth Hayward on 1/6/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <REFrostedViewController.h>

@interface MenuViewController : REFrostedViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView *loginView;
    IBOutlet UIView *footerView;
}

- (UIView *)loginView;

@property (weak, readwrite, nonatomic) UINavigationController *navigationController;
@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItems;

@end
