//
//  RegisterViewController.m
//  authie
//
//  Created by Seth Hayward on 12/16/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import "RODItemStore.h"
#import "RegisterViewController.h"
#define StringFromBOOL(b) ((b) ? @"YES" : @"NO")

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self checkHandleAvailability];
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)tappedScreen:(id)sender {
    [self.authieHandle resignFirstResponder];
    
    [self checkHandleAvailability];
}

- (IBAction)authieHandleChanged:(id)sender {
    [self checkHandleAvailability];
}


- (void)checkHandleAvailability
{
    
    NSString *check_handle = [self.authieHandle text];
    NSString *check_status = [NSString stringWithFormat:@"check %@, available: %@", check_handle, StringFromBOOL([[RODItemStore sharedStore] checkHandleAvailability:check_handle])];
    [self.handleAvailability setText:check_status];
        
}
@end
