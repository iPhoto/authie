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
}

@property (strong, nonatomic) NSArray *buttons;


@end
