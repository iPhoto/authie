//
//  RODAuthie.h
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RODSelfie;

@interface RODAuthie : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *allSelfies;
@property (nonatomic, strong) NSString *authieHandle;
@property (nonatomic, strong) NSString *authieKey;
@property (nonatomic, strong) NSString *authiePublicKey;
@property (nonatomic, strong) NSString *authiePrivateKey;
@property (nonatomic) int registered;

- (NSArray *)all_Selfies;

@end
