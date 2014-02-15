//
//  MessageItemCell.h
//  authie
//
//  Created by Seth Hayward on 2/15/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelHandle;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;

@end
