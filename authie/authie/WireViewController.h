//
//  WireViewController.h
//  authie
//
//  Created by Seth Hayward on 2/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WireViewController : UIViewController
{
    NSMutableArray *_items;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@property (nonatomic) int contentSize;
@property (nonatomic) int photoHeight;


-(void) getThreads;
-(void) populateScrollView;

@end
