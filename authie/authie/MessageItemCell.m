//
//  MessageItemCell.m
//  authie
//
//  Created by Seth Hayward on 2/15/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "MessageItemCell.h"

@implementation MessageItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
