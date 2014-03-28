//
//  PrivateKeyViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <BButton/BButton.h>

@interface PrivateKeyViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UILabel *privateKey;

@property (weak, nonatomic) IBOutlet UILabel *privateKeyHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyTextLabel;
@property (weak, nonatomic) IBOutlet BButton *markAsReadButton;


- (IBAction)markRead:(id)sender;

@end
