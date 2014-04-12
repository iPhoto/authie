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
#import <Social/Social.h>

@implementation ThreadViewController
@synthesize toHandle, tweetImage, loadedThreadKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        [self setEdgesForExtendedLayout:UIRectEdgeNone];

        self.messages = [[NSMutableArray alloc] init];
        
        self.timestamps = [[NSMutableArray alloc] init];
        
        self.hasTimeStamp = [[NSMutableArray alloc] init];
        
        self.subtitles = [[NSMutableArray alloc] init];
        
        self.avatars = [[NSDictionary alloc] init];
        
        self.messageType = [[NSMutableArray alloc] init];
                
        UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_menu setFrame:CGRectMake(0, 0, 25, 25)];
        [button_menu setImage:[UIImage imageNamed:@"heart-white-v1"] forState:UIControlStateNormal];
        [button_menu addTarget:self action:@selector(sendLove:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];

        self.navigationItem.rightBarButtonItem = rightDrawerButton;
        
        loadedThreadKey = @"";
        
//        UIButton *button_tweet = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button_tweet setFrame:CGRectMake(0, 0, 25, 25)];
//        [button_tweet setImage:[UIImage imageNamed:@"tweet-button-v2"] forState:UIControlStateNormal];
//        [button_tweet addTarget:self action:@selector(tweetPhoto:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIBarButtonItem *rightDrawerButtonTweet = [[UIBarButtonItem alloc] initWithCustomView:button_tweet];
        
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightDrawerButtonTweet, rightDrawerButton, nil];
        
        
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 25, 25)];
    [button_menu setImage:[UIImage imageNamed:@"heart-white-v1"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(sendLove:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
//    
//    UIButton *button_tweet = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button_tweet setFrame:CGRectMake(0, 0, 25, 25)];
//    [button_tweet setImage:[UIImage imageNamed:@"tweet-button-v2"] forState:UIControlStateNormal];
//    [button_tweet addTarget:self action:@selector(tweetPhoto:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *rightDrawerButtonTweet = [[UIBarButtonItem alloc] initWithCustomView:button_tweet];
//    
//    if([self.thread.fromHandle.publicKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightDrawerButtonTweet, rightDrawerButton, nil];
//    } else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightDrawerButton, nil];
//    }
    
    
    [[RODItemStore sharedStore] loadMessagesForThread:self.thread.groupKey];
    [self reloadThread];
    
}

- (IBAction)tappedScreen:(id)sender {
    NSLog(@"Do stuffed.");
}

- (void)reloadThread
{
    
    NSLog(@"reloadThread: %@", self.loadedThreadKey);
    if(self.loadedThreadKey) {
        NSLog(@"Reloaded thread.");
        [self resetChatObjects];
        [self loadThread:self.loadedThreadKey];
        [self.snapView setNeedsUpdateConstraints];

    }
}

- (void)resetChatObjects
{
    [self.messages removeAllObjects];
    [self.subtitles removeAllObjects];
    [self.timestamps removeAllObjects];
    [self.hasTimeStamp removeAllObjects];
    [self.messageType removeAllObjects];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetChatObjects];
    
    [self loadThread:self.loadedThreadKey];
    [self.snapView setNeedsUpdateConstraints];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.snapView setImage:[UIImage alloc]];
    //self.thread = nil;
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
    
    UIFont *f = [UIFont fontWithName:@"LucidaTypewriter" size:12.0f];
    UIFont *fs16 = [UIFont fontWithName:@"LucidaTypewriter" size:14.0f];
    
    [[JSBubbleView appearance] setFont:f];
   
    [self.messageInputView.textView setFont:fs16];
    
    self.messageInputView.textView.placeHolder = @"New Message";
    [self.messageInputView.sendButton.titleLabel setFont:fs16];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.view setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
    [self.view addGestureRecognizer:tapView];

    [self reloadThread];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[RODItemStore sharedStore] unreadMessages];
    [self reloadThread];

}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{

    [self reloadThread];
    

    if(self.tableView.hidden == YES) {
        [self.tableView setHidden:NO];
        [self.messageInputView setHidden:NO];
    } else {
        [self.tableView setHidden:YES];
        [self.messageInputView endEditing:YES];
        [self.messageInputView setHidden:YES];
    }
    
}

-(void)tweetPhoto:(id)sender
{
 
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.thread.caption];
        [tweetSheet addImage:self.tweetImage];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}


-(void)sendLove:(id)sender
{

    [self.messages addObject:@"<3"];
    [self.timestamps addObject:[NSDate date]];
    [self.hasTimeStamp addObject:[NSNumber numberWithInt:0]];
    [self.messageType addObject:@"1"];
    [self.tableView setHidden:NO];
    [self.subtitles addObject:[RODItemStore sharedStore].authie.handle.name];

    NSString *toKey;
    toKey = [RODItemStore sharedStore].authie.handle.publicKey;
    
    if([[RODItemStore sharedStore].authie.handle.publicKey isEqualToString:self.thread.fromHandle.publicKey]) {
        // it's the other person... but who...
        
    }
    
    NSString *sentMessageKey = [[RODItemStore sharedStore] addChat:[RODItemStore sharedStore].authie.handle.name message:@"<3" groupKey:self.thread.groupKey toKey:self.toHandle.publicKey];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] sendChat:self.thread.groupKey message:@"<3" toKey:self.toHandle.publicKey messageKey:sentMessageKey];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            
            // nothing?
        });
    });
}

-(void)loadThread:(NSString *)groupKey
{
 
    NSString *currentMessage = self.messageInputView.textView.text;
    self.loadedThreadKey = groupKey;
    
    
    [self resetChatObjects];
    
    NSArray *tempThreads = [NSArray arrayWithArray:[RODItemStore sharedStore].authie.allThreads];
    
    RODThread *thread;
    
    for(RODThread *t in tempThreads) {
        if([t.groupKey isEqualToString:groupKey]) {
            thread = t;
            break;
        }
    }
    
//    if(thread.successfulUpload == NO) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"failed upload :(" message:@"This image failed to upload -- would you like to try again?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"reupload", nil];
//        [alert show];
//        
//    }
    
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
    
    UILabel *threadLabel = [[UILabel alloc] init];
    [threadLabel setText:[NSString stringWithFormat:@"%@:%@", [RODItemStore sharedStore].authie.handle.name, self.toHandle.name]];
    
    UIFont *menlo10 =[UIFont fontWithName:@"Menlo-Bold" size:10.0f];
    [threadLabel setFont:menlo10];
    
    [threadLabel setFrame:CGRectMake(0, 18, 100, 20)];
    [threadLabel setTextAlignment:NSTextAlignmentCenter];
    [threadLabel setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView = threadLabel;
    
    self.snapDate.text = [self.thread.startDate prettyDate];
    
    // now load all the messages that are associated with this thread
    
    NSLog(@"allMessages count: %lu, me.publicKey: %@ toHandle: %@", (unsigned long)[[RODItemStore sharedStore].authie.allMessages count], [RODItemStore sharedStore].authie.handle.publicKey, self.toHandle.publicKey);
    
    NSMutableArray *tempMessages = [NSMutableArray arrayWithArray:[RODItemStore sharedStore].authie.allMessages];
    
    // NOW, SORT TEMP MESSAGES BY DATE!
    
    NSPredicate *predictate = [NSPredicate predicateWithFormat:@"groupKey == %@", self.thread.groupKey];
    NSMutableArray *sortedMessages = [NSMutableArray arrayWithArray:[tempMessages filteredArrayUsingPredicate:predictate]];
    
//    for(RODMessage *m in sortedMessages) {
//        // remove all messages that are not equal to this groupKey
//        if([m.thread.groupKey isEqualToString:self.thread.groupKey] == false) {
//            [tempMessages removeObject:m];
//        }
//        
//    }
    
    [sortedMessages sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:YES], nil]];
    
    
    for(int i = 0; i < [sortedMessages count]; i++) {
        
        RODMessage *msg = [sortedMessages objectAtIndex:i];
        
//        NSLog(@"Checking: %@, %@", msg.messageText, msg.toKey);

        NSLog(@"checking id %@ date %@, text %@, name %@, toKey %@, toHandle.publicKey %@, seen: %@, groupKey: %@", msg.id, msg.sentDate, msg.messageText, msg.fromHandle.name, msg.toKey, self.toHandle.publicKey, msg.seen, msg.groupKey);

        
        if([msg.thread.groupKey isEqualToString:self.thread.groupKey]) {
            
            // NOW, one more check
            // we want to show items that have toHandleId = self.toHandle...
            // - from this user, to toHandleId
            // - or from toHandleId, to this user

            Boolean canAdd = NO;
            
            if([msg.fromHandle.publicKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
                
                // from me
                
                //from me and to the selected person
                if([msg.toKey isEqualToString:self.toHandle.publicKey]) {
                    canAdd = YES;
                }
                
                // from me and to the dash?
                if([msg.toKey isEqualToString:@"1"]) {
                    canAdd = YES;
                }
                
            }
            
            if([msg.fromHandle.publicKey isEqualToString:self.toHandle.publicKey]) {
                
                // from selected person
                canAdd = YES;
            }
            

            
            
//            
//            if([msg.thread.fromHandle.publicKey isEqualToString:self.toHandle.publicKey] && [msg.toKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey]) {
//                
//                canAdd = YES;
//            }
            
            
            if (canAdd == YES) {
                
                [self.timestamps addObject:msg.sentDate];
                
                if([msg.seen isEqualToNumber:[NSNumber numberWithInt:0]] && [msg.fromHandle.publicKey isEqualToString:[RODItemStore sharedStore].authie.handle.publicKey] == false) {
                    // hasn't been seen, give it time stamp...
                    // but this is only true if it's from other people
                    
                    [self.hasTimeStamp addObject:[NSNumber numberWithInt:1]];
                    
                } else {
                    // only give timestamp if it's every 3rd chat
                    
                    long x = [self.timestamps count];
                    if(x % 3 == 0) {
                        [self.hasTimeStamp addObject:[NSNumber numberWithInt:1]];
                    } else {
                        [self.hasTimeStamp addObject:[NSNumber numberWithInt:0]];
                    }
                    
                }
                
                msg.seen = [NSNumber numberWithInt:1];
                [msg setLocalNotificationSent:[NSNumber numberWithInt:1]];
                                
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
        
    }
    
    
    if([thread.groupKey isEqualToString:@"9074096b-9274-460c-a75a-ff1d3f55fc83"]) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"Max:Sloan"];
        
        [self resetChatObjects];

        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:-200];
        NSDate *newDate2 = [[NSDate date] dateByAddingTimeInterval:-199];
        
        [self.messages insertObject:@"Countdown to Chromeo..." atIndex:0];
        [self.subtitles insertObject:@"Sloan" atIndex:0];
        [self.timestamps insertObject:newDate atIndex:0];
        [self.messageType insertObject:@"0" atIndex:0];
        [self.hasTimeStamp insertObject:[NSNumber numberWithInt:1] atIndex:0];
        
        [self.messages insertObject:@"😎 what side" atIndex:1];
        [self.subtitles insertObject:@"Max" atIndex:1];
        [self.timestamps insertObject:newDate atIndex:1];
        [self.messageType insertObject:@"1" atIndex:1];
        [self.hasTimeStamp insertObject:[NSNumber numberWithInt:0] atIndex:1];

        [self.messages insertObject:@"on grass by V.I.P. 🌴🌴" atIndex:2];
        [self.subtitles insertObject:@"Sloan" atIndex:2];
        [self.timestamps insertObject:newDate atIndex:2];
        [self.messageType insertObject:@"0" atIndex:2];
        [self.hasTimeStamp insertObject:[NSNumber numberWithInt:0] atIndex:2];

        [self.messages insertObject:@"v chill, will find u" atIndex:3];
        [self.subtitles insertObject:@"Max" atIndex:3];
        [self.timestamps insertObject:newDate2 atIndex:3];
        [self.messageType insertObject:@"1" atIndex:3];
        [self.hasTimeStamp insertObject:[NSNumber numberWithInt:1] atIndex:3];
        
    }
    
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
        
    [[RODItemStore sharedStore] unreadMessages];
    // to perserve seen values
    [[RODItemStore sharedStore] saveChanges];
                                                                                                                                                                                                       
    self.messageInputView.textView.text = currentMessage;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSendText:(NSString *)text
{
        
//    if([RODItemStore sharedStore].hubConnection.state != 1) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wifi" message:@"Unable to connect to chat server to send message. Please try again." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    [self.messages addObject:text];
    
    [self.timestamps addObject:[NSDate date]];

    [self.hasTimeStamp addObject:[NSNumber numberWithInt:0]];
    
    [self.messageType addObject:@"1"];
    
    [self.tableView setHidden:NO];
    
    [self.subtitles addObject:[RODItemStore sharedStore].authie.handle.name];

    NSString *sentMessageKey  = [[RODItemStore sharedStore] addChat:[RODItemStore sharedStore].authie.handle.name message:text groupKey:self.thread.groupKey toKey:self.toHandle.publicKey];

    [self finishSend];
    [self scrollToBottomAnimated:YES];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] sendChat:self.thread.groupKey message:text toKey:self.toHandle.publicKey messageKey:sentMessageKey];

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
    return JSMessagesViewTimestampPolicyCustom;
}

- (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSNumber *x = [self.hasTimeStamp objectAtIndex:indexPath.row];
    if([x isEqualToNumber:[NSNumber numberWithInt:1]]) {
        return YES;
    } else {
        return NO;
    }
    
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
