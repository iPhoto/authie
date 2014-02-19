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
#import "ContactsViewController.h"
#import "PrivateKeyViewController.h"
#import "SelectContactViewController.h"
#import "DashViewController.h"
#import "RODHandle.h"
#import "RODAuthie.h"
#import <MRProgress/MRProgress.h>

@implementation MenuViewController
@synthesize buttons;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttons = @[@"Dash", @"Add", @"Private Key", @"About"];
    self.subtitles = @[@"your snaps", @"add a bff's handle", @"its a password you can forget", @"what is authie?"];
    
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
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:9];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 0;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView setNeedsDisplay];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (indexPath.row) {
        case 0: // dash
        {
            [self showDashboard];
        }
            break;
//        case 1: // profile
//        {
//            appDelegate.profileViewController = [[ProfileViewController alloc] init];
//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.profileViewController];
//            appDelegate.profileViewController.handle = [RODItemStore sharedStore].authie.handle;
//            self.frostedViewController.contentViewController = navigationController;
//        }
//            break;
//        case 2: // contacts
//        {
//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.contactsViewController];
//            self.frostedViewController.contentViewController = navigationController;
//        }
//            break;
//        case 3: // compose
//        {
//            [self showSelectContact];
//        }
//            break;
//        case 4: // daily
//        {
//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.dailyViewController];
//            self.frostedViewController.contentViewController = navigationController;
//        }
//            break;
//        case 1: // invite
//        {
//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.inviteViewController];
//            self.frostedViewController.contentViewController = navigationController;
//        }
//            break;
//        case 1: // add
//        {
//            [appDelegate.dashViewController addContact];
//        }
            break;
        case 2: // private key
        {
            [[RODItemStore sharedStore] getPrivateKey];
//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.privateKeyViewController];
//            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 3: // about
        {

//            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.aboutViewController];
//            self.frostedViewController.contentViewController = navigationController;
        }
            break;
            
    }
    
//    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

-(void)showSelectContact
{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.dashViewController];
    
    [appDelegate.dashViewController.navigationController pushViewController:appDelegate.selectContactViewController animated:YES];
    
//    self.frostedViewController.contentViewController = navigationController;
//    
}

- (void)showDashboard
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.dashViewController];
    
    [appDelegate.dashViewController clearScrollView];
    [appDelegate.dashViewController getThreads];
    //self.frostedViewController.contentViewController = navigationController;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.text = self.subtitles[indexPath.row];
    cell.textLabel.text = self.buttons[indexPath.row];
    
    return cell;
}
@end
