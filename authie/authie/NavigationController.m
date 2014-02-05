//
//  NavigationController.m
//  crushes
//
//  Created by Seth Hayward on 10/2/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "NavigationController.h"
#import "MenuViewController.h"
#import "RODItemStore.h"
#import <SignalR-ObjC/SignalR.h>

@interface NavigationController ()

@property (strong, readwrite, nonatomic) MenuViewController *menuViewController;

@end

@implementation NavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
 

    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender
{
//[self.frostedViewController presentMenuViewController];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
// no more pan gesture, this is annoying
//    [self.frostedViewController panGestureRecognized:sender];
    
}

@end
