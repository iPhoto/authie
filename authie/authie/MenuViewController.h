//
//  MenuViewController.h
//  authie
//
//  Created by Seth Hayward on 1/6/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView *menuHeaderView;
    IBOutlet UIView *footerView;
    NSArray *menuItems;
}

- (UIView *)menuHeaderView;

@end
