//
//  WireViewController.m
//  authie
//
//  Created by Seth Hayward on 2/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "WireViewController.h"
#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RODThread.h"
#import "RODHandle.h"
#import "BlankWireViewController.h"
#import "MiniThreadViewController.h"
#import "NSDate+PrettyDate.h"
#import "AppDelegate.h"
#import <MRProgressOverlayView.h>

@implementation WireViewController
@synthesize photoHeight, contentSize, doGetThreadsOnView;

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
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"eye-white-v1"];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if(self.doGetThreadsOnView) {
        [self getThreads];
        self.doGetThreadsOnView = NO;
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self populateScrollView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [[RODItemStore sharedStore] loadThreads:true];
        
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
    
    
    if([[RODItemStore sharedStore].wireThreads count] == 0) {
        NSLog(@"0 wire threads.");
        BlankWireViewController *bvc = [[BlankWireViewController alloc] init];
        [bvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.scroll addSubview:bvc.view];
    }
    

    UIFont *lucidaTypewriter = [UIFont fontWithName:@"LucidaTypewriter" size:20.0f];
    
    [_items removeAllObjects];
    
    for(int i=0; i < [[RODItemStore sharedStore].wireThreads count]; i++) {
        
        if(i > 10) break;
        
        RODThread *thread = [[RODItemStore sharedStore].wireThreads objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];
        
        [mini.heartsVotingView setHidden:NO];
        
        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];
        
        [mini.view setClipsToBounds:YES];
                
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        
        [mini.view setFrame:CGRectMake(0, yOffset, self.scroll.frame.size.width, self.photoHeight)];
        
        NSString *what;
        if([thread.toHandleId isEqualToString:@"dash"]) {
            what = @"posted to the dash";
        } else {
            what = [NSString stringWithFormat:@"sent direct to %@", thread.toHandleId];
            
        }
        
        [mini.labelDate setText:[NSString stringWithFormat:@"snapped %@", [thread.startDate prettyDate]]];
        
        yOffset = yOffset + self.photoHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            // The device is an iPad running iOS 3.2 or later.
            [mini.labelDate setFont:[UIFont systemFontOfSize:20]];
        }
        
        [mini.snapView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
        [mini.heartsVotingView addGestureRecognizer:tapView];
        
        [mini.view setNeedsUpdateConstraints];
        
        int mini_tag = i*100;
        int imageview_tag = i*1000;
        int report_tag = (i+900)*2000;
        mini.heartsVotingView.tag = mini_tag;
        mini.snapView.tag = imageview_tag;
        mini.reportView.tag = report_tag;
        
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            [mini.labelCaption setFont:lucidaTypewriter];
            mini.labelCaption.text = thread.caption;
            mini.labelCaption.layer.shadowOpacity = 0.4;
            mini.labelCaption.layer.shadowColor = [UIColor blackColor].CGColor;
            //            mini.labelCaption.layer.shadowRadius = 1;
            
        }
        
        mini.heartsCount.text = [NSString stringWithFormat:@"%i", [thread.hearts intValue]];
        
        [mini.reportView setHidden:YES];
        
        [mini.view layoutSubviews];
        //photo_height = mini.snapView.image.size.height + 10;
        
        
        [_items addObject:mini];
        
        [self.scroll addSubview:mini.view];
        
    }
    
    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{
    int thread_index = ([tapGesture.view tag] / 100);
    RODThread *thread = [[RODItemStore sharedStore].wireThreads objectAtIndex:thread_index];
    
    
    MiniThreadViewController *m = (MiniThreadViewController *)[_items objectAtIndex:thread_index];
    
    if(m.voted == false) {
        [m.heartsCount setTextColor:[UIColor colorWithRed:0.0/255 green:103.0/255 blue:0.0/255 alpha:1.0f]];
        [m.heartsImage setImage:[UIImage imageNamed:@"heart-green-filled-v1"]];
        thread.hearts = [NSNumber numberWithInt:[thread.hearts intValue] + 1];
        [m setVoted:YES];
    } else {
        [m.heartsCount setTextColor:[UIColor whiteColor]];
        thread.hearts = [NSNumber numberWithInt:[thread.hearts intValue] - 1];
        [m.heartsImage setImage:[UIImage imageNamed:@"heart-white-v1"]];
        [m setVoted:NO];
    }
    
    [m.heartsCount setText:[NSString stringWithFormat:@"%@", thread.hearts]];
    NSLog(@"Tapped: %@", thread.caption);
}

- (void)doRefresh:(UIRefreshControl *)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"syncing threads..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[RODItemStore sharedStore] loadThreads:true];
        
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
@end
