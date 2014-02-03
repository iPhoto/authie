//
//  SelectContactViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

@class RODHandle;
#import <NBUImagePicker/NBUCameraViewController.h>
#import <UIKit/UIKit.h>

@interface SelectContactViewController : NBUCameraViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) RODHandle *selected;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@end
