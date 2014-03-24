//
//  RODCameraViewController.m
//  authie
//
//  Created by Seth Hayward on 3/7/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "RODCameraViewController.h"
#import <NBUImagePicker/NBUCameraView.h>
#import "ConfirmSnapViewController.h"
#import "RODHandle.h"

@implementation RODCameraViewController
@synthesize snap, selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.RODCamera = [[NBUCameraView alloc] initWithFrame:self.view.window.frame];
    self.RODCamera.targetResolution = CGSizeMake(640.0, 640.0); // The minimum resolution we want
    self.RODCamera.keepFrontCameraPicturesMirrored = YES;
    self.RODCamera.captureResultBlock = ^(UIImage * image,
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
    
    
    self.RODCamera.flashButtonConfigurationBlock = [self.RODCamera buttonConfigurationBlockWithTitleFrom:
                                                     @[@"off", @"on", @"auto"]];
    self.RODCamera.focusButtonConfigurationBlock = [self.RODCamera buttonConfigurationBlockWithTitleFrom:
                                                     @[@"Fcs Lckd", @"Fcs Auto", @"Fcs Cont"]];
    self.RODCamera.exposureButtonConfigurationBlock = [self.RODCamera buttonConfigurationBlockWithTitleFrom:
                                                        @[@"Exp Lckd", @"Exp Auto", @"Exp Cont"]];
    self.RODCamera.whiteBalanceButtonConfigurationBlock = [self.RODCamera buttonConfigurationBlockWithTitleFrom:
                                                            @[@"WB Lckd", @"WB Auto", @"WB Cont"]];
    
    [self.RODCamera setSavePicturesToLibrary:YES];
    
    
    // Configure for video
    //self.cameraView.targetMovieFolder = [UIApplication sharedApplication].temporaryDirectory;
    
    // Optionally auto-save pictures to the library
    self.RODCamera.saveResultBlock = ^(UIImage * image,
                                        NSDictionary * metadata,
                                        NSURL * url,
                                        NSError * error)
    {
        // *** Do something with the image and its URL ***
        NSLog(@"Save results.");

        //NSLog(@"Picker finished with media info: %@", mediaInfos);
        [self confirmSnap:image];
        image = nil;
        //if(mediaInfos == nil) {
        //    [self.navigationController popViewControllerAnimated:YES];
        //    return;
        //}
        
        //NBUMediaInfo *m = mediaInfos[0];
        
        //[self dismissViewControllerAnimated:NO completion:nil];
        
        
    };
    
    
    self.RODCamera.captureResultBlock = ^(UIImage * image,
                                           NSError * error)
    {
        if (!error)
        {
            NSLog(@"CaptureResultBlock.");
        }
    };

    
    [self.RODCamera setToggleCameraButton:_toggle];
    [self.toggle addTarget:self.RODCamera action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    // Connect the shoot button
    [self.RODCamera setShootButton:_shoot];
    [self.shoot addTarget:self.RODCamera
                     action:@selector(takePicture:)
           forControlEvents:UIControlEventTouchUpInside];

    
    [self.RODCamera setFlashButton:_flash];
    
    [self.view addSubview:self.RODCamera];
    [self.view sendSubviewToBack:self.RODCamera];
    
}

-(void)confirmSnap:(UIImage *)sentSnap
{
    //UIImage *image = m.editedImage;
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;
    
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // now push to confirm snap
    
    ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
    confirm.snap = sentSnap;
    confirm.key = key;
    confirm.handle = self.selected;
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    NSLog(@"Snap going to self.selected.id: %@, self.selected.publicKey: %@", self.selected.id, self.selected.publicKey);
    
    // old
    [self.navigationController pushViewController:confirm animated:YES];
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleFlash:(id)sender {

    // We intentionally skip AVCaptureFlashModeAuto
    if (self.RODCamera.currentFlashMode == AVCaptureFlashModeOff)
    {
        self.RODCamera.currentFlashMode = AVCaptureFlashModeOn;
        //[self.flash setTitle:@"on" forState:UIControlStateNormal];
    }
    else
    {
        //[self.flash setTitle:@"off" forState:UIControlStateNormal];
        self.RODCamera.currentFlashMode = AVCaptureFlashModeOff;
    }

    
}
@end
