//
//  DailyViewController.m
//  authie
//
//  Created by Seth Hayward on 1/11/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "DailyViewController.h"
#import "RODItemStore.h"
#import "MiniThreadViewController.h"
#import "RODImageStore.h"
#import "RODThread.h"
#import "NSDate+PrettyDate.h"
#import <MRProgress/MRProgress.h>

@implementation DailyViewController
@synthesize contentSize;

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
    
    [self.navigationItem setTitle:@"the daily"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];
    
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
    [progressView setTintColor:[UIColor blackColor]];
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.navigationController.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];
        
        [[RODItemStore sharedStore] loadDaily];
        
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
    
    MiniThreadViewController *mini;
    int yOffset = 0;
    
    
    // remove the threads that were there before
    [[self.scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int photo_height = 500;
    
    for(int i=0; i < [[RODItemStore sharedStore].dailyThreads count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].dailyThreads objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];
        
        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];
        
        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, photo_height);
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        [mini.labelDate setText:[thread.startDate prettyDate]];
        
        [mini.heartsCount setText:[thread.hearts stringValue]];
                
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            mini.labelCaption.text = thread.caption;
        }
        
        
        [mini.view layoutSubviews];
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + photo_height;
        
        [self.scroll addSubview:mini.view];
        
    }
    
    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
}

@end
