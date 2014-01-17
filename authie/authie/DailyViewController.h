//
//  DailyViewController.h
//  authie
//
//  Created by Seth Hayward on 1/11/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyViewController : UIViewController
{
    NSMutableArray *_items;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (nonatomic) int contentSize;

- (void)populateScrollView;

@end
