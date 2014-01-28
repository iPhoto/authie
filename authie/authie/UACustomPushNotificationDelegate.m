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
    
    [[RODItemStore sharedStore] loadMessagesForThread:notificationGroupKey];
    [[RODItemStore sharedStore] pushThreadWithGroupKey:notificationGroupKey];
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification
{
    NSLog(@"received background notification: %@", notification);
    
    NSString *alertMessage;
    NSString *notificationGroupKey = [notification objectForKey:@"threadKey"];
    
    NSDictionary *aps = [notification objectForKey:@"aps"];
    alertMessage = [aps objectForKey:@"alert"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[RODItemStore sharedStore] loadMessagesForThread:notificationGroupKey];
        
    if([appDelegate.threadViewController.thread.groupKey isEqualToString:notificationGroupKey]) {
        // do nothing, they are viewing this thread
        
    } else {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"new auth" message:alertMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
        [al show];
        self.received_thread_key = notificationGroupKey;
        
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
    [[RODItemStore sharedStore] loadMessagesForThread:notificationGroupKey];
    
    
    if([appDelegate.threadViewController.thread.groupKey isEqualToString:notificationGroupKey]) {
        // do nothing, they are viewing this thread
        
    } else {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"new auth" message:alertMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"go to thread", nil];
        [al show];
        self.received_thread_key = notificationGroupKey;
        
    }
    
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
//        // Perform async operation
//        // Call your method/function here
//        // Example:
//        // NSString *result = [anObject calculateSomething];
//        
//        NSLog(@"foreground notification says load messages/threads");
//        
//        [[RODItemStore sharedStore] loadThreads];
//        [[RODItemStore sharedStore] loadMessages];
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            // Update UI
//            // trash the dash
//            // recreate it, do it better this time
//            [appDelegate.dashViewController populateScrollView];
//            
//        });
//    });
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1) {
        // push find thread with groupKey = self.received_group_key,
        // push that...
        [[RODItemStore sharedStore] loadMessagesForThread:self.received_thread_key];
        [[RODItemStore sharedStore] pushThreadWithGroupKey:self.received_thread_key];
    }
    
    self.received_thread_key = @"";
    
}

@end
