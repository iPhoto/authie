//
//  CameraViewController.m
//  authie
//
//  Created by Seth Hayward on 2/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "CameraViewController.h"
#import <NBUImagePicker/NBUImagePickerController.h>
#import <NBUImagePicker/NBUMediaInfo.h>
#import "AppDelegate.h"

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *littleView;

@end

@implementation CameraViewController

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
                                                     @[@"off", @"on", @"auto"]];
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
    };
    
    
    [NBUImagePickerController startPickerWithTarget:self
                                            options:(NBUImagePickerOptionReturnMediaInfo |    NBUImagePickerOptionDisableConfirmation |
                                                     NBUImagePickerOptionSingleImage |
                                                     NBUImagePickerOptionDisableFilters |
                                                     NBUImagePickerOptionDisableCrop
                                                     )
                                            customStoryboard:nil
                                        resultBlock:^(NSArray * mediaInfos)
     {
         NSLog(@"Picker finished with media info: %@", mediaInfos);
         
         if(mediaInfos == nil) {
             
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             
             [self.navigationController popViewControllerAnimated:YES];
             
             return;
         }
         
         NBUMediaInfo *m = mediaInfos[0];
         
         
     }];
    
    //if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    //} else {
    //    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //}
    
    //[self.imagePicker setDelegate:self];
    
    //[self presentViewController:self.imagePicker animated:YES completion:nil];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
