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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
    [self.scroll layoutSubviews];
   
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
    
    int photo_height = 500;

    for(int i=0; i < [[RODItemStore sharedStore].loadedThreadsFromAuthor count]; i++) {
        
        RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];
        
        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, photo_height);
        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];
        [mini.labelDate setText:[thread.startDate prettyDate]];
        
        [mini.view layoutIfNeeded];
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + photo_height;
                
        [self.scroll addSubview:mini.view];
        
    }

    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];

}

@end
