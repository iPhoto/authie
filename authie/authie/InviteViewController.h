//
//  InviteViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteViewController : UIViewController <UITextViewDelegate>
{
    NSString *placeholderText;
}
- (IBAction)sendInvite:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;

@end
