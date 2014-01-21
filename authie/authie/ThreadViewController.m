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
        
        loadRow = -1;
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeThread:)];
        
        self.navigationItem.rightBarButtonItem = edit;
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[[RODItemStore sharedStore] loadMessages];
}

- (IBAction)tappedScreen:(id)sender {
    NSLog(@"Do stuffed.");
}

- (void)reloadThread
{
    NSLog(@"reload thread....");
    if(loadRow != -1) {
        [self resetChatObjects];
        [self loadThread:loadRow];
    }
}

- (void)resetChatObjects
{
    [self.messages removeAllObjects];
    [self.subtitles removeAllObjects];
    [self.timestamps removeAllObjects];
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
    
    self.title = @"Messages";
    
    self.messageInputView.textView.placeHolder = @"New Message";
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.view setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
    [self.view addGestureRecognizer:tapView];

    self.messages = [[NSMutableArray alloc] init];
    
    self.timestamps = [[NSMutableArray alloc] init];
    
    self.subtitles = [[NSMutableArray alloc] init];
    
    self.avatars = [[NSDictionary alloc] init];
    
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


-(void)removeThread:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[RODItemStore sharedStore] removeThread:self.thread];
}

-(void)loadThread:(int)row
{
    
    [self resetChatObjects];
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
    
    if([self.thread.toHandleId isEqualToString:@"profile"]) {
        self.navigationItem.title = @"profile snap";
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"to: %@, from: %@", thread.toHandleId, thread.fromHandleId];
    }
    
    self.snapDate.text = [self.thread.startDate prettyDate];
    
    // now load all the messages that are associated with this thread
    
    for(int i = 0; i < [[RODItemStore sharedStore].authie.all_Messages count]; i++) {
        
        RODMessage *msg = [[RODItemStore sharedStore].authie.all_Messages objectAtIndex:i];
        
        if([msg.thread.groupKey isEqualToString:self.thread.groupKey]) {
            [self.timestamps addObject:msg.sentDate];
            [self.messages addObject:msg.messageText];
            [self.subtitles addObject:msg.fromHandle.name];
        }
        
    }
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
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

    [self.tableView setHidden:NO];
    
    [self.subtitles addObject:[RODItemStore sharedStore].authie.handle.name];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    [[RODItemStore sharedStore] sendChat:self.thread.groupKey message:text];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row % 2) {
//        return [JSBubbleImageViewFactory bubbleImageViewForType:type
//                                                          color:[UIColor js_bubbleLightGrayColor]];
//    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
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
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
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
