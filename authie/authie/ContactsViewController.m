//
//  ContactsViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ContactsViewController.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "RODAuthie.h"
#import "RODFollower.h"
#import "RODItemStore.h"
#import "DashViewController.h"
#import "ConfirmSnapViewController.h"
#import "RODItemStore.h"

@implementation ContactsViewController
@synthesize selected, imagePicker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
        self.navigationItem.rightBarButtonItem = addButton;
        
        self.navigationItem.title = @"Authors";
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.imagePicker = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(id)sender
{
    [[RODItemStore sharedStore] loadContacts];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RODItemStore sharedStore].authie.all_Contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts  objectAtIndex:indexPath.row];
    
    cell.textLabel.text = handle.name;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", handle.publicKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];
        
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //ProfileViewController *pvc = [[ProfileViewController alloc] init];
    //appDelegate.profileViewController = pvc;
    
    //pvc.handle = handle;
    //[self.navigationController pushViewController:pvc animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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



- (void)addContact:(id)sender
{
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"request authorization"
                                                    message:@"if you want to add someone, you will need to send verification. we suggest a selfie. enter their handle to begin."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"take image", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
}

- (void)showAuthorizationRequestImagePicker
{
    self.imagePicker = nil;
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self.imagePicker setDelegate:self];
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [[RODItemStore sharedStore] addContact:name];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;
    
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    
    // now push to confirm snap
    //...
    
    ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
    confirm.snap = image;
    confirm.key = key;
    confirm.handle = self.selected;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.masterViewController];

    [appDelegate.masterViewController.navigationController pushViewController:confirm animated:YES];
    self.frostedViewController.contentViewController = navigationController;
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.masterViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
    
    [appDelegate.contactsViewController.navigationController popToRootViewControllerAnimated:YES];
    
    [alert show];
    
}


@end
