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
    
}

- (IBAction)tappedScreen:(id)sender {
    NSLog(@"Do stuffed.");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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


    self.messages = [[NSMutableArray alloc] init];
    
    self.timestamps = [[NSMutableArray alloc] init];
    
    self.subtitles = [[NSMutableArray alloc] init];
    
    self.avatars = [[NSDictionary alloc] init];
    
}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{

//    if(self.tableView.hidden == YES) {
//        [self.tableView setHidden:NO];
//        [self.viewDetails setHidden:YES];
//    } else {
//        [self.tableView setHidden:YES];
//        [self.viewDetails setHidden:NO];
//    }
        
        
    NSLog(@"Hello friends i am here");
    
}


-(void)removeThread:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[RODItemStore sharedStore] removeThread:self.thread];
}

-(void)loadThread:(int)row
{
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
    
    if([self.thread.toHandleId isEqualToString:@"profile"]) {
        self.navigationItem.title = @"profile snap";
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"to: %@, from: %@", thread.toHandleId, thread.fromHandleId];
    }
    
    self.snapDate.text = [self.thread.startDate prettyDate];
    
    if(self.thread.caption == (id)[NSNull null] || self.thread.caption.length == 0 ) {
        self.snapCaption.text = @"";
    } else {

        [self.timestamps addObject:self.thread.startDate];
        [self.messages addObject:self.thread.caption];
        [self.subtitles addObject:self.thread.fromHandleId];
        [self finishSend];
        [self scrollToBottomAnimated:YES];
        
    }
    
    
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

    [self.subtitles addObject:[RODItemStore sharedStore].authie.handle.name];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
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
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
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
