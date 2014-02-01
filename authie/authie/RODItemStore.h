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
@class NavigationController;

@interface RODItemStore : NSObject <SRConnectionDelegate, NSURLConnectionDataDelegate>
{
    RODAuthie *_authie;
}

@property (strong, nonatomic) NSMutableArray *loadedThreadsFromAuthor;
@property (strong, nonatomic) NSMutableArray *dailyThreads;
@property (strong, nonatomic) SRHubConnection *hubConnection;
@property (strong, nonatomic) SRHubProxy *hubProxy;
@property (strong, nonatomic) NSString *mostRecentGroupKey;

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
- (void)sendNotes:(NSString *)groupKey;
- (void)report:(NSString *)groupKey;
- (void)giveLove:(NSString *)groupKey;
- (void)sendChat:(NSString *)groupKey message:(NSString *)msg;
- (void)invite:(NSString *)email message:(NSString *)msg;

- (void)addChat:(NSString *)user message:(NSString *)message groupKey:(NSString *)groupKey;
- (void)loadMessages;
- (void)loadMessagesForThread:(NSString *)key;
- (BOOL)loadThreads;
- (BOOL)loadContacts;
- (BOOL)checkLoginStatus;
- (BOOL)getHandleInformation;
- (BOOL)startThread:(NSString *)toHandle forKey:(NSString *)key withCaption:(NSString *)caption;
- (BOOL)getThreadsFromHandle:(NSString *)publicKey;
- (BOOL)uploadSnap:(NSString *)key;
- (BOOL)addContact:(NSString *)handle;
- (UIView *)generateHeaderView;
- (UIBarButtonItem *)generateSettingsCog:(UIViewController *)target;

- (void)pushThreadWithGroupKey:(NSString *)group_key;
- (void)addMessage:(NSString *)user message:(NSString *)msg groupKey:(NSString *)key;


@end

