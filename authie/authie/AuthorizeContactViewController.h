//
//  AuthorizeContactViewController.h
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//
@class RODThread;

#import <UIKit/UIKit.h>

@interface AuthorizeContactViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelRequestDetails;
- (IBAction)acceptAuthorization:(id)sender;
- (IBAction)denyAuthorization:(id)sender;
- (IBAction)block:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (strong, nonatomic) RODThread *thread;

- (void)loadThread:(int)row;

@end
