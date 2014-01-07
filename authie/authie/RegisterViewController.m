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
        
        // isAvailable refers to whether or not we have checked to see
        // if the user's handle is available to register on the site.
        self.isAvailable = NO;
        
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

- (BOOL)prefersStatusBarHidden
{
    return YES;    
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

- (IBAction)registerHandle:(id)sender {

    UIAlertView *alert;
    
    if(self.isAvailable == NO) {
    
        alert = [[UIAlertView alloc] initWithTitle: @"Handle" message: @"Please choose an available handle." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return;
        
    } else {
        // okay, now register it for real
        bool registered = [[RODItemStore sharedStore] registerHandle:self.handle];
        
        if(registered == YES) {
            // show the main screen?
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            
            alert = [[UIAlertView alloc] initWithTitle:@"Handle" message:@"We were unable to register your handle. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
}

- (IBAction)authieHandleChanged:(id)sender {
    
    if([self.authieHandle text].length > 2) {
        [self.handleAvailability setHidden:false];
        [self checkHandleAvailability];
    } else {
        [self.handleAvailability setHidden:true];
    }
}


- (void)checkHandleAvailability
{
    
    NSString *check_handle = [self.authieHandle text];
    NSString *check_result;
    
    self.handle = check_handle;
    
    BOOL check_status = [[RODItemStore sharedStore] checkHandleAvailability:check_handle];
    
    if(check_status == YES) {
        check_result = [NSString stringWithFormat:@"%@ is available.", check_handle];
        self.isAvailable = YES;
    } else {
        check_result = [NSString stringWithFormat:@"%@ is not available.", check_handle];
        self.isAvailable = NO;
    }
    
    [self.handleAvailability setText:check_result];
        
}
@end
