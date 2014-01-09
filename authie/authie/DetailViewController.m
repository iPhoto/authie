//
//  DetailViewController.m
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "DetailViewController.h"
#import "RODImageStore.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODThread.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setThread:(RODThread *)new_thread
{
    NSLog(@"setSnap: %@", new_thread.groupKey);
    self.snap = new_thread;

    if (self.snap) {
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    RODThread *thread = self.snap;

    if (thread) {
        NSLog(@"Thread: %@", thread.groupKey);
        [self.SnapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];

    } else {
        NSLog(@"emptienss");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
    NSLog(@"DetailViewController started.");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
