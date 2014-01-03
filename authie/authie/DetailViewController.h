//
//  DetailViewController.h
//  authie
//
//  Created by Seth Hayward on 12/6/13.
//  Copyright (c) 2013 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RODSelfie.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) RODSelfie *snap;
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIImageView *SnapView;
@property (weak, nonatomic) IBOutlet UILabel *SnapLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
