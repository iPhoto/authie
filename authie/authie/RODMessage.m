//
//  RODMessage.m
//  authie
//
//  Created by Seth Hayward on 1/19/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODMessage.h"

@implementation RODMessage
@synthesize active, anon, fromHandle, id, messageText, thread, toHandleSeen, sentDate;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.fromHandle forKey:@"fromHandle"];
    [aCoder encodeObject:self.thread forKey:@"thread"];
    [aCoder encodeObject:self.sentDate forKey:@"sentDate"];
    [aCoder encodeObject:self.active forKey:@"active"];
    [aCoder encodeObject:self.anon forKey:@"anon"];
    [aCoder encodeObject:self.toHandleSeen forKey:@"toHandleSeen"];
    [aCoder encodeObject:self.messageText forKey:@"messageText"];
    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setId:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"id"] integerValue]]];
        [self setFromHandle:[aDecoder decodeObjectForKey:@"fromHandle"]];
        [self setThread:[aDecoder decodeObjectForKey:@"thread"]];
        [self setSentDate:[aDecoder decodeObjectForKey:@"sentDate"]];
        [self setActive:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"active"] integerValue]]];
        [self setAnon:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"anon"] integerValue]]];
        [self setToHandleSeen:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"toHandleSeen"] integerValue]]];
        [self setMessageText:[aDecoder decodeObjectForKey:@"messageText"]];        
    }
    return self;
}

- (NSComparisonResult)compare:(RODMessage *)otherObject {
    return [self.sentDate compare:otherObject.sentDate];
}

@end
