//
//  RODItemStore.h
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RODSelfie;
@class RODAuthie;

@interface RODItemStore : NSObject
{
    RODAuthie *_authie;
}

@property (nonatomic, retain) RODSelfie *recentSelfie;

+ (RODItemStore *)sharedStore;

- (RODAuthie *)authie;

- (NSString *)itemArchivePath;

- (RODSelfie *)createSelfie:(NSString *)key;
- (void) removeSelfie:(NSInteger)index;

- (BOOL)saveChanges;
- (BOOL)checkHandleAvailability:(NSString *)handle;

@end

