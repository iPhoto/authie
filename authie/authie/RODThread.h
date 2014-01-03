//
//  RODThread.h
//  authie
//
//  Created by Seth Hayward on 1/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODThread : NSObject <NSCoding>

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *fromHandleId;
@property (nonatomic) NSString *toHandleId;
@property (nonatomic) NSString *groupKey;
@property (nonatomic) NSDate *startDate;

@end
