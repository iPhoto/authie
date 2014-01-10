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

@implementation MasterViewController

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

    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 40, 40)];
    [button_menu setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    self.navigationItem.leftBarButtonItem = leftDrawerButton;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSnap:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    //[self.imagePicker setNavigationBarHidden:true];
    
    UIImage *image = [UIImage imageNamed:@"authie-logo-07-350px"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    [imageview setFrame:CGRectMake(0, 0, 100, 20)];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imageview;
    self.navigationItem.title = [RODItemStore sharedStore].authie.handle.name;
        
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setAllowsSelection:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendSnap:(id)sender
{
    
    SelectContactViewController *select = [[SelectContactViewController alloc] init];
    [self.navigationController pushViewController:select animated:YES];
    
}

- (void)insertNewObject:(id)sender
{
    
    [self createSnap];
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads  objectAtIndex:indexPath.row];
    
    NSLog(@"Found: %@, %@", thread.toHandleId, thread.groupKey);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", thread.toHandleId];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", thread.fromHandleId];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
        
        self.detailViewController.detailItem = thread;
        self.detailViewController.snap = thread;
    } else {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];        
        [[RODImageStore sharedStore] preloadImageAndShowScreen:indexPath.row];
    }
}

- (void)createSnap
{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        
        //CGRect f = self.imagePicker.view.bounds;
        //f.size.height = 20;
        //UIView *seth = [[UIView alloc] init];
        //seth.frame = CGRectMake(0, 0, 20, 100);
        //seth.backgroundColor = [UIColor redColor];
        //[self.imagePicker.cameraOverlayView addSubview:seth];
        
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // DISABLE THE STATUS BAR... but how...
    
    [self.imagePicker setDelegate:self];
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;
    
    [[RODImageStore sharedStore] setImage:image forKey:key];
    NSLog(@"Created key: %@", key);
    
    [[RODItemStore sharedStore] createSelfie:key];
    [[RODItemStore sharedStore] startThread:@"1" forKey:key];
    
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


@end
