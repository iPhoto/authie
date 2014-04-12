//
//  RODItemStore.h
//  selfies
//
//  Created by Seth Hayward on 11/14/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SignalR-ObjC/SignalR.h>

@class RODSelfie;
@class RODAuthie;
@class RODThread;
@class RODHandle;
@class RODMessage;
@class NavigationController;

@interface RODItemStore : NSObject <SRConnectionDelegate, NSURLConnectionDataDelegate>
{
    RODAuthie *_authie;
}

@property (strong, nonatomic) NSMutableArray *loadedThreadsFromAuthor;
@property (strong, nonatomic) NSMutableArray *wireThreads;
@property (strong, nonatomic) SRHubConnection *hubConnection;
@property (strong, nonatomic) SRHubProxy *hubProxy;
@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) NSString *mostRecentGroupKey;
@property (nonatomic) int currentPage;

+ (RODItemStore *)sharedStore;
- (UIColor *)colorFromHexString:(NSString *)hexString;

- (RODAuthie *)authie;

- (NSString *)itemArchivePath;

- (RODSelfie *)createSelfie:(NSString *)key;
- (void) removeThread:(RODThread *)thread;

- (void) removeContact:(RODHandle *)handle;
- (void) authorizeContact:(NSString *)publicKey;

- (BOOL)saveChanges;
- (BOOL)checkHandleAvailability:(NSString *)handle;
- (BOOL)registerHandle:(NSString *)handle;
- (NSString *)login:(NSString *)handle privateKey:(NSString *)key;
- (void)report:(NSString *)groupKey;
- (void)giveLove:(NSString *)groupKey;
- (void)sendChat:(NSString *)groupKey message:(NSString *)msg toKey:(NSString *)toKey messageKey:(NSString *)key;
- (void)getPrivateKey;
- (NSString *)addChat:(NSString *)user message:(NSString *)message groupKey:(NSString *)groupKey toKey:(NSString *)toKey;
- (void)addChatById:(NSString *)user message:(NSString *)message groupKey:(NSString *)groupKey toKey:(NSString *)toKey messageId:(NSNumber *)mId;
- (void)addBlock:(NSString *)publicKey;
- (void)loadBlocks;
- (void)loadMessages:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)loadMessagesForThread:(NSString *)key;
- (BOOL)loadThreads:(bool)isWire;
- (BOOL)loadContacts;
- (BOOL)checkLoginStatus;
- (BOOL)getHandleInformation;
- (BOOL)startThread:(NSString *)toHandle forKey:(NSString *)key withCaption:(NSString *)caption withLocation:(NSString *)location withFont:(NSString *)font withTextColor:(NSString *)textColor;
- (BOOL)getThreadsFromHandle:(NSString *)publicKey;
- (BOOL)uploadSnap:(NSString *)key;
- (BOOL)addContact:(NSString *)handle fromDash:(BOOL)dash;
- (UIView *)generateHeaderView;
- (UIView *)generateWireHeaderView;
- (UIBarButtonItem *)generateMenuItem:(NSString *)menu;
- (UIBarButtonItem *)generateAddPersonMenuItem;

- (void)markMessageAsRead:(NSNumber *)id;
- (void)markRead;
- (int)unreadMessages;
- (int)unreadMessagesFor:(NSString *)thread handle:(NSString *)contactHandle;
- (void)sendUnsentLocalNotifications;

- (void)retrySendingFailedChats;
- (void)sendLocalNotification:(RODMessage *)msg;

- (void)pushThreadWithGroupKey:(NSString *)group_key from:(NSString *)fromKey;

@end

