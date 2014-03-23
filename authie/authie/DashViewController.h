//
//  ProfileViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

@class RODHandle;
@class RODThread;
#import <UIKit/UIKit.h>
#import <SignalR-ObjC/SignalR.h>
#import "GAITrackedViewController.h"
#import "BlankSlateViewController.h"
#import <NBUImagePicker/NBUCameraViewController.h>

@interface DashViewController : NBUCameraViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SRConnectionDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray *_items;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) RODHandle *handle;
@property (nonatomic) int contentSize;
@property (nonatomic) int photoHeight;
@property (nonatomic) BOOL doGetThreadsOnView;
@property (nonatomic) BOOL doUploadOnView;


@property (strong, nonatomic) UIImage *imageToUpload;
@property (strong, nonatomic) NSString *keyToUpload;
@property (strong, nonatomic) RODHandle *handleToUpload;
@property (strong, nonatomic) NSString *captionToUpload;
@property (strong, nonatomic) NSString *locationToUpload;
@property (strong, nonatomic) NSString *fontToUpload;
@property (strong, nonatomic) NSString *textColorToUpload;

- (void)getThreads;
- (void)populateScrollView;
- (void)clearScrollView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) RODHandle *selected;
@property (strong, nonatomic) RODThread *tappedThread;
@property (nonatomic) int tappedThreadIndex;

@property (strong, nonatomic) NSString *mostRecentGroupKey;

- (void)updateDashHeader;



@end
