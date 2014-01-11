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
@class RODThread;
@class NavigationController;

@interface RODItemStore : NSObject
{
    RODAuthie *_authie;
}

@property (weak, nonatomic) NSMutableArray *loadedThreadsFromAuthor;

+ (RODItemStore *)sharedStore;

- (RODAuthie *)authie;

- (NSString *)itemArchivePath;

- (RODSelfie *)createSelfie:(NSString *)key;
- (void) removeThread:(RODThread *)thread;

- (BOOL)saveChanges;
- (BOOL)checkHandleAvailability:(NSString *)handle;
- (BOOL)registerHandle:(NSString *)handle;
- (BOOL)login;
- (BOOL)loadThreads;
- (BOOL)checkLoginStatus;
- (BOOL)startThread:(NSString *)toHandle forKey:(NSString *)key;
- (BOOL)getThreadsFromHandle:(NSString *)publicKey;
- (BOOL)uploadSnap:(NSString *)key;
- (BOOL)addContact:(NSString *)handle;
- (UIView *)generateHeaderView;
- (UIBarButtonItem *)generateSettingsCog:(UIViewController *)target;

@end

