//
//  LoginViewController.h
//  authie
//
//  Created by Seth Hayward on 1/11/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)doLogin:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textHandle;
@property (weak, nonatomic) IBOutlet UILabel *labelResults;
@property (weak, nonatomic) IBOutlet UITextField *textKey;

@end
