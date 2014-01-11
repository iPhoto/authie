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
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ContactsViewController.h"
#import "InviteViewController.h"
#import "PrivateKeyViewController.h"
#import "SelectContactViewController.h"

@implementation MenuViewController
@synthesize buttons;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttons = @[@"Inbox", @"Contacts", @"Invite", @"The Daily", @"Compose", @"Private Key"];
    
    self.tableView = [[UITableView alloc] init]; // Frame will be automatically set
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 29.0f)];
        view;
    });
    
    
    [self.tableView reloadData];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Friends Online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (indexPath.row) {
        case 0: // inbox
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.masterViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
            
            [[RODItemStore sharedStore] loadThreads];
            
        }
            break;
        case 1: // contacts
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.contactsViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 2: // invite
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.inviteViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 3: // daily
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.dailyViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 4: // compose
        {
            SelectContactViewController *select = [[SelectContactViewController alloc] init];
            
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.masterViewController];
            [appDelegate.masterViewController.navigationController pushViewController:select animated:YES];
            
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 5: // private key
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.privateKeyViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
    }
    
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.buttons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.buttons[indexPath.row];
    
    return cell;
}
@end
