//
//  ColorViewController.m
//  authie
//
//  Created by Seth Hayward on 2/17/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ColorViewController.h"
#import <NKOColorPickerView/NKOColorPickerView.h>
#import "AppDelegate.h"
#import "ConfirmSnapViewController.h"
#import "RODItemStore.m"

@interface ColorViewController ()

@end

@implementation ColorViewController
@synthesize pickerView;

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
    
    __weak ColorViewController *weakSelf = self;
    
    [self.pickerView setDidChangeColorBlock:^(UIColor *color){
        [weakSelf _customizeButton];
    }];
    
    
}

- (void)_customizeButton
{
    
    //[RODItemStore sharedStore].selectedColor = pickerView.color;
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
