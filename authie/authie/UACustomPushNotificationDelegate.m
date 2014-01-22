//
//  UrbanAirshipCustomPushNotificationDelegate.m
//  authie
//
//  Created by Seth Hayward on 1/21/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "UACustomPushNotificationDelegate.h"
#import "RODItemStore.h"
#import "AppDelegate.h"

@implementation UACustomPushNotificationDelegate

- (void)launchedFromNotification:(NSDictionary *)notification
{
    NSLog(@"Launched from notification...");
    
}

- (void)displayNotificationAlert:(NSString *)alertMessage {
    NSLog(@"Cool... %@", alertMessage);

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"class: %@", [appDelegate.dashViewController.navigationController.topViewController class]);
    
    if([appDelegate.dashViewController.navigationController.topViewController class] == [DashViewController class]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"new chat" message:alertMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
        [alert show];
        return;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [[RODItemStore sharedStore] addContact:name];
    }
}

@end
