//
//  RODFollower.h
//  authie
//
//  Created by Seth Hayward on 1/9/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RODHandle.h"

@interface RODFollower : NSObject <NSCoding>

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSNumber *followerId;
@property (nonatomic) NSNumber *followeeId;
@property (nonatomic) NSNumber *active;
@property (nonatomic) NSString *mostRecentSnap;

@property (nonatomic) RODHandle *followeeHandle;
@property (nonatomic) RODHandle *followerHandle;

@end
