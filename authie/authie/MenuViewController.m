//
//  MenuViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 Seth Hayward. All rights reserved.
//

#import "MenuViewController.h"
#import "RODItemStore.h"
#import "AppDelegate.h"
#import <REFrostedViewController.h>
#import "UIViewController+REFrostedViewController.h"

@implementation MenuViewController

-(void)viewDidLoad
{
 
    
    NSLog(@"view did load");
    menuItems = [NSArray arrayWithObjects:@"one", @"private key", @"lol", nil];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = @"Roman Efimov";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
    
    [self.menuHeaderView addGestureRecognizer:singleTap];
    
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"view will appear");

    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
//    NSLog(@"Top class: %@", [[appDelegate.navigationController visibleViewController] class]);
    
    
}

- (UIView *)menuHeaderView
{
    if (!menuHeaderView) {
        [[NSBundle mainBundle] loadNibNamed:@"MenuHeader" owner:self options:nil];
    }
    
    return menuHeaderView;
}


- (void)oneTap:(UIGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self menuHeaderView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self menuHeaderView] bounds].size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItems count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UITableViewCell *)tableView:(UITableView *)a_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [a_tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    
    NSString *s = [menuItems objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:s];
    
    //if([p checked]) {
    //    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //} else {
    //    cell.accessoryType = UITableViewCellAccessoryNone;
    //}
    
    return cell;
}

- (void)tableView:(UITableView *)a_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // reload the data so the checkbox updates
    [a_tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
