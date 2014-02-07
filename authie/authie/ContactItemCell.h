//
//  ContactItemCell.h
//  authie
//
//  Created by Seth Hayward on 2/2/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RODHandle.h"

@interface ContactItemCell : UITableViewCell

- (IBAction)btnRemove:(id)sender;
- (IBAction)btnBlock:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonBlock;
@property (weak, nonatomic) IBOutlet UIButton *buttonRemove;

@property (weak, nonatomic) IBOutlet UIImageView *mostRecentSnap;

@property (weak, nonatomic) IBOutlet UILabel *contactName;

@property (weak, nonatomic) RODHandle *handle;


@end
