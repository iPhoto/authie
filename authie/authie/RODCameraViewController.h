//
//  RODCameraViewController.h
//  authie
//
//  Created by Seth Hayward on 3/7/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NBUImagePicker/NBUCameraView.h>
@class RODHandle;

@interface RODCameraViewController : UIViewController

@property (strong, nonatomic) RODHandle *selected;
@property (strong, nonatomic) IBOutlet NBUCameraView *RODCamera;
@property (weak, nonatomic) IBOutlet UIButton *shoot;


@property (weak, nonatomic) UIImage *snap;


@end
