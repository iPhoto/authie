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
#import "AppDelegate.h"
#import "RODItemStore.h"

@implementation AuthorizeContactViewController
@synthesize snapView;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.snapView setImage:[[RODImageStore sharedStore] imageForKey:self.thread.groupKey]];

    
    if([[RODItemStore sharedStore].authie.handle.name isEqualToString:self.thread.toHandle.name]) {
        // sent TO them, so display controls
        self.labelRequestDetails.text = [NSString stringWithFormat:@"%@ has sent you an authorization request. if you accept this request, %@ will be able to send you snaps and see snaps you've sent to the dash.", self.thread.fromHandleId, self.thread.fromHandleId];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    [self.snapView setImage:[UIImage alloc]];
    
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
    [[RODItemStore sharedStore] authorizeContact:self.thread.fromHandle.publicKey];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)denyAuthorization:(id)sender {
    // same as trashing it
    [[RODItemStore sharedStore] removeThread:self.thread];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)blockHandle:(id)sender {    
    
    [self deleteObject];
    [[RODItemStore sharedStore] addBlock:self.thread.fromHandle.publicKey];
    UIAlertView *bye = [[UIAlertView alloc] initWithTitle:@"bye" message:[NSString stringWithFormat:@"%@ is blocked.", self.thread.fromHandle.name] delegate:self cancelButtonTitle:@"good" otherButtonTitles:nil];
    [bye show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)loadThread:(int)row
{
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:row];
    self.thread = thread;
    
    NSLog(@"thread: %@", self.thread.fromHandle.name);
    
    
}

- (void)deleteObject
{
    NSMutableArray *tempThreads = [NSMutableArray arrayWithArray:[RODItemStore sharedStore].authie.allThreads];
    for(RODThread *r in tempThreads) {
        if([r.groupKey isEqualToString:self.thread.groupKey]) {
            [[RODItemStore sharedStore].authie.allThreads removeObject:r];
            [[RODItemStore sharedStore] saveChanges];
            NSLog(@"Thread found and removed.");
            break;
        }
        
    }
    
}
@end
