//
//  ProfileViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ProfileViewController.h"
#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RODHandle.h"
#import <MRProgress/MRProgress.h>
#import "MiniThreadViewController.h"
#import "RODThread.h"

@implementation ProfileViewController
@synthesize handle, contentSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:handle.name];
    
    [self getThreads];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
    [self.scroll layoutSubviews];
   
}

- (void)getThreads
{
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"downloading, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.navigationController.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];

        [[RODItemStore sharedStore] getThreadsFromHandle:handle.publicKey];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
            [self populateScrollView];
            [progressView dismiss:YES];
        });
    });
    
}

- (void)populateScrollView
{
    
    NSLog(@"populateScrollView started: %i", [[RODItemStore sharedStore].loadedThreadsFromAuthor count]);
    MiniThreadViewController *mini;
    int yOffset = 0;

    for(int i=0; i < [[RODItemStore sharedStore].loadedThreadsFromAuthor count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];
        
        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, 300);
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        [mini.view layoutIfNeeded];
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + 300;
        
        NSLog(@"Image height, snapView height: %i, %i", image.size.height, mini.snapView.frame.size.height);
        
        [self.scroll addSubview:mini.view];
        
    }

    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];

    
    NSLog(@"Scroll view content size: %f, %f", self.scroll.contentSize.height, self.scroll.frame.size.width);
    
}

@end
