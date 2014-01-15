//
//  SelectContactViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "SelectContactViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODHandle.h"
#import "AppDelegate.h"
#import "MasterViewController.h"
#import "RODImageStore.h"
#import "ConfirmSnapViewController.h"

@implementation SelectContactViewController
@synthesize imagePicker, contactsTable;

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
    
    [self.contactsTable setSeparatorInset:UIEdgeInsetsZero];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this happens when they are viewing their own profile
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];

    self.imagePicker = [[UIImagePickerController alloc] init];
    
    [self.contactsTable deselectRowAtIndexPath:[self.contactsTable indexPathForSelectedRow] animated:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendSnap:(id)sender
{
    NSLog(@"bye.");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.masterViewController.navigationController popToRootViewControllerAnimated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RODItemStore sharedStore].authie.all_ContactsWithEverybody count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_ContactsWithEverybody objectAtIndex:indexPath.row];
    
    cell.textLabel.text = handle.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_ContactsWithEverybody objectAtIndex:indexPath.row];
    
    self.selected = handle;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self.imagePicker setDelegate:self];
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];

    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;

    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // now push to confirm snap
    
    ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
    confirm.snap = image;
    confirm.key = key;
    confirm.handle = self.selected;
    
    // old
    [self.navigationController pushViewController:confirm animated:YES];

    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.masterViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];

    [appDelegate.masterViewController.navigationController popToRootViewControllerAnimated:YES];

    [alert show];
    
}

@end
