//
//  RODSelfie.h
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODSelfie : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *selfieDate;
@property (nonatomic, copy) NSString *selfieKey;

@end
