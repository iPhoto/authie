//
//  RODThread.m
//  authie
//
//  Created by Seth Hayward on 1/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODThread.h"

@implementation RODThread
@synthesize authorizeRequest, hearts, toHandleSeen, caption, fromHandle, toHandle, successfulUpload,
    groupKey, location, font, textColor, convos;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.fromHandleId forKey:@"fromHandleId"];
    [aCoder encodeObject:self.toHandleId forKey:@"toHandleId"];
    [aCoder encodeObject:self.groupKey forKey:@"groupKey"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.caption forKey:@"caption"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.authorizeRequest forKey:@"authorizeRequest"];
    [aCoder encodeObject:self.hearts forKey:@"hearts"];
    [aCoder encodeBool:self.successfulUpload forKey:@"successfulUpload"];
    [aCoder encodeObject:self.font forKey:@"font"];
    [aCoder encodeObject:self.textColor forKey:@"textColor"];
    [aCoder encodeObject:self.convos forKey:@"convos"];
    
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
        [self setCaption:[aDecoder decodeObjectForKey:@"caption"]];
        [self setLocation:[aDecoder decodeObjectForKey:@"location"]];
        [self setSuccessfulUpload:[aDecoder decodeBoolForKey:@"successfulUpload"]];
        [self setFont:[aDecoder decodeObjectForKey:@"font"]];
        [self setTextColor:[aDecoder decodeObjectForKey:@"textColor"]];
        convos = [aDecoder decodeObjectForKey:@"convos"];

        id hearts_result = [aDecoder decodeObjectForKey:@"hearts"];
        if(hearts_result == [NSNull null]) {
            [self setHearts:[NSNumber numberWithInteger:0]];
        } else {
            [self setHearts:[NSNumber numberWithInteger:[hearts_result integerValue]]];
        }

        id authorize_result = [aDecoder decodeObjectForKey:@"authorizeResult"];
        if(authorize_result == [NSNull null]) {
            [self setAuthorizeRequest:[NSNumber numberWithInteger:0]];
        } else {
            [self setAuthorizeRequest:[NSNumber numberWithInteger:[authorize_result integerValue]]];
        }

        
    }
    return self;
}


@end
