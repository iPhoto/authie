//
//  MasterViewController.h
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class SnapCreatorController;
@class RODHandle;

@interface MasterViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) UIImage *imageToUpload;
@property (strong, nonatomic) NSString *keyToUpload;
@property (strong, nonatomic) RODHandle *handleToUpload;
@property (nonatomic) BOOL doUploadOnView;

- (void)doUpload;

@end
