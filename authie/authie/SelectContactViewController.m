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

@implementation SelectContactViewController
@synthesize imagePicker, contactsTable, editingContacts;

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
    
    
    [self.contactsTable deselectRowAtIndexPath:[self.contactsTable indexPathForSelectedRow] animated:animated];

    self.cameraView.savePicturesToLibrary = YES;
    self.cameraView.backgroundColor = [UIColor whiteColor];
    self.cameraView.highlightColor = [UIColor blackColor];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.cameraView setAlpha:1.0f];
    [self.cameraView setOpaque:NO];
    
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enableBlocking:)];
    self.navigationItem.rightBarButtonItem = rightDrawerButton;
    
    editingContacts = NO;
    
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
        
        mostRecent = [UIImage imageNamed:@"heart-blue-v2.png"];
        
        
    } else {
        mostRecent = [[RODImageStore sharedStore] imageForKey:handle.mostRecentSnap];
    }
    
    if(editingContacts == YES && indexPath.row > 0) {
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
    
    // Configure for video
    //self.cameraView.targetMovieFolder = [UIApplication sharedApplication].temporaryDirectory;
        
    // Optionally auto-save pictures to the library
    self.cameraView.saveResultBlock = ^(UIImage * image,
                                        NSDictionary * metadata,
                                        NSURL * url,
                                        NSError * error)
    {
        // *** Do something with the image and its URL ***
    };

    

    [NBUImagePickerController startPickerWithTarget:self
                                            options:(NBUImagePickerOptionReturnMediaInfo |    NBUImagePickerOptionDisableConfirmation |
                                                     NBUImagePickerOptionSingleImage |
                                                     NBUImagePickerOptionDisableFilters |
                                                     NBUImagePickerOptionDisableCrop
                                                     )
                                            nibName:nil
                                        resultBlock:^(NSArray * mediaInfos)
     {
         NSLog(@"Picker finished with media info: %@", mediaInfos);
         
         if(mediaInfos == nil) {
             
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.dashViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
             
             [self.navigationController popViewControllerAnimated:YES];
             
             [alert show];
             return;
         }
         
         NBUMediaInfo *m = mediaInfos[0];
         
         [self dismissViewControllerAnimated:NO completion:nil];
         
         UIImage *image = m.editedImage;
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
         
     }];
    
    //if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    //} else {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //}
    
    //[self.imagePicker setDelegate:self];
    
    //[self presentViewController:self.imagePicker animated:YES completion:nil];

    
}



@end
