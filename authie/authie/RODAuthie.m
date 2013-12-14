//
//  RODAuthie.m
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODAuthie.h"
#import "RODSelfie.h"

@implementation RODAuthie
@synthesize authieHandle, authieKey, registered, allSelfies;

- (NSArray *)all_Selfies
{
    return allSelfies;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:authieKey forKey:@"authieKey"];
    [aCoder encodeObject:authieHandle forKey:@"authieHandle"];
    [aCoder encodeInt:registered forKey:@"registered"];
    [aCoder encodeObject:allSelfies forKey:@"allSelfies"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setAuthieKey:[aDecoder decodeObjectForKey:@"authieKey"]];
        [self setAuthieHandle:[aDecoder decodeObjectForKey:@"authieHandle"]];
        [self setRegistered:[aDecoder decodeIntForKey:@"registered"]];
        allSelfies = [aDecoder decodeObjectForKey:@"allSelfies"];
    }
    return self;
}

@end
