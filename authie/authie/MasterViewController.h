//
//  MasterViewController.h
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlideNavigationController.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
