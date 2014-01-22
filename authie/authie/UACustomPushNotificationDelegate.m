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
#import "ThreadViewController.h"
#import "RODHandle.h"
#import "RODThread.h"
#import "RODAuthie.h"

@implementation UACustomPushNotificationDelegate
@synthesize received_thread_key;

- (void)launchedFromNotification:(NSDictionary *)notification
{
    NSString *notificationGroupKey = [notification objectForKey:@"threadKey"];
    NSLog(@"Launched from notification...%@", notificationGroupKey );
    
    [self pushThreadWithGroupKey:notificationGroupKey];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // push find thread with groupKey = self.received_group_key,
        // push that...
        [self pushThreadWithGroupKey:self.received_thread_key];
        self.received_thread_key = @"";
        
    }
}

- (void)pushThreadWithGroupKey:(NSString *)group_key
{
    RODThread *thread;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for(int i = 0; i< [[RODItemStore sharedStore].authie.all_Threads count]; i++)
    {
        thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:i];
        if([thread.groupKey isEqualToString:group_key]) {
            
            appDelegate.threadViewController = [[ThreadViewController alloc] init];
            [appDelegate.threadViewController loadThread:i];
            [appDelegate.dashViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
            
            break;
        }
    }
    
}

- (void)receivedForegroundNotification:(NSDictionary *)notification
{
    NSLog(@"recieved forground notification: %@", notification);

    NSString *alertMessage;
    NSString *notificationGroupKey = [notification objectForKey:@"threadKey"];
    
    NSDictionary *aps = [notification objectForKey:@"aps"];
    alertMessage = [aps objectForKey:@"alert"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];
        
        NSLog(@"foreground notification says load messages/threads");
        
        [[RODItemStore sharedStore] loadThreads];
        [[RODItemStore sharedStore] loadMessages];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // trash the dash
            // recreate it, do it better this time
            [appDelegate.dashViewController populateScrollView];
            
        });
    });
    
    if([appDelegate.dashViewController.navigationController.topViewController class] != [ThreadViewController class]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"new chat" message:alertMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
        self.received_thread_key = notificationGroupKey;
        [alert show];
        return;
    } else {
        NSLog(@"Toplevel was a threadviewcontroller.");
        NSString *current_group_key = appDelegate.threadViewController.thread.groupKey;
        
        if([current_group_key isEqualToString:notificationGroupKey]) {
            // reload the current messages..??????
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"new chat" message:alertMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
            [alert show];
            self.received_thread_key = notificationGroupKey;
        }
        
    }
    
    
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification
{
    
    NSLog(@"Received background push.");

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[RODItemStore sharedStore] loadThreads];
    [[RODItemStore sharedStore] loadMessages];
    appDelegate.dashViewController.doGetThreadsOnView = NO;
        
}

@end
