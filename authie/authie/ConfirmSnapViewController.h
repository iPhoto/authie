//
//  ConfirmSnapViewController.h
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RODHandle;

@interface ConfirmSnapViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (weak, nonatomic) IBOutlet UITextView *snapCaption;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) UIImage *snap;
@property (strong, nonatomic) RODHandle *handle;
- (IBAction)addCaption:(id)sender;

@end
