//
//  UrbanAirshipCustomPushNotificationDelegate.m
//  authie
//
//  Created by Seth Hayward on 1/21/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "UACustomPushNotificationDelegate.h"
#import "RODItemStore.h"

@implementation UACustomPushNotificationDelegate

- (void)launchedFromNotification:(NSDictionary *)notification
{
    NSLog(@"Launched from notification...");
    
}

- (void)displayNotificationAlert:(NSString *)alertMessage {
    NSLog(@"Cool... %@", alertMessage);
}
@end
