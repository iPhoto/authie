//
//  UrbanAirshipCustomPushNotificationDelegate.h
//  authie
//
//  Created by Seth Hayward on 1/21/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"


@interface UACustomPushNotificationDelegate : NSObject <UAPushNotificationDelegate>

@property (strong, nonatomic) NSString *received_thread_key;
@property (strong, nonatomic) NSString *received_from_public_key;

@end
