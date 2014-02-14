//
//  RODThread.h
//  authie
//
//  Created by Seth Hayward on 1/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RODHandle;

@interface RODThread : NSObject <NSCoding>

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *fromHandleId;
@property (nonatomic) NSString *toHandleId;
@property (nonatomic) NSString *groupKey;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSString *caption;
@property (nonatomic) NSString *location;
@property (nonatomic) NSNumber *hearts;
@property (nonatomic) NSNumber *authorizeRequest;
@property (nonatomic) NSNumber *toHandleSeen;
@property (nonatomic) Boolean successfulUpload;
@property (nonatomic) NSString *font;
@property (nonatomic) NSString *textColor;

@property (nonatomic) RODHandle *fromHandle;
@property (nonatomic) RODHandle *toHandle;

@end
