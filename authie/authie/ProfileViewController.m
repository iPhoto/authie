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
#import "RODAuthie.h"
#import "NSDate+PrettyDate.h"

@implementation ProfileViewController
@synthesize handle, contentSize;

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
    
    [self.navigationItem setTitle:handle.name];
    
    [self getThreads];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self populateScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
            
    if(self.handle.name != [RODItemStore sharedStore].authie.handle.name) {
        
        // add trash can button to allow the user
        // to remove a contact
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeContact:)];
        
        self.navigationItem.rightBarButtonItem = edit;
        
    } else {

        // this happens when they are viewing their own profile
        self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];

        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)removeContact:(id)sender
{
    
    NSString *message = [NSString stringWithFormat:@"remove %@ as a contact?", handle.name];
    
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"remove contact" message:message delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil];
    
    [confirm show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[RODItemStore sharedStore] removeContact:handle];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSArray *viewsToRemove = [self.scroll subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    
    //[self populateScrollView];
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
    
    MiniThreadViewController *mini;
    int yOffset = 0;
    
    int photo_height = 400;

    for(int i=0; i < [[RODItemStore sharedStore].loadedThreadsFromAuthor count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];
        
        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, photo_height);
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        [mini.labelDate setText:[thread.startDate prettyDate]];
        
        [mini.heartsView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapHearts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeart:)];
        [mini.heartsView addGestureRecognizer:tapHearts];
        
        [mini.snapView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
        [mini.snapView addGestureRecognizer:tapView];
        
        int mini_tag = i*100;
        int imageview_tag = (i+100)*1000;
        int report_tag = (i+900)*2000;
        mini.heartsView.tag = mini_tag;
        mini.snapView.tag = imageview_tag;
        mini.reportView.tag = report_tag;
        
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            mini.labelCaption.text = thread.caption;
        }

        if(mini.labelCaption.text.length == 0) {
            
            [mini.heartsView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            CGRect f = mini.heartsView.frame;
            f.size.height -= 50;
            f.size.width = self.scroll.frame.size.width;
            
            [mini.heartsView setFrame:f];
        } else if(mini.labelCaption.text.length < 20) {
            
            [mini.heartsView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            CGRect f = mini.heartsView.frame;
            f.size.height -= 20;
            f.size.width = self.scroll.frame.size.width;
            
            [mini.heartsView setFrame:f];
        }
        
        [mini.reportView setHidden:YES];

        [mini.view layoutSubviews];
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + photo_height;
        
        [_items addObject:mini];
        
        [self.scroll addSubview:mini.view];
        
    }

    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];

}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{
    
    int thread_index = ([tapGesture.view tag] / 1000) - 100;
    
    MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];
    if([lil_t.heartsView isHidden] == YES) {
        [lil_t.heartsView setHidden:NO];
    } else {
        [lil_t.heartsView setHidden:YES];
    }
    
}


- (void)clickedHeart:(UITapGestureRecognizer *)tapGesture
{
    
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

@end
