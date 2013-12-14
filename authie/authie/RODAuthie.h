//
//  RODAuthie.h
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODAuthie : NSObject <NSCoding>

@property (nonatomic, strong) NSString *authieHandle;
@property (nonatomic, strong) NSDate *authieKey;
@property (nonatomic) BOOL *registered;


@end
