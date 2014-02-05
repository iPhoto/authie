//
//  PrivateKeyViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "PrivateKeyViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODHandle.h"
#import "NavigationController.h"

@implementation PrivateKeyViewController

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

    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];

    NSLog(@"Will appear: %@",[RODItemStore sharedStore].authie.privateKey);
    
    self.privateKey.text = [[RODItemStore sharedStore].authie.privateKey substringToIndex:5];
    
    self.screenName = @"PrivateKey";
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
