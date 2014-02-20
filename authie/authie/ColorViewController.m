//
//  ColorViewController.m
//  authie
//
//  Created by Seth Hayward on 2/17/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ColorViewController.h"
#import "RSColorPickerView.h"

@interface ColorViewController ()

@end

@implementation ColorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    RSColorPickerView *color = [[RSColorPickerView alloc] initWithFrame:self.colorView.frame];
    //[color setFrame:CGRectMake(0, 0, 180, 180)];
    self.colorPickerView = color;
    [self.colorView addSubview:color];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
