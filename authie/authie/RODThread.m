//
//  RODThread.m
//  authie
//
//  Created by Seth Hayward on 1/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODThread.h"

@implementation RODThread

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.fromHandleId forKey:@"fromHandleId"];
    [aCoder encodeObject:self.toHandleId forKey:@"toHandleId"];
    [aCoder encodeObject:self.groupKey forKey:@"groupKey"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"id"] integerValue]]];
        [self setFromHandleId:[aDecoder decodeObjectForKey:@"fromHandleId"]];
        [self setToHandleId:[aDecoder decodeObjectForKey:@"toHandleId"]];
        [self setGroupKey:[aDecoder decodeObjectForKey:@"groupKey"]];
        [self setStartDate:[aDecoder decodeObjectForKey:@"startDate"]];
    }
    return self;
}


@end
