//
//  RODHandle.m
//  authie
//
//  Created by Seth Hayward on 12/27/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODHandle.h"

@implementation RODHandle


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.active forKey:@"active"];
    [aCoder encodeObject:self.userGuid forKey:@"userGuid"];
    [aCoder encodeObject:self.privateKey forKey:@"privateKey"];
    [aCoder encodeObject:self.publicKey forKey:@"publicKey"];
    [aCoder encodeObject:self.mostRecentSnap forKey:@"mostRecentSnap"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"id"] integerValue]]];
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setActive:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"active"] integerValue]]];
        [self setUserGuid:[aDecoder decodeObjectForKey:@"userGuid"]];
        [self setPrivateKey:[aDecoder decodeObjectForKey:@"privateKey"]];
        [self setPublicKey:[aDecoder decodeObjectForKey:@"publicKey"]];
        [self setMostRecentSnap:[aDecoder decodeObjectForKey:@"mostRecentSnap"]];
    }
    return self;
}


@end
