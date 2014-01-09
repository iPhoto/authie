//
//  ThreadViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ThreadViewController.h"
#import "RODImageStore.h"
#import "RODThread.h"

@implementation ThreadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"ThreadViewController init.");
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"ThreadViewController viewDidLoad");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setThread:(RODThread *)new_thread
{
    NSLog(@"setThread: %@", new_thread.groupKey);
    //self.thread = new_thread;
    
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:new_thread.groupKey]];
    
}

@end
