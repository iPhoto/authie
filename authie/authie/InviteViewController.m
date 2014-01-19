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
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithTitle:@"invite" style:UIBarButtonItemStylePlain target:self action:@selector(sendInvite:)];
        
        self.navigationItem.rightBarButtonItem = inviteButton;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];

    placeholderText = self.messageText.text;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateSettingsCog:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Hello: %@", textView.text);
    if([textView.text isEqualToString:placeholderText]) {
        [textView setText:@""];
    }
}

- (IBAction)sendInvite:(id)sender {
    [[RODItemStore sharedStore] invite:self.emailText.text message:self.messageText.text];
}
@end
