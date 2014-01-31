//
//  RODAuthie.m
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODAuthie.h"
#import "RODSelfie.h"
#import "RODHandle.h"

@implementation RODAuthie
@synthesize authieHandle, privateKey, registered, allSelfies, allThreads, handle, allContacts, allMessages;

- (NSArray *)all_Messages
{
    return allMessages;
}

- (NSArray *)all_Selfies
{
    return allSelfies;
}

- (NSArray *)all_Threads
{
    return allThreads;
}

- (NSArray *)all_Contacts
{
    return allContacts;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:privateKey forKey:@"privateKey"];
    [aCoder encodeObject:authieHandle forKey:@"authieHandle"];
    [aCoder encodeInt:registered forKey:@"registered"];
    [aCoder encodeObject:allSelfies forKey:@"allSelfies"];
    [aCoder encodeObject:allContacts forKey:@"allContacts"];
    [aCoder encodeObject:allMessages forKey:@"allMessages"];
    
    [aCoder encodeObject:handle forKey:@"handle"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setPrivateKey:[aDecoder decodeObjectForKey:@"privateKey"]];
        [self setAuthieHandle:[aDecoder decodeObjectForKey:@"authieHandle"]];
        [self setRegistered:[aDecoder decodeIntForKey:@"registered"]];
        [self setHandle:[aDecoder decodeObjectForKey:@"handle"]];
        allSelfies = [aDecoder decodeObjectForKey:@"allSelfies"];
        allContacts = [aDecoder decodeObjectForKey:@"allContacts"];
        allMessages = [aDecoder decodeObjectForKey:@"allMessages"];
    }
    return self;
}

@end
