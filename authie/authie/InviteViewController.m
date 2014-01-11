//
//  InviteViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "InviteViewController.h"
#import "NavigationController.h"
#import "RODItemStore.h"
#import "RODHandle.h"
#import "RODAuthie.h"

@implementation InviteViewController

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
    
    UIView *holder = [[UIView alloc] init];
    [holder setFrame:CGRectMake(0, 0, 100, 35)];
    
    UIImage *image = [UIImage imageNamed:@"authie-logo-07-350px"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    [imageview setFrame:CGRectMake(0, 0, 100, 20)];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    
    [holder addSubview:imageview];
    
    UILabel *handleLabel = [[UILabel alloc] init];
    handleLabel.text = [RODItemStore sharedStore].authie.handle.name;
    [handleLabel setFont:[UIFont systemFontOfSize:10]];
    [handleLabel setFrame:CGRectMake(0, 25, 100, 10)];
    [handleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [holder addSubview:handleLabel];
    
    self.navigationItem.titleView = holder;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 40, 40)];
    [button_menu setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    self.navigationItem.leftBarButtonItem = leftDrawerButton;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
