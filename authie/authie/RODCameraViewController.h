//
//  RODCameraViewController.h
//  authie
//
//  Created by Seth Hayward on 3/7/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NBUImagePicker/NBUCameraView.h>

@interface RODCameraViewController : UIViewController

@property (strong, nonatomic) IBOutlet NBUCameraView *RODCamera;
@property (weak, nonatomic) IBOutlet UIButton *shoot;


@end
