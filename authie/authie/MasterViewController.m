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

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    //[button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    //[button_menu setImage:[UIImage imageNamed:@"cog.png"] forState:UIControlStateNormal];
    //[button_menu addTarget:self action:@selector(hamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    
    
    //UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    //self.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    [self.imagePicker setNavigationBarHidden:true];
    
    UIImage *image = [UIImage imageNamed:@"authie-logo-09-100px"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = imageview;
    
    self.navigationItem.title = [RODItemStore sharedStore].authie.handle.name;

}

//- (void)hamburger:(id)sender
//{
//    NSLog(@"menu timeeee");
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate.drawer presentMenuViewController];
//}


-(void)btnSettings:(UIButton *)b
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tag line" message:@"something happens" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [[RODItemStore sharedStore] removeThread:indexPath.row];
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
        
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
        
        //[[segue destinationViewController] setDetailItem:thread];
        NSLog(@"Show thread pls: %@", thread.groupKey);
        
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setDetailItem:thread];
        NSLog(@"Show detail: %@", thread.groupKey);
    }
    
}

- (void)createSnap
{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
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
