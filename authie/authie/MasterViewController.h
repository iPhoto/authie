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

@interface MasterViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) DetailViewController *detailViewController;

- (void)showLoadingIndicator;

@end
