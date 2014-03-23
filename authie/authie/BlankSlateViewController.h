//
//  BlankSlateViewController.h
//  authie
//
//  Created by Seth Hayward on 1/26/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <BButton/BButton.h>
#import <NBUImagePicker/NBUCameraViewController.h>


@interface BlankSlateViewController : NBUCameraViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet BButton *buttonSendPic;
@property (weak, nonatomic) IBOutlet BButton *buttonAddContact;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelDetails;
- (IBAction)addContact:(id)sender;

@end
