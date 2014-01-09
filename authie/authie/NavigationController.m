//
//  NavigationController.m
//  crushes
//
//  Created by Seth Hayward on 10/2/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "NavigationController.h"
#import <REFrostedViewController.h>
#import "MenuViewController.h"

@interface NavigationController ()

@property (strong, readwrite, nonatomic) MenuViewController *menuViewController;

@end

@implementation NavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender
{
    NSLog(@"ShowMenu called.");
 //   [self resignFirstResponder];
//    [self.menuViewController presentFromViewController:self animated:YES completion:nil];
    [self.frostedViewController presentMenuViewController];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
//    [self.menuViewController presentFromViewController:self panGestureRecognizer:sender];
    [self.frostedViewController panGestureRecognized:sender];
}

@end
