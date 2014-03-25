//
//  RODChat.m
//  authie
//
//  Created by Seth Hayward on 3/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODChat.h"

@implementation RODChat
@synthesize message, groupKey, toKey, messageKey;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.groupKey forKey:@"groupKey"];
    [aCoder encodeObject:self.toKey forKey:@"toKey"];
    [aCoder encodeObject:self.messageKey forKey:@"messageKey"];
    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setMessage:[aDecoder decodeObjectForKey:@"message"]];
        [self setGroupKey:[aDecoder decodeObjectForKey:@"groupKey"]];
        [self setToKey:[aDecoder decodeObjectForKey:@"toKey"]];
        [self setMessageKey:[aDecoder decodeObjectForKey:@"messageKey"]];
    }
    return self;
}


@end

