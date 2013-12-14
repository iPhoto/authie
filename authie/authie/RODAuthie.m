//
//  RODAuthie.m
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODAuthie.h"

@implementation RODAuthie
@synthesize authieHandle, authieKey, registered;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:authieKey forKey:@"authieKey"];
    [aCoder encodeObject:authieHandle forKey:@"authieHandle"];
    [aCoder encodeBool:registered forKey:@"registered"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setAuthieKey:[aDecoder decodeObjectForKey:@"authieKey"]];
        [self setAuthieHandle:[aDecoder decodeObjectForKey:@"authieHandle"]];
        [self setRegistered:(bool *)[aDecoder decodeBoolForKey:@"registered"]];
    }
    return self;
}

@end
