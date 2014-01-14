//
//  AuthorizeContactViewController.m
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "AuthorizeContactViewController.h"
#import "RODThread.h"
#import "RODImageStore.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODHandle.h"

@implementation AuthorizeContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeThread:)];
        
        self.navigationItem.rightBarButtonItem = edit;
        
        
        
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

- (IBAction)tappedScreen:(id)sender {
    if(self.viewAuthorization.hidden == YES) {
        [self.viewAuthorization setHidden:NO];
    } else {
        [self.viewAuthorization setHidden:YES];
    }
}

-(void)removeThread:(id)sender
{
    [[RODItemStore sharedStore] removeThread:self.thread];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)acceptAuthorization:(id)sender {
    [[RODItemStore sharedStore] authorizeContact:self.thread.toHandle.publicKey];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)denyAuthorization:(id)sender {
    // same as trashing it
    [[RODItemStore sharedStore] removeThread:self.thread];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)block:(id)sender {
    UIAlertView *block = [[UIAlertView alloc] initWithTitle:@"block" message:@"block is not implemented yet." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [block show];
}

-(void)loadThread:(int)row
{
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:thread.groupKey]];
    self.thread = thread;
    
    NSLog(@"thread: %@", thread.toHandleId);
    
    if([[RODItemStore sharedStore].authie.handle.name isEqualToString:thread.toHandleId]) {
        // sent TO them, so display controls
        self.labelRequestDetails.text = [NSString stringWithFormat:@"You have received an authorization request from %@.", self.thread.fromHandleId];
        [self.btnAccept setHidden:NO];
        [self.btnDeny setHidden:NO];
        [self.btnBlock setHidden:NO];    

        [self.navigationItem setTitle:self.thread.fromHandleId];
        
    } else {
        // sent FROM them, so hide controls

        [self.navigationItem setTitle:[NSString stringWithFormat:@"sent to %@", self.thread.toHandleId]];

        
        self.labelRequestDetails.text = [NSString stringWithFormat:@"You sent an authorization request to %@.", self.thread.toHandle.name];
        [self.btnAccept setHidden:YES];
        [self.btnDeny setHidden:YES];
        [self.btnBlock setHidden:YES];
    }
    
}
@end
