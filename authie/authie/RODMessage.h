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
@property (nonatomic) NSDate *sentDate;
@property (nonatomic) NSNumber *active;
@property (nonatomic) NSNumber *anon;
@property (nonatomic) NSNumber *toHandleSeen;
@property (nonatomic) NSString *messageText;

@property (nonatomic) RODHandle *fromHandle;
@property (nonatomic) RODThread *thread;

@end
