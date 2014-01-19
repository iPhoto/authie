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
@class RODHandle;
@class NavigationController;

@interface RODItemStore : NSObject
{
    RODAuthie *_authie;
}

@property (strong, nonatomic) NSMutableArray *loadedThreadsFromAuthor;
@property (strong, nonatomic) NSMutableArray *dailyThreads;

+ (RODItemStore *)sharedStore;

- (RODAuthie *)authie;

- (NSString *)itemArchivePath;

- (RODSelfie *)createSelfie:(NSString *)key;
- (void) removeThread:(RODThread *)thread;

- (void) removeContact:(RODHandle *)handle;
- (void) authorizeContact:(NSString *)publicKey;

- (BOOL)saveChanges;
- (BOOL)checkHandleAvailability:(NSString *)handle;
- (BOOL)registerHandle:(NSString *)handle;
- (BOOL)login:(NSString *)handle privateKey:(NSString *)key;
- (void)report:(NSString *)groupKey;
- (void)giveLove:(NSString *)groupKey;
- (void)invite:(NSString *)email message:(NSString *)msg;
- (void)loadDaily;
- (BOOL)loadThreads;
- (BOOL)loadContacts;
- (BOOL)checkLoginStatus;
- (BOOL)getHandleInformation;
- (BOOL)startThread:(NSString *)toHandle forKey:(NSString *)key withCaption:(NSString *)caption;
- (BOOL)getThreadsFromHandle:(NSString *)publicKey;
- (BOOL)uploadSnap:(NSString *)key;
- (BOOL)addContact:(NSString *)handle;
- (UIView *)generateHeaderView;
- (UIView *)generateDailyView;
- (UIBarButtonItem *)generateSettingsCog:(UIViewController *)target;

@end

