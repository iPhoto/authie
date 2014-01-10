//
//  ContactsViewController.m
//  authie
//
//  Created by Seth Hayward on 1/8/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ContactsViewController.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "RODAuthie.h"
#import "RODFollower.h"
#import "RODItemStore.h"

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_menu setFrame:CGRectMake(0, 0, 40, 40)];
        [button_menu setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
        [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
        self.navigationItem.leftBarButtonItem = leftDrawerButton;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
        self.navigationItem.rightBarButtonItem = addButton;
        
        self.navigationItem.title = @"Contacts";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"rows in section: %i", [[RODItemStore sharedStore].authie.all_Contacts count]);
    
    return [[RODItemStore sharedStore].authie.all_Contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts  objectAtIndex:indexPath.row];
    
    cell.textLabel.text = handle.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", handle.publicKey];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)addContact:(id)sender
{
    
    NSLog(@"add contact pls...");
    
    [[RODItemStore sharedStore] addContact:@"modest"];
    
}

@end
