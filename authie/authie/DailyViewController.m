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
#import "RODAuthie.h"
#import "RODHandle.h"

@implementation DailyViewController
@synthesize contentSize;

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
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateDailyView];
    
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
    
    int photo_height = 400;
    
    [_items removeAllObjects];
    [self.scroll setContentOffset:CGPointZero animated:YES];
    
    for(int i=0; i < [[RODItemStore sharedStore].dailyThreads count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].dailyThreads objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];
        
        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];

        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, photo_height);
        [mini.view setClipsToBounds:YES];
        
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        [mini.labelDate setText:[NSString stringWithFormat:@"%@, by %@", [thread.startDate prettyDate], thread.fromHandle.name]];
        
        [mini.heartsCount setText:[thread.hearts stringValue]];
        
        [mini.heartsView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapHearts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeart:)];
        [mini.heartsView addGestureRecognizer:tapHearts];
        
        [mini.snapView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
        [mini.snapView addGestureRecognizer:tapView];
        
        [mini.reportButton setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapReport = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedReport:)];
        [mini.reportButton addGestureRecognizer:tapReport];
        
        int mini_tag = i*100;
        int imageview_tag = (i+100)*1000;
        int report_tag = (i+900)*2000;
        mini.heartsView.tag = mini_tag;
        mini.snapView.tag = imageview_tag;
        mini.reportButton.tag = report_tag;
        
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            mini.labelCaption.text = thread.caption;
        }

        if(mini.labelCaption.text.length == 0) {
            
            [mini.heartsView setTranslatesAutoresizingMaskIntoConstraints:YES];
            
            CGRect f = mini.heartsView.frame;
            f.size.height = 40;
            f.size.width = self.scroll.frame.size.width;
            
            [mini.heartsView setFrame:f];
        } else if(mini.labelCaption.text.length < 100) {
            
            [mini.heartsView setTranslatesAutoresizingMaskIntoConstraints:YES];
            
            CGRect f = mini.heartsView.frame;
            f.size.height = 80;
            f.size.width = self.scroll.frame.size.width;
            
            [mini.heartsView setFrame:f];
        }
                
        [mini.view layoutSubviews];
        
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + photo_height;
        
        [self.scroll addSubview:mini.view];
        [_items addObject:mini];
        
    }
    
    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
}

- (void)tappedReport:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"Tapped report.");
    
    int thread_index = ([tapGesture.view tag] / 2000) - 900;
    RODThread *thread = [[RODItemStore sharedStore].dailyThreads objectAtIndex:thread_index];

    // run update interface code before calling web service
    UIAlertView *reported = [[UIAlertView alloc] initWithTitle:@"Reported" message:@"This image has been reported. A moderator has been alerted and will remove the image if it is inappropriate." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];

    [reported show];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] report:thread.groupKey];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
        });
    });
    
}


- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{

    int thread_index = ([tapGesture.view tag] / 1000) - 100;
    
    MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];
    if([lil_t.heartsView isHidden] == YES) {
        [lil_t.heartsView setHidden:NO];
        [lil_t.reportView setHidden:NO];
    } else {
        [lil_t.heartsView setHidden:YES];
        [lil_t.reportView setHidden:YES];
    }
    
}


- (void)clickedHeart:(UITapGestureRecognizer *)tapGesture
{
    
    int thread_index = [tapGesture.view tag] / 100;
    RODThread *thread = [[RODItemStore sharedStore].dailyThreads objectAtIndex:thread_index];
    
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


@end
