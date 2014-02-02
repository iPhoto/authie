//
//  ContactItemCell.h
//  authie
//
//  Created by Seth Hayward on 2/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *contactName;

@end
