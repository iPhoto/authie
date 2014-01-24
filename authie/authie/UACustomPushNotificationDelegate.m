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
    
    [[RODItemStore sharedStore] pushThreadWithGroupKey:notificationGroupKey];
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
    
    
    
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification
{
    
    NSLog(@"Received background push.");
    
}

@end
