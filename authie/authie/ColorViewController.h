//
//  ColorViewController.h
//  authie
//
//  Created by Seth Hayward on 2/17/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSColorPickerView.h"

@interface ColorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) RSColorPickerView *colorPickerView;
@end
