//
//  BlankSlateViewController.m
//  authie
//
//  Created by Seth Hayward on 1/26/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "BlankSlateViewController.h"
#import "RODItemStore.h"

@interface BlankSlateViewController ()

@end

@implementation BlankSlateViewController

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
    
    UIFont *f = [UIFont fontWithName:@"LucidaTypewriter" size:12.0f];
    UIFont *f10 = [UIFont fontWithName:@"LucidaTypewriter" size:10.0f];
    
    [self.labelDetails setFont:f10];
    [self.labelHeader setFont:f10];
    [self.buttonSendPic.titleLabel setFont:f];
    [self.buttonAddContact.titleLabel setFont:f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self.buttonAddContact setColor:[[RODItemStore sharedStore] colorFromHexString:@"#006700"]];
    [self.buttonSendPic setColor:[[RODItemStore sharedStore] colorFromHexString:@"#006700"]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"BlankSlate";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
