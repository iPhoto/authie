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
#import "RODItemStore.h"
#import <SignalR-ObjC/SignalR.h>

@interface NavigationController ()

@property (strong, readwrite, nonatomic) MenuViewController *menuViewController;

@end

@implementation NavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self.frostedViewController presentMenuViewController];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
// no more pan gesture, this is annoying
//    [self.frostedViewController panGestureRecognized:sender];
    
}


- (void)addMessage:(NSString *)user message:(NSString *)msg groupKey:(NSString *)key
{
    NSLog(@"addMessage, dashy: %@, %@, %@, %i", user, msg, key, [RODItemStore sharedStore].hubConnection.state);
    [[RODItemStore sharedStore] addChat:user message:msg groupKey:key];
    
    //NSString *s = [NSString stringWithFormat:@"%@ said: %@", user, msg];
    // Print the message when it comes in
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"new auth" message:s delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
    //[alert show];
    //self.mostRecentGroupKey = key;
    
    //
    //
    //    if([dashViewController.navigationController.topViewController class] != [ThreadViewController class]) {
    //        // looking at dash, invite, private key, compose
    //        self.mostRecentGroupKey = key;
    //        [alert show];
    //    } else {
    //
    //        // looking at a thread, may be the one we need to update
    //
    //        NSLog(@"Toplevel was a threadviewcontroller.");
    //        NSString *current_group_key = threadViewController.thread.groupKey;
    //
    //        if([current_group_key isEqualToString:key]) {
    //            // reload the current messages..??????
    //        } else {
    //            self.mostRecentGroupKey = key;
    //        }
    //
    //        [alert show];
    //
    //    }
    
}

@end
