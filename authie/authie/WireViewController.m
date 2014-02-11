//
//  WireViewController.m
//  authie
//
//  Created by Seth Hayward on 2/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "WireViewController.h"
#import "RODItemStore.h"

@implementation WireViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getThreads
{
    NSLog(@"Get the Wire threads pls");
}

@end
