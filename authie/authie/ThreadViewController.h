//
//  ThreadViewController.h
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RODThread.h"
#import <JSMessagesViewController/JSMessagesViewController.h>

@interface ThreadViewController : JSMessagesViewController <UIScrollViewDelegate, JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *snapDate;
@property (weak, nonatomic) IBOutlet UIView *viewDetails;

@property (weak, nonatomic) IBOutlet UILabel *threadFrom;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (strong, nonatomic) RODThread *thread;
@property (strong, nonatomic) RODHandle *toHandle;

@property (weak, nonatomic) IBOutlet UILabel *snapCaption;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) NSMutableArray *messageType;
@property (strong, nonatomic) NSMutableArray *hasTimeStamp;

@property (nonatomic) int loadRow;

- (void)setThread:(RODThread *)new_thread;
- (void)loadThread:(int)row;
- (void)reloadThread;
- (void)setThreadIndex:(int)row;

@end
