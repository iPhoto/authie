//
//  LoginViewController.m
//  authie
//
//  Created by Seth Hayward on 1/11/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "LoginViewController.h"
#import "RODItemStore.h"
#import "AppDelegate.h"

@implementation LoginViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doLogin:(id)sender {
    
    [[RODItemStore sharedStore] login:self.textHandle.text privateKey:self.textKey.text];
}

- (IBAction)cancel:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.dashViewController.navigationController popToViewController:appDelegate.registerViewController animated:YES];
    
}

@end
