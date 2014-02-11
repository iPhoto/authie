//
//  WireViewController.m
//  authie
//
//  Created by Seth Hayward on 2/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "WireViewController.h"
#import "RODItemStore.h"
#import "BlankWireViewController.h"

@implementation WireViewController

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
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"eye-white-v1"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getThreads
{
    NSLog(@"Get the Wire threads pls");
    [self populateScrollView];
}

- (void)populateScrollView
{

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
@end
