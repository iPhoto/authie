//
//  RODChat.h
//  authie
//
//  Created by Seth Hayward on 3/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODChat : NSObject

// - (void)sendChat:(NSString *)groupKey message:(NSString *)msg  toKey:(NSString *)toKey

@property (nonatomic) NSString *groupKey;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *toKey;

@end
