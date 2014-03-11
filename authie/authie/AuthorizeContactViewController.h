//
//  AuthorizeContactViewController.h
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//
@class RODThread;

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AuthorizeContactViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UILabel *labelRequestDetails;
- (IBAction)acceptAuthorization:(id)sender;
- (IBAction)denyAuthorization:(id)sender;
- (IBAction)block:(id)sender;
- (IBAction)blockHandle:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (strong, nonatomic) RODThread *thread;
@property (weak, nonatomic) IBOutlet UIView *viewAuthorization;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnDeny;
@property (weak, nonatomic) IBOutlet UIButton *btnBlock;

- (void)loadThread:(int)row;

@end
