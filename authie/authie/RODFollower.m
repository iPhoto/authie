//
//  RODFollower.m
//  authie
//
//  Created by Seth Hayward on 1/9/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODFollower.h"

@implementation RODFollower

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.followerId forKey:@"followerId"];
    [aCoder encodeObject:self.followeeId forKey:@"followeeId"];
    [aCoder encodeObject:self.active forKey:@"active"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"id"] integerValue]]];
        [self setFollowerId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"followerId"] integerValue]]];
        [self setFolloweeId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"followeeId"] integerValue]]];
        [self setActive:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"active"] integerValue]]];
        
    }
    return self;
}


@end
