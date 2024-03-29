//
//  RODAuthie.h
//  authie
//
//  Created by Seth Hayward on 12/13/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RODSelfie;
@class RODHandle;

@interface RODAuthie : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *allMessages;
@property (nonatomic, strong) NSMutableArray *allThreads;
@property (nonatomic, strong) NSMutableArray *allSelfies;
@property (nonatomic, strong) NSMutableArray *allContacts;
@property (nonatomic, strong) NSMutableArray *failedChats;
@property (nonatomic, strong) RODHandle *handle;
@property (nonatomic, strong) NSString *authieHandle;
@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic) int registered;

- (NSArray *)all_Messages;
- (NSArray *)all_Contacts;
- (NSArray *)all_Selfies;
- (NSArray *)all_Threads;

@end
