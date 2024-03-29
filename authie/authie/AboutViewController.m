//
//  AboutViewController.m
//  authie
//
//  Created by Seth Hayward on 1/31/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "AboutViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"

@implementation AboutViewController

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
        
    self.navigationItem.title = @"what is authie?";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Do any additional setup after loading the view from its nib.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://authie.me/appabout"]]];

    [self.navigationController setNavigationBarHidden:NO];
    
    self.screenName = @"About";
    
    if([RODItemStore sharedStore].authie.registered == 1) {
        self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"about-v3-white.png"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
