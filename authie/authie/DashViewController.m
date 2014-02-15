//
//  DashViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "DashViewController.h"
#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RODHandle.h"
#import <MRProgress/MRProgress.h>
#import "MiniThreadViewController.h"
#import "RODThread.h"
#import "RODAuthie.h"
#import "NSDate+PrettyDate.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "ConfirmSnapViewController.h"
#import "BlankSlateViewController.h"
#import <CXAlertView/CXAlertView.h>
#import "PagerViewController.h"
#import <REMenu/REMenu.h>
#import <UIImage+Blur.h>
#import <FBGlowLabel/FBGlowLabel.h>

@implementation DashViewController
@synthesize handle, contentSize, imageToUpload, keyToUpload, handleToUpload, captionToUpload,
            doUploadOnView, imagePicker, selected, mostRecentGroupKey, photoHeight,
            locationToUpload, fontToUpload, textColorToUpload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        _items = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSnap:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];
    
    self.navigationItem.title = @"Dash";
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    UIPanGestureRecognizer *swipeView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipedImageView:)];
    [swipeView setMinimumNumberOfTouches:1];
    [self.view addGestureRecognizer:swipeView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)clearScrollView
{
    NSArray *viewsToRemove = [self.scroll subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
   
}

- (void)sendSnap:(id)sender
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[RODItemStore sharedStore] loadContacts];
    [self.navigationController pushViewController:appDelegate.selectContactViewController animated:YES];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self populateScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.screenName = @"Dash";
    
    if(self.doUploadOnView) {
        [self doUpload];
    }

    if(self.doGetThreadsOnView) {
        
        
        [self getThreads];
        self.doGetThreadsOnView = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];

    [self updateDashHeader];
    
    
}

- (void) updateDashHeader
{
    
    int unread = [[RODItemStore sharedStore] unreadMessages];
    if(unread > 0) {
        self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v6-white-new-msg"];
        
    } else {
        self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];
    }
    
}

- (void) toggleMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.navigationViewController toggleMenu];    
}

- (void)addMessage:(NSString *)user message:(NSString *)msg groupKey:(NSString *)key {
    NSLog(@"addMessage, dashy: %@, %@, %@, %i", user, msg, key, [RODItemStore sharedStore].hubConnection.state);
    [[RODItemStore sharedStore] addChat:user message:msg groupKey:key];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSArray *viewsToRemove = [self.scroll subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    
    //[self populateScrollView];
}

- (void)getThreads
{
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"syncing threads";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    
    // overlay dead man's switch
    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(removeOverlays:)
                                   userInfo:nil
                                    repeats:NO];
    
    
    [self.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation

        [[RODItemStore sharedStore] loadThreads:false];
        [[RODItemStore sharedStore] loadMessages];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [self populateScrollView];
            [progressView dismiss:YES];
            
        });
    });
    
}

- (void)removeOverlays:(NSTimer *)timer
{
    NSLog(@"Dead Man's switch fired. clear all overlays.");
    [MRProgressOverlayView dismissAllOverlaysForView:self.view.window animated:YES];
}

- (void)doRefresh:(UIRefreshControl *)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"syncing threads..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[RODItemStore sharedStore] loadThreads:false];
        [[RODItemStore sharedStore] loadMessages];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
            
            refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
            
            [refreshControl endRefreshing];
            
            [self populateScrollView];
            
        });
    });
}

- (void)populateScrollView
{
    
    MiniThreadViewController *mini;
    int yOffset = 0;
    
    self.photoHeight = 400;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iOS 3.2 or later.
        self.photoHeight = 800;
    }

    // scroll to top
    [self.scroll setContentOffset:CGPointZero animated:NO];
    
    // remove the threads that were there before
    [[self.scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"pull to sync"]];
    [refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [self.scroll addSubview:refreshControl];
    
    [self.scroll setAlwaysBounceVertical:YES];
    
    [_items removeAllObjects];

    if([[RODItemStore sharedStore].authie.all_Threads count] == 0) {

        BlankSlateViewController *bsvc = [[BlankSlateViewController alloc] init];
        [bsvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        self.contentSize = self.view.frame.size.height;
        [self.scroll addSubview:bsvc.view];
        
    }
    
    
    for(int i=0; i < [[RODItemStore sharedStore].authie.all_Threads count]; i++) {
        
        if(i > 10) break;
        
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];

        [mini.view setClipsToBounds:YES];

        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        
        if([thread.authorizeRequest isEqualToNumber:[NSNumber numberWithInt:1]]) {
            
            mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, self.photoHeight);
            
            //
            // authorization request

            UIView *theDarkness = [[UIView alloc] initWithFrame:mini.view.frame];
            theDarkness.backgroundColor = [UIColor blackColor];
            theDarkness.layer.opacity = 0.6f;
            [mini.snapView addSubview:theDarkness];
            
            mini.labelDate.text = [NSString stringWithFormat:@"authorization request from %@ to %@", thread.fromHandle.name, thread.toHandle.name];
            
            yOffset = yOffset + self.photoHeight;
            
        } else {
            
            mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, self.photoHeight);

            NSString *what;
            if([thread.toHandleId isEqualToString:@"dash"]) {
                what = @"posted to the dash";
            } else if ([thread.toHandleId isEqualToString:@"the wire"]) {
                what = @"sent secretly to the wire";
            } else {
                what = [NSString stringWithFormat:@"sent direct to %@", thread.toHandleId];
            }
            
            [mini.labelDate setText:[NSString stringWithFormat:@"snapped by %@, %@ %@", thread.fromHandle.name, what, [thread.startDate prettyDate]]];
            
            [mini.heartsView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *tapHearts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeart:)];
            [mini.heartsView addGestureRecognizer:tapHearts];

            yOffset = yOffset + self.photoHeight;

        }

        [mini.view setNeedsUpdateConstraints];

        // only allow tapping on dash and direct posts
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];

        
        if([thread.toHandleId isEqualToString:@"dash"]) {
            // don't blur pls
            [mini.snapView addGestureRecognizer:tapView];
            
            [mini.heartsVotingView setHidden:YES];
        } else if ([thread.toHandleId isEqualToString:@"the wire"]) {
            // don't blur pls

            if(thread.location == (id)[NSNull null] || thread.location.length == 0) {
                [mini.labelLocation setText:@""];
            } else {
                [mini.labelLocation setText:thread.location];
            }
            
            [mini.heartsCount setText:[NSString stringWithFormat:@"%i", [thread.hearts intValue]]];
            [mini.heartsVotingView setHidden:NO];
        } else {
            // blurry
            
            float quality = .00001f;
            float blurred = .5f;
            
            NSData *imageData = UIImageJPEGRepresentation([mini.snapView image], quality);
            UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
            mini.snapView.image = blurredImage;
            [mini.snapView setNeedsLayout];

            [mini.heartsVotingView setHidden:YES];

            [mini.snapView addGestureRecognizer:tapView];
            
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            // The device is an iPad running iOS 3.2 or later.
            [mini.labelDate setFont:[UIFont systemFontOfSize:20]];
        }

        [mini.snapView setUserInteractionEnabled:YES];
        
        
        int mini_tag = i*100;
        int imageview_tag = i*1000;
        int report_tag = (i+900)*2000;
        mini.heartsView.tag = mini_tag;
        mini.snapView.tag = imageview_tag;
        mini.reportView.tag = report_tag;
        
        [mini.view setNeedsDisplay];
        
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            
            mini.labelCaption.text = thread.caption;
            
            mini.labelCaption.clipsToBounds = YES;
            mini.labelCaption.alpha = 1.0;
            
            
            UIColor *c;
            if(thread.textColor == (id)[NSNull null] || thread.textColor.length == 0 ) {
                c = [UIColor whiteColor];
                
                mini.labelCaption.textColor = c;
                
                mini.labelCaption.glowSize = 2;
                mini.labelCaption.glowColor = [UIColor grayColor];
                
                mini.labelCaption.innerGlowSize = 4;
                mini.labelCaption.innerGlowColor = [UIColor whiteColor];
                
            }
            else {
                NSLog(@"textColor: %@", thread.textColor);
                c = [[RODItemStore sharedStore] colorFromHexString:thread.textColor];
                
                mini.labelCaption.textColor = c;
                
                mini.labelCaption.glowSize = 2;
                mini.labelCaption.glowColor = c;
                
                mini.labelCaption.innerGlowSize = 4;
                mini.labelCaption.innerGlowColor = c;
                
            }
            mini.labelCaption.textColor = c;
            
            UIFont *f;
            if(thread.font == (id)[NSNull null] || thread.font.length == 0 ) {
                f = [UIFont fontWithName:@"LucidaTypewriter" size:20.0f];
            }
            else {
                f = [UIFont fontWithName:thread.font size:20.0f];
            }

            [mini.labelCaption setFont:f];
            

            
            
        }
        
        
        [mini.reportView setHidden:YES];

        [mini.view layoutSubviews];

        
        [_items addObject:mini];
        
        [self.scroll addSubview:mini.view];
        
    }
    
    // now add the pager control if there 1 or more snaps
    
    if([[RODItemStore sharedStore].authie.allThreads count] > 1) {

        PagerViewController *pager = [[PagerViewController alloc] init];
        pager.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, pager.view.frame.size.height);
        
        if([[RODItemStore sharedStore] currentPage] > 1) {
            [pager.buttonBack setHidden:false];
            [pager.buttonBack addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [pager.buttonBack setHidden:true];
        }
        
        [pager.buttonNext addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        pager.view.tag = 7;
        yOffset = yOffset + pager.view.frame.size.height;
        
        [self.scroll addSubview:pager.view];

        
    }

    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
}

- (void)nextButtonClicked:(UIButton *)button
{
    [RODItemStore sharedStore].currentPage++;
    [self getThreads];
}

-(void)backButtonClicked:(UIButton *)button
{
    if([[RODItemStore sharedStore] currentPage] > 1) {
        [RODItemStore sharedStore].currentPage--;
        [self getThreads];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"Swiped.");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"delete?" message:@"do you want to delete this message?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"delete", nil];
//    [alert show];
}

- (void)swipedImageView:(UIPanGestureRecognizer *)swipeGesture
{
    
    if(swipeGesture.state == UIGestureRecognizerStateEnded) {
        // try to determine which thread was swiped...
        
        CGPoint pointInView = [swipeGesture locationInView:self.scroll];
        
        int thread_index = ceilf(pointInView.y / self.photoHeight);
        thread_index = thread_index - 1;
        
        RODThread *t = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:thread_index];
        
        if([t.fromHandleId isEqualToString:[RODItemStore sharedStore].authie.handle.name] || [t.toHandleId isEqualToString:[RODItemStore sharedStore].authie.handle.name]) {
            
        } else {
            
            NSLog(@"t.fromHandle.id: %@, t.toHandle.id: %@", t.fromHandleId, t.toHandleId);
            NSLog(@"Can't delete this one.");
            return;
        }
        
        // This is a demo for changing content at realtime.
        CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:@"delete thread?" message:@"you want to delete this thread?" cancelButtonTitle:@"cancel"];
        // This is a demo for changing content at realtime.

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [imageView setImage:[[RODImageStore sharedStore] imageForKey:t.groupKey]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.backgroundColor = [UIColor clearColor];
        alertView.contentView = imageView;
        alertView.tag = 101;
        
        [alertView addButtonWithTitle:@"delete" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
            [[RODItemStore sharedStore] removeThread:t];
            [self populateScrollView];
            [alertView dismiss];
            
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"bye" message:@"This thread has been trashed." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            
            //[alert show];
            
        }];
        
        [alertView show];
    }
    
    
}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{
    
    NSLog(@"tappedImageView.");

    // Block whole window
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    [progressView setTitleLabelText:@""];
    [self.view addSubview:progressView];
    [progressView show:YES];
    
    
    int thread_index = ([tapGesture.view tag] / 1000);
    
    //MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:thread_index];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
     
        NSLog(@"preloadImage");
        
        [[RODImageStore sharedStore] preloadImageAndShowScreen:thread_index];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;

            if([thread.authorizeRequest isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                
                appDelegate.authorizeContactViewController = [[AuthorizeContactViewController alloc] init];
                //[appDelegate.authorizeContactViewController loadThread:thread_index];
                [appDelegate.dashViewController.navigationController pushViewController:appDelegate.authorizeContactViewController animated:YES];
                [appDelegate.authorizeContactViewController loadThread:thread_index];
                
            } else {
                
                appDelegate.threadViewController = [[ThreadViewController alloc] init];
                [appDelegate.threadViewController setLoadRow:thread_index];
                [appDelegate.dashViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
            }
                        
            [progressView dismiss:YES];
            
        });
    });
    
}


- (void)clickedHeart:(UITapGestureRecognizer *)tapGesture
{
 
    NSLog(@"clicked heart...");
    
    int thread_index = [tapGesture.view tag] / 100;
    RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:thread_index];
    
    // run update interface code before calling web service
    MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];
    int more_hearts = [thread.hearts intValue] + 1;
    [lil_t.heartsCount setText:[NSString stringWithFormat:@"%i", more_hearts]];
    thread.hearts = [NSNumber numberWithInt:more_hearts];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] giveLove:thread.groupKey];
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
        });
    });
    
    
}

- (void)resetUploadVariables
{
    self.doUploadOnView = NO;
    self.keyToUpload = @"";
    self.imageToUpload = [UIImage alloc];
    self.captionToUpload = @"";
    self.locationToUpload = @"";
    self.textColorToUpload = @"";
    self.fontToUpload = @"";
}

- (void)doUpload
{
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"uploading, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    [[RODImageStore sharedStore] setImage:self.imageToUpload forKey:self.keyToUpload];
    NSLog(@"Created key: %@", self.keyToUpload);
    [[RODItemStore sharedStore] createSelfie:self.keyToUpload];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        [[RODItemStore sharedStore] startThread:self.handleToUpload.publicKey
                                         forKey:self.keyToUpload
                                    withCaption:self.captionToUpload
                                   withLocation:self.locationToUpload
                                       withFont:self.fontToUpload
                                  withTextColor:self.textColorToUpload
            ];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [[RODItemStore sharedStore] sendNotes:self.keyToUpload];
            [self resetUploadVariables];
            [[RODItemStore sharedStore] loadThreads:false];
            [progressView dismiss:YES];
            
        });
    });
    
}



- (void)addContact
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add"
                                                    message:@"to add a friend, enter their handle and send a snap (for example, a selfie) so they know it's you."
                                                   delegate:self
                                          cancelButtonTitle:@"cancel"
                                          otherButtonTitles:@"take image", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [alert show];
    
}

- (void)showAuthorizationRequestImagePicker
{
    self.imagePicker = nil;
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self.imagePicker setDelegate:self];
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView clickedButtonAtIndex");

    if(alertView.tag == 2) {
        if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
            [[RODItemStore sharedStore] addContact:name];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;
    
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    
    // now push to confirm snap
    //...
    
    ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
    confirm.snap = image;
    confirm.key = key;
    confirm.handle = self.selected;
    
    [self.navigationController pushViewController:confirm animated:YES];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.dashViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
    
    [appDelegate.contactsViewController.navigationController popToRootViewControllerAnimated:YES];
    
    [alert show];
    
}


@end
