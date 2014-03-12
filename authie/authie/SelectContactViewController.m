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
#import "RODImageStore.h"
#import "ConfirmSnapViewController.h"
#import "RODThread.h"
#import "ContactItemCell.h"
#import <NBUImagePicker/NBUImagePickerController.h>
#import <NBUImagePicker/NBUMediaInfo.h>
#import <NBUImagePicker/NBUCameraViewController.h>
#import "RODCameraViewController.h"

@implementation SelectContactViewController
@synthesize imagePicker, contactsTable, editingContacts, cameraView;

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

    UINib *nib = [UINib nibWithNibName:@"ContactItemCell" bundle:nil];
    [self.contactsTable registerNib:nib forCellReuseIdentifier:@"ContactItemCell"];
    
    [self.contactsTable setRowHeight:100];
    
    self.navigationItem.title = @"send snap to:";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this happens when they are viewing their own profile
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];
    
    UIBarButtonItem *one = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];
    UIBarButtonItem *two = [[RODItemStore sharedStore] generateAddPersonMenuItem];
    
    self.navigationItem.leftBarButtonItems = @[ one, two ];
    
    [self.contactsTable deselectRowAtIndexPath:[self.contactsTable indexPathForSelectedRow] animated:animated];

    self.cameraView.savePicturesToLibrary = YES;
    self.cameraView.backgroundColor = [UIColor whiteColor];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    if([[RODItemStore sharedStore].authie.all_Contacts count] > 2) {
        UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enableBlocking:)];
        self.navigationItem.rightBarButtonItem = rightDrawerButton;        
    }
    
    
    editingContacts = NO;

    [self.contactsTable reloadData];
    
}

- (void)addContact:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add"
                                                    message:@"to add a friend, enter their handle and send a snap (for example, a selfie) so they know it's you."
                                                   delegate:self
                                          cancelButtonTitle:@"cancel"
                                          otherButtonTitles:@"take image", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 311;
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


-(void)enableBlocking:(UIBarButtonItem *)btn
{
    
    UIBarButtonItem *rightDrawerButton;
    
    if(editingContacts == YES) {
        NSLog(@"block.");
        rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enableBlocking:)];
        self.navigationItem.rightBarButtonItem = rightDrawerButton;
        [self setEditingContacts:NO];
    } else {
        NSLog(@"block.");
        rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(enableBlocking:)];
        self.navigationItem.rightBarButtonItem = rightDrawerButton;
        [self setEditingContacts:YES];
    }
    
    [self.contactsTable reloadData];
    
    
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
    [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RODItemStore sharedStore].authie.all_Contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];
    
    ContactItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactItemCell"];
    
    [cell.contactName setText:handle.name];
    
    UIImage *mostRecent = [UIImage alloc];

    if(handle.mostRecentSnap == (id)[NSNull null] || handle.mostRecentSnap.length == 0) {
        // nothing
        
        mostRecent = [UIImage imageNamed:@"heart-green-filled-v1"];
        
        
    } else {
        mostRecent = [[RODImageStore sharedStore] imageForKey:handle.mostRecentSnap];
    }
    
    
    if(editingContacts == YES && indexPath.row > 1) {
        [cell.buttonBlock setHidden:NO];
        [cell.buttonRemove setHidden:NO];
        
        UITapGestureRecognizer *tapBlock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlock:)];
        [cell.buttonBlock addGestureRecognizer:tapBlock];

        UITapGestureRecognizer *tapRemove = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemove:)];
        [cell.buttonRemove addGestureRecognizer:tapRemove];
        
        [cell.buttonRemove setTag:(indexPath.row * 1000)];
        [cell.buttonBlock setTag:(indexPath.row * 1000) + 500000];

        
    } else {
        [cell.buttonBlock setHidden:YES];
        [cell.buttonRemove setHidden:YES];
    }

    [cell.mostRecentSnap setImage:mostRecent];
    
    return cell;
}

- (void)tapBlock:(UITapGestureRecognizer *)tapGesture
{
    int row = (tapGesture.view.tag - 500000) / 1000;
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:row];
    
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"block" message:[NSString stringWithFormat:@"block %@? they will be unable to send you snaps.", handle.name] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"block", nil];
    
    self.selected = handle;

    
    a.tag = 200;
    [a show];
    
}

- (void)tapRemove:(UITapGestureRecognizer *)tapGesture
{
    int row = (tapGesture.view.tag) / 1000;
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:row];
    
    self.selected = handle;
    
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"remove" message:[NSString stringWithFormat:@"remove %@ as a contact?", handle.name] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"remove", nil];
    a.tag = 100;
    [a show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex == 0) {
        // cancel button
        return;
    }

    UIAlertView *bye;

    // figure out if it's a remove or a block
    switch(alertView.tag) {
        case 100:
            NSLog(@"clicked remove: %@", self.selected.name);
            [[RODItemStore sharedStore] removeContact:self.selected];
            [self.contactsTable reloadData];
            bye = [[UIAlertView alloc] initWithTitle:@"bye" message:[NSString stringWithFormat:@"%@ is removed from your list.", self.selected.name] delegate:self cancelButtonTitle:@"good" otherButtonTitles:nil];
            [bye show];
            break;
        case 200:
            NSLog(@"clicked block");
            [[RODItemStore sharedStore] addBlock:self.selected.publicKey];
            [self.contactsTable reloadData];
            
            bye = [[UIAlertView alloc] initWithTitle:@"bye" message:[NSString stringWithFormat:@"%@ is blocked.", self.selected.name] delegate:self cancelButtonTitle:@"good" otherButtonTitles:nil];
            [bye show];
            break;
        case 311:
            // add contact
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                [[RODItemStore sharedStore] addContact:name];
            }

            break;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingContacts == YES) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];
    self.selected = handle;
        
    //self.imagePicker = nil;
    //self.imagePicker = [[UIImagePickerController alloc] init];
    
    // Configure the camera view
    //self.cameraView.shouldAutoRotateView = YES;

    [self.cameraView setBackgroundColor:[UIColor clearColor]];
    
    //self.cameraView.targetResolution = CGSizeMake(640.0, 640.0); // The minimum resolution we want
    self.cameraView.keepFrontCameraPicturesMirrored = YES;
    self.cameraView.captureResultBlock = ^(UIImage * image,
                                           NSError * error)
    {
        if (!error)
        {
            // *** Only used to update the slide view ***
//            UIImage * thumbnail = [image thumbnailWithSize:_slideView.targetObjectViewSize];
//            NSMutableArray * tmp = [NSMutableArray arrayWithArray:_slideView.objectArray];
//            [tmp insertObject:thumbnail atIndex:0];
//            _slideView.objectArray = tmp;
        } else {
            
            NSLog(@"Error occurred: %@", error);
        }
    };
    
    
    self.cameraView.flashButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                     @[@"Flash Off", @"Flash On", @"Flash Auto"]];
    self.cameraView.focusButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                     @[@"Fcs Lckd", @"Fcs Auto", @"Fcs Cont"]];
    self.cameraView.exposureButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                        @[@"Exp Lckd", @"Exp Auto", @"Exp Cont"]];
    self.cameraView.whiteBalanceButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                            @[@"WB Lckd", @"WB Auto", @"WB Cont"]];
    
    [self.cameraView setSavePicturesToLibrary:YES];
    
    
    
    // Configure for video
    //self.cameraView.targetMovieFolder = [UIApplication sharedApplication].temporaryDirectory;
        
    // Optionally auto-save pictures to the library
    self.cameraView.saveResultBlock = ^(UIImage * image,
                                        NSDictionary * metadata,
                                        NSURL * url,
                                        NSError * error)
    {
        // *** Do something with the image and its URL ***
        NSLog(@"Save results.");
    };


    self.cameraView.captureResultBlock = ^(UIImage * image,
                                           NSError * error)
    {
        if (!error)
        {
            NSLog(@"CaptureResultBlock.");
        }
    };
    
    RODCameraViewController *cvc = [[RODCameraViewController alloc] init];
    [cvc.RODCamera setFrame:self.navigationController.view.window.frame];
    [cvc.view setFrame:self.navigationController.view.window.frame];
    [cvc.view layoutSubviews];

    cvc.selected = self.selected;

    [self.navigationController pushViewController:cvc animated:YES];
    
    return;
    
//    [NBUImagePickerController startPickerWithTarget:self
//                                            options:(NBUImagePickerOptionReturnMediaInfo |    NBUImagePickerOptionDisableConfirmation |
//                                                     NBUImagePickerOptionSingleImage |
//                                                     NBUImagePickerOptionDisableFilters |
//                                                     NBUImagePickerOptionDisableCrop
//                                                     )
//                                            nibName:nil
//                                        resultBlock:^(NSArray * mediaInfos)
//     {
//         NSLog(@"Picker finished with media info: %@", mediaInfos);
//         
//         if(mediaInfos == nil) {
//             
//             [self.navigationController popViewControllerAnimated:YES];
//             
//             return;
//         }
//         
//         NBUMediaInfo *m = mediaInfos[0];
//         
//         [self dismissViewControllerAnimated:NO completion:nil];
//         
//         UIImage *image = m.editedImage;
//         CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
//         CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
//         
//         NSString *key = (__bridge NSString *)newUniqueIDString;
//         
//         CFRelease(newUniqueIDString);
//         CFRelease(newUniqueID);
//         
//         // now push to confirm snap
//         
//         ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
//         confirm.snap = image;
//         confirm.key = key;
//         confirm.handle = self.selected;
//         
//         NSLog(@"Snap going to self.selected.id: %@", self.selected.id);
//         
//         // old
//         [self.navigationController pushViewController:confirm animated:YES];
//         
//     }];
    
    //if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    //} else {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //}
    
    //[self.imagePicker setDelegate:self];
    
    //[self presentViewController:self.imagePicker animated:YES completion:nil];

    
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
    
    [self.navigationController pushViewController:confirm animated:YES];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.contactsViewController.navigationController popToRootViewControllerAnimated:YES];
    
}


@end
