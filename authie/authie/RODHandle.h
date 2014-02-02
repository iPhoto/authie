//
//  RODHandle.h
//  authie
//
//  Created by Seth Hayward on 12/27/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODHandle : NSObject <NSCoding>

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *active;
@property (nonatomic) NSString *userGuid;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *mostRecentSnap;

@end
