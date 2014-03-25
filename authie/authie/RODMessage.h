//
//  RODMessage.h
//  authie
//
//  Created by Seth Hayward on 1/19/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RODHandle;
@class RODThread;

@interface RODMessage : NSObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *messageKey;
@property (nonatomic) NSDate *sentDate;
@property (nonatomic) NSNumber *active;
@property (nonatomic) NSNumber *anon;
@property (nonatomic) NSNumber *seen;
@property (nonatomic) NSString *messageText;
@property (nonatomic) NSString *toKey;
@property (nonatomic) NSNumber *localNotificationSent;
@property (nonatomic) NSString *groupKey;

@property (nonatomic) RODHandle *fromHandle;
@property (nonatomic) RODThread *thread;

@end
