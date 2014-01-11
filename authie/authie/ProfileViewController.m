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
@synthesize handle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.handleLabel setText:handle.name];
 
    [self getThreads];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    int photo_height = 300;
    
    for(int i=0; i < [[RODItemStore sharedStore].loadedThreadsFromAuthor count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        mini.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width - 5, photo_height);
        
        [mini.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];

        yOffset = yOffset + photo_height;
        [self.scroll addSubview:mini.view];
        NSLog(@"added %@", thread.groupKey);
        
    }
    
    [self.scroll setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
}

@end
