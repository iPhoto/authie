//
//  RegisterViewController.h
//  authie
//
//  Created by Seth Hayward on 12/16/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController  <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *authieHandle;
@property (weak, nonatomic) IBOutlet UILabel *handleAvailability;
@property (nonatomic) bool isAvailable;
@property (copy, nonatomic) NSString *handle;
- (IBAction)tappedScreen:(id)sender;
- (IBAction)registerHandle:(id)sender;
- (IBAction)loginWithPrivateKey:(id)sender;

- (IBAction)authieHandleChanged:(id)sender;
- (void)checkHandleAvailability;
@end
