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
#import "RODHandle.h"
#import "RODAuthie.h"
#import <MRProgress/MRProgress.h>

@implementation MenuViewController
@synthesize buttons;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttons = @[@"Inbox", @"Profile", @"Contacts", @"Compose", @"The Daily", @"Invite", @"Private Key"];
    
    self.tableView = [[UITableView alloc] init]; // Frame will be automatically set
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
        
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
        case 0: // inbox
        {
            
            
            MRProgressOverlayView *progressView = [MRProgressOverlayView new];
            progressView.titleLabelText = @"";
            [progressView setTintColor:[UIColor blackColor]];
            progressView.titleLabel.font = [UIFont systemFontOfSize:10];

            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.masterViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;

            [appDelegate.masterViewController.view addSubview:progressView];
            
            
            [progressView show:YES];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                // Perform async operation
                [[RODItemStore sharedStore] loadThreads];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Update UI
                    [progressView dismiss:YES];
                });
            });
            
            
            
        }
            break;
        case 1: // profile
        {
                        
            appDelegate.profileViewController = [[ProfileViewController alloc] init];
            
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.profileViewController];
            appDelegate.profileViewController.handle = [RODItemStore sharedStore].authie.handle;
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 2: // contacts
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.contactsViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 3: // compose
        {
            
            [self showSelectContact];
            
        }
            break;
        case 4: // daily
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.dailyViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 5: // invite
        {
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.inviteViewController];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            self.frostedViewController.contentViewController = navigationController;
        }
            break;
        case 6: // private key
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

-(void)showSelectContact
{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:appDelegate.selectContactViewController];
    [navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.frostedViewController.contentViewController = navigationController;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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
