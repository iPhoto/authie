//
//  ThreadViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <JSMessagesViewController/JSMessagesViewController.h>
#import "ThreadViewController.h"
#import "RODImageStore.h"
#import "RODItemStore.h"
#import "RODThread.h"
#import "RODAuthie.h"
#import "RODHandle.h"
#import "RODMessage.h"
#import "NSDate+PrettyDate.h"

@implementation ThreadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        [self setEdgesForExtendedLayout:UIRectEdgeNone];

        self.messages = [[NSMutableArray alloc] init];
        
        self.timestamps = [[NSMutableArray alloc] init];
        
        self.subtitles = [[NSMutableArray alloc] init];
        
        self.avatars = [[NSDictionary alloc] init];
        
        self.messageType = [[NSMutableArray alloc] init];
        
        
        loadRow = -1;
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeThread:)];
        
        self.navigationItem.rightBarButtonItem = edit;
        
        
    }
    return self;
}

- (void)setThreadIndex:(int)row;
{
    loadRow = row;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *button_heart = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_heart setFrame:CGRectMake(0, 0, 20, 20)];
    [button_heart setImage:[UIImage imageNamed:@"heart-blue-v2.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_heart];
    self.navigationItem.rightBarButtonItem = rightDrawerButton;
    
}

- (IBAction)tappedScreen:(id)sender {
    NSLog(@"Do stuffed.");
}

- (void)reloadThread
{
    
    if(loadRow != -1) {
        NSLog(@"Reloaded thread.");
        [self resetChatObjects];
        [self loadThread:loadRow];
        [self.snapView setNeedsUpdateConstraints];

    }
}

- (void)resetChatObjects
{
    [self.messages removeAllObjects];
    [self.subtitles removeAllObjects];
    [self.timestamps removeAllObjects];
    [self.messageType removeAllObjects];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetChatObjects];
    
    [self loadThread:loadRow];
    [self.snapView setNeedsUpdateConstraints];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    [self.snapView setImage:[UIImage alloc]];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
        
    self.messageInputView.textView.placeHolder = @"New Message";
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.view setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
    [self.view addGestureRecognizer:tapView];
    
    [[RODItemStore sharedStore].hubConnection disconnect];
    // connect to signalr for realtime
    // Connect to the service
    [RODItemStore sharedStore].hubConnection = [SRHubConnection connectionWithURL:@"http://authie.me/"];
    
    [RODItemStore sharedStore].hubConnection.delegate = [[RODItemStore sharedStore] self];
    
    // Create a proxy to the chat service
    [RODItemStore sharedStore].hubProxy = [[RODItemStore sharedStore].hubConnection createHubProxy:@"authhub"];
    
    [RODItemStore sharedStore].hubConnection.received = ^(NSString * data) {
        NSLog(@"receieved: %@", data);
    };
    
    [RODItemStore sharedStore].hubConnection.started = ^{
        
        [[RODItemStore sharedStore].hubProxy invoke:@"join" withArgs:[NSArray arrayWithObject:@"ok"]];
        [[RODItemStore sharedStore].hubProxy on:@"addMessage" perform:self selector:@selector(addMessage:message:groupKey:)];
        
        NSLog(@"Started.");
        
    };

    [RODItemStore sharedStore].hubConnection.error = ^(NSError *__strong err){
        NSLog(@"there was an error... go back home...");

        [self dismissViewControllerAnimated:NO completion:nil];

        
    };
    
    // Start the connection
    [[RODItemStore sharedStore].hubConnection start];
        

    NSLog(@"About to reload.");
    
    [self reloadThread];
    [[RODItemStore sharedStore] loadMessagesForThread:self.thread.groupKey];

    NSLog(@"Reload.");
    
}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{

    if(self.tableView.hidden == YES) {
        [self.tableView setHidden:NO];
        [self.messageInputView setHidden:NO];
    } else {
        [self.tableView setHidden:YES];
        [self.messageInputView endEditing:YES];
        [self.messageInputView setHidden:YES];
    }
    
}


- (void)addMessage:(NSString *)user message:(NSString *)msg groupKey:(NSString *)key
{
    NSLog(@"addMessage, thread: %@, %@, %@, %i", user, msg, key, [RODItemStore sharedStore].hubConnection.state);
    [[RODItemStore sharedStore] addChat:user message:msg groupKey:key];

    [self reloadThread];
}

-(void)removeThread:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[RODItemStore sharedStore] removeThread:self.thread];
}

-(void)loadThread:(int)row
{
 
    NSLog(@"loadThread");
    NSString *currentMessage = self.messageInputView.textView.text;
    
    [self resetChatObjects];
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
     
    if([thread.toHandle.name isEqualToString:[RODItemStore sharedStore].authie.handle.name]) {
        self.navigationItem.title = [NSString stringWithFormat:@"chat with %@", thread.fromHandleId];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"chat with %@", thread.toHandleId];
    }
    
    self.snapDate.text = [self.thread.startDate prettyDate];
    
    // now load all the messages that are associated with this thread
    
    for(int i = 0; i < [[RODItemStore sharedStore].authie.all_Messages count]; i++) {
        
        RODMessage *msg = [[RODItemStore sharedStore].authie.all_Messages objectAtIndex:i];
        
        if([msg.thread.groupKey isEqualToString:self.thread.groupKey]) {
            
            [self.timestamps addObject:msg.sentDate];
            [self.messages addObject:msg.messageText];
            [self.subtitles addObject:msg.fromHandle.name];
            
            if([msg.fromHandle.name isEqualToString:[RODItemStore sharedStore].authie.handle.name])
            {
                // indicates outgoing
                [self.messageType addObject:@"1"];
            } else {
                // incoming
                [self.messageType addObject:@"0"];
            }
        }
        
    }
    
    
    if([thread.groupKey isEqualToString:@"2fde7af1-b92b-4642-b3e8-aef43f57ed31"]) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"chat with vronica"];
        
        [self resetChatObjects];

        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:-3600*6];
        
        [self.messages insertObject:@"The Bro Rises" atIndex:0];
        [self.subtitles insertObject:@"vronica" atIndex:0];
        [self.timestamps insertObject:newDate atIndex:0];
        [self.messageType insertObject:@"0" atIndex:0];
        
        [self.messages insertObject:@"Lolol" atIndex:1];
        [self.subtitles insertObject:@"geofsf" atIndex:1];
        [self.timestamps insertObject:newDate atIndex:1];
        [self.messageType insertObject:@"1" atIndex:1];

        [self.messages insertObject:@"just got to the park" atIndex:2];
        [self.subtitles insertObject:@"vronica" atIndex:2];
        [self.timestamps insertObject:newDate atIndex:2];
        [self.messageType insertObject:@"0" atIndex:2];

        [self.messages insertObject:@"how's Brolores today" atIndex:3];
        [self.subtitles insertObject:@"geofsf" atIndex:3];
        [self.timestamps insertObject:newDate atIndex:3];
        [self.messageType insertObject:@"1" atIndex:3];

        [self.messages insertObject:@"chill you should come by" atIndex:4];
        [self.subtitles insertObject:@"vronica" atIndex:4];
        [self.timestamps insertObject:newDate atIndex:4];
        [self.messageType insertObject:@"0" atIndex:4];

        [self.messageInputView.textView setText:@"k"];
        
    }
    
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
                                                                                                                                                                                                       
    self.messageInputView.textView.text = currentMessage;

    
    loadRow = row;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setThreadRow:(int)row
{
    loadRow = row;
}


- (void)didSendText:(NSString *)text
{
    
    [self.messages addObject:text];
    
    [self.timestamps addObject:[NSDate date]];
    
    [self.messageType addObject:@"1"];
    
    [self.tableView setHidden:NO];
    
    [self.subtitles addObject:[RODItemStore sharedStore].authie.handle.name];

    [[RODItemStore sharedStore] addChat:[RODItemStore sharedStore].authie.handle.name message:text groupKey:self.thread.groupKey];    

    [self finishSend];
    [self scrollToBottomAnimated:YES];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] sendChat:self.thread.groupKey message:text];

        NSLog(@"state: %i", [RODItemStore sharedStore].hubConnection.state);
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            
            // nothing?
        });
    });
    
    
    
    
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[self.messageType objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.messageType objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    } else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    }
    
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryFive;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor whiteColor];
        cell.timestampLabel.shadowColor = [UIColor blackColor];
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor whiteColor];
        cell.subtitleLabel.shadowColor = [UIColor blackColor];
    }
}

//  *** Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
//
//  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subtitle = [self.subtitles objectAtIndex:indexPath.row];
    UIImage *image = [self.avatars objectForKey:subtitle];
    return [[UIImageView alloc] initWithImage:image];
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.subtitles objectAtIndex:indexPath.row];
}


@end
