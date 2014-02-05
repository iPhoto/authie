//
//  BlankSlateViewController.m
//  authie
//
//  Created by Seth Hayward on 1/26/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "BlankSlateViewController.h"

@interface BlankSlateViewController ()

@end

@implementation BlankSlateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"BlankSlate";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
