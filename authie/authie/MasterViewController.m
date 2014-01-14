//
//  MasterViewController.m
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RKPostSelfie.h"
#import "RODAuthie.h"
#import "RODSelfie.h"
#import "RODThread.h"
#import "RODHandle.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "NavigationController.h"
#import "ThreadViewController.h"
#import "SelectContactViewController.h"
#import <MRProgress/MRProgress.h>
#import "RODImageStore.h"
#import "NSDate+PrettyDate.h"
#import "AuthorizeContactViewController.h"

@implementation MasterViewController
@synthesize imageToUpload, keyToUpload, handleToUpload, doUploadOnView, captionToUpload;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 40, 40)];
    [button_menu setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    self.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    
    if(self.doUploadOnView) {
        [self doUpload];
    }
    
}

- (void)resetUploadVariables
{
    self.doUploadOnView = NO;
    self.keyToUpload = @"";
    self.imageToUpload = [UIImage alloc];
    self.captionToUpload = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self resetUploadVariables];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSnap:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];
    self.navigationItem.title = @"Inbox";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setAllowsSelection:YES];
    [self.tableView setAllowsMultipleSelection:NO];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(id)sender
{
    NSLog(@"Refresh fired.");
    // do your refresh here and reload the tablview
    [[RODItemStore sharedStore] loadThreads];
}

- (void)sendSnap:(id)sender
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.selectContactViewController animated:YES];
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [RODItemStore sharedStore].authie.all_Threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", thread.fromHandleId];
    
    NSString *cool_time = [thread.startDate prettyDate];
    cell.detailTextLabel.text = cool_time;
    
    if([thread.authorizeRequest isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        [cell.imageView setImage:[UIImage imageNamed:@"lock.png"]];    
    } else
    {
        [cell.imageView setImage:[UIImage alloc]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"commitEditingStyle");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSLog(@"Delete.");
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
        [[RODItemStore sharedStore] removeThread:thread];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
    
    Boolean is_authorize_request = NO;
    
    if([thread.authorizeRequest isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        
        appDelegate.authorizeContactViewController = [[AuthorizeContactViewController alloc] init];
        [appDelegate.masterViewController.navigationController pushViewController:appDelegate.authorizeContactViewController animated:YES];
        is_authorize_request = YES;
        
    } else {
        
        appDelegate.threadViewController = [[ThreadViewController alloc] init];
        [appDelegate.masterViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
        
    }

    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    [progressView setTintColor:[UIColor blackColor]];
    [progressView setTitleLabelText:@""];
    [self.view.window addSubview:progressView];
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{


        
        [[RODImageStore sharedStore] preloadImageAndShowScreen:indexPath.row];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
            if(is_authorize_request == YES) {
                [appDelegate.authorizeContactViewController loadThread:indexPath.row];
            } else {
                [appDelegate.threadViewController loadThread:indexPath.row];
            }
            
            [progressView dismiss:YES];
            
            
        });
    });
    
}

- (void)doUpload
{

    // Block whole window

    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"uploading, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    [progressView setTintColor:[UIColor blackColor]];
    
    [self.navigationController.view.window addSubview:progressView];
    
    [progressView show:YES];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];

        [[RODImageStore sharedStore] setImage:self.imageToUpload forKey:self.keyToUpload];
        NSLog(@"Created key: %@", self.keyToUpload);
        
        [[RODItemStore sharedStore] createSelfie:self.keyToUpload];
        [[RODItemStore sharedStore] startThread:self.handleToUpload.publicKey forKey:self.keyToUpload withCaption:self.captionToUpload];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
            [progressView dismiss:YES];
            [self resetUploadVariables];
            [self.tableView reloadData];
        });
    });

}

@end
