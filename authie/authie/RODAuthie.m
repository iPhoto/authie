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
@synthesize authieHandle, privateKey, registered, allSelfies, allThreads, handle, allContacts;

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

- (NSArray *)all_ContactsWithEverybody
{
    NSMutableArray *before = [[NSMutableArray alloc] initWithArray:allContacts];
    
    RODHandle *everyone = [[RODHandle alloc] init];
    everyone.id = [NSNumber numberWithInt:1];
    everyone.name = @"profile";
    everyone.publicKey = @"1";

    RODHandle *daily = [[RODHandle alloc] init];
    daily.id = [NSNumber numberWithInt:2];
    daily.name = @"the daily";
    daily.publicKey = @"2";

    [before insertObject:everyone atIndex:0];
    [before insertObject:daily atIndex:1];
    
    return before;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:privateKey forKey:@"privateKey"];
    [aCoder encodeObject:authieHandle forKey:@"authieHandle"];
    [aCoder encodeInt:registered forKey:@"registered"];
    [aCoder encodeObject:allSelfies forKey:@"allSelfies"];
    [aCoder encodeObject:allContacts forKey:@"allContacts"];
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
    }
    return self;
}

@end
