//
//  RODMessage.m
//  authie
//
//  Created by Seth Hayward on 1/19/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODMessage.h"

@implementation RODMessage
@synthesize active, anon, fromHandle, id, messageText, thread, seen, sentDate, toKey, localNotificationSent, groupKey, messageKey;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.fromHandle forKey:@"fromHandle"];
    [aCoder encodeObject:self.thread forKey:@"thread"];
    [aCoder encodeObject:self.sentDate forKey:@"sentDate"];
    [aCoder encodeObject:self.active forKey:@"active"];
    [aCoder encodeObject:self.anon forKey:@"anon"];
    [aCoder encodeObject:self.seen forKey:@"seen"];
    [aCoder encodeObject:self.messageText forKey:@"messageText"];
    [aCoder encodeObject:self.toKey forKey:@"toKey"];
    [aCoder encodeObject:self.localNotificationSent forKey:@"localNotificationSent"];
    [aCoder encodeObject:self.groupKey forKey:@"groupKey"];
    [aCoder encodeObject:self.messageKey forKey:@"messageKey"];
    
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
        [self setSeen:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"seen"] integerValue]]];
        [self setMessageText:[aDecoder decodeObjectForKey:@"messageText"]];
        [self setToKey:[aDecoder decodeObjectForKey:@"toKey"]];
        [self setLocalNotificationSent:[NSNumber numberWithInteger:[[aDecoder decodeObjectForKey:@"localNotificationSent"] integerValue]]];
        [self setGroupKey:[aDecoder decodeObjectForKey:@"groupKey"]];
        [self setMessageKey:[aDecoder decodeObjectForKey:@"messageKey"]];
        
    }
    return self;
}

- (NSComparisonResult)compare:(RODMessage *)otherObject {
    return [self.sentDate compare:otherObject.sentDate];
}

@end
