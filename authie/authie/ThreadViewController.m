//
//  ThreadViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ThreadViewController.h"
#import "RODImageStore.h"
#import "RODItemStore.h"
#import "RODThread.h"
#import "RODAuthie.h"

@implementation ThreadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"ThreadViewController init.");
        // PREVENT THE UNDERLAPPING THAT OCCURS WITH
        // IOS 7!!!!!
        self.edgesForExtendedLayout = UIRectEdgeNone;
        loadRow = -1;
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeThread:)];
        
        self.navigationItem.rightBarButtonItem = edit;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad: %i", loadRow);
    if(self.thread) {
        [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:self.thread.groupKey]];
    } else {
        NSLog(@"No thread.");
    }
}

-(void)removeThread:(id)sender
{
    NSLog(@"Remove thread.");
    [self dismissViewControllerAnimated:YES completion:nil];
    [[RODItemStore sharedStore] removeThread:self.thread];
}

-(void)loadThread:(int)row
{
    NSLog(@"loadThread: %i", row);
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
    
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

@end
