//
//  MiniThreadViewController.h
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniThreadViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIView *heartsView;
@property (weak, nonatomic) IBOutlet UILabel *heartsCount;
@property (weak, nonatomic) IBOutlet UIView *reportView;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIImageView *heartsImage;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;
@property (weak, nonatomic) IBOutlet UIView *heartsVotingView;

@property (nonatomic) bool *voted;

@end
