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

    UINib *nib = [UINib nibWithNibName:@"ContactItemCell" bundle:nil];
    [self.contactsTable registerNib:nib forCellReuseIdentifier:@"ContactItemCell"];
    
    [self.contactsTable setRowHeight:100];
    
    self.navigationItem.title = @"send snap to:";
    
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

    [cell.mostRecentSnap setImage:mostRecent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];
    
    self.selected = handle;
        
    //self.imagePicker = nil;
    //self.imagePicker = [[UIImagePickerController alloc] init];
    
    // Configure the camera view
    //self.cameraView.shouldAutoRotateView = YES;
    //self.cameraView.savePicturesToLibrary = YES;
    self.cameraView.targetResolution = CGSizeMake(640.0, 640.0); // The minimum resolution we want
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
                                            options:(NBUImagePickerOptionReturnMediaInfo)
                                            nibName:nil
                                        resultBlock:^(NSArray * mediaInfos)
     {
         NSLog(@"Picker finished with media info: %@", mediaInfos);
         
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
    self.imagePicker = nil;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.dashViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];

    [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];

    [alert show];
    
}

@end
