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
#import "RODItemStore.h"

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
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    __weak ColorViewController *weakSelf = self;
    
    [self.pickerView setDidChangeColorBlock:^(UIColor *color){
        [weakSelf _customizeButton];
    }];
    
    [self.pickerView setColor:[RODItemStore sharedStore].selectedColor];
    [self.pickerView setTintColor:[UIColor darkGrayColor]];
    
    [self _customizeButton];
    
}

- (void)_customizeButton
{
    [RODItemStore sharedStore].selectedColor = pickerView.color;
    [self.choose setTitleColor:pickerView.color forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseColor:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

@end
