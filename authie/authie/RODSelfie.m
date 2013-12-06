//
//  RODSelfie.m
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODSelfie.h"

@implementation RODSelfie
@synthesize selfieDate, selfieKey;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:selfieDate forKey:@"selfieDate"];
    [aCoder encodeObject:selfieKey forKey:@"selfieKey"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setSelfieDate:[aDecoder decodeObjectForKey:@"selfieDate"]];
        [self setSelfieKey:[aDecoder decodeObjectForKey:@"selfieKey"]];
    }
    return self;
}
@end
