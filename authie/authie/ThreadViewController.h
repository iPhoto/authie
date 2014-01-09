//
//  ThreadViewController.h
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RODThread.h"

@interface ThreadViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *threadFrom;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (weak, nonatomic) RODThread *thread;

- (void)setThread:(RODThread *)new_thread;


@end