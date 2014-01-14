//
//  AuthorizeContactViewController.h
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizeContactViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelRequestDetails;
- (IBAction)acceptAuthorization:(id)sender;
- (IBAction)denyAuthorization:(id)sender;
- (IBAction)block:(id)sender;

@end
