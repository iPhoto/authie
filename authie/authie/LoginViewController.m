//
//  LoginViewController.m
//  authie
//
//  Created by Seth Hayward on 1/11/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "LoginViewController.h"
#import "RODItemStore.h"
#import "AppDelegate.h"
#import <MRProgress/MRProgress.h>
#import "RODAuthie.h"
#import <GAITrackedViewController.h>
#import "RODImageStore.h"

@implementation LoginViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Login";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.backgroundImage setImage:[[RODImageStore sharedStore] imageForKey:@"B14253A0-E5D0-43DB-A1E1-629EED91FCBE"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doLogin:(id)sender {
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"syncing, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self.navigationController.view.window addSubview:progressView];

    [self.textHandle resignFirstResponder];
    [self.textKey resignFirstResponder];
    
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        [[RODItemStore sharedStore] login:self.textHandle.text privateKey:self.textKey.text];
       
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [progressView dismiss:YES];
            
            if([RODItemStore sharedStore].authie.registered == 1) {
                [[RODItemStore sharedStore] loadThreads];
                [[RODItemStore sharedStore] loadContacts];
                [[RODItemStore sharedStore] loadMessages];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.dashViewController setDoGetThreadsOnView:YES];
                
                [appDelegate.navigationViewController popToRootViewControllerAnimated:NO];
                
            }
            
        });
    });
    
}

- (IBAction)cancel:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.dashViewController.navigationController popToViewController:appDelegate.registerViewController animated:YES];
    
}

@end
