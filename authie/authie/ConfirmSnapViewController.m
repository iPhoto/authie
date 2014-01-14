//
//  ConfirmSnapViewController.m
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ConfirmSnapViewController.h"
#import "AppDelegate.h"
#import "MasterViewController.h"

@implementation ConfirmSnapViewController
@synthesize snap, key, handle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.snapView setImage:self.snap];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(trashMessage:)];

    self.navigationItem.leftBarButtonItem = cancel;

    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendSnap:)];
    
    self.navigationItem.rightBarButtonItem = send;
    
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"textViewShouldBeginEditing:");
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing:");
//    self.snapCaption.backgroundColor = [UIColor greenColor];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSLog(@"textViewShouldEndEditing:");
//    self.snapCaption.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"textViewDidEndEditing:");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedScreen:(id)sender {
    [self.snapCaption resignFirstResponder];
    
}

-(void)sendSnap:(id)sender
{

    NSLog(@"Send snap.");
    [self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.masterViewController.imageToUpload = snap;
    appDelegate.masterViewController.keyToUpload = key;
    appDelegate.masterViewController.handleToUpload = handle;
    appDelegate.masterViewController.captionToUpload = self.snapCaption.text;
    [appDelegate.masterViewController setDoUploadOnView:true];
    [appDelegate.masterViewController.navigationController popToRootViewControllerAnimated:YES];

}

-(void)trashMessage:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.masterViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
    
    [appDelegate.masterViewController.navigationController popToRootViewControllerAnimated:YES];
    
    [alert show];
}

- (IBAction)addCaption:(id)sender {
//    [self.snapCaption setHidden:NO];
//    [self.snapCaption becomeFirstResponder];
    
}
@end
