//
//  ProfileViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

@class RODHandle;
#import <UIKit/UIKit.h>

@interface DashViewController : UIViewController <UIImagePickerControllerDelegate>
{
    NSMutableArray *_items;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) RODHandle *handle;
@property (nonatomic) int contentSize;
@property (nonatomic) BOOL doGetThreadsOnView;
@property (nonatomic) BOOL doUploadOnView;


@property (strong, nonatomic) UIImage *imageToUpload;
@property (strong, nonatomic) NSString *keyToUpload;
@property (strong, nonatomic) RODHandle *handleToUpload;
@property (strong, nonatomic) NSString *captionToUpload;


- (void)populateScrollView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) RODHandle *selected;

- (void)showAuthorizationRequestImagePicker;
- (void)addContact;


@end
