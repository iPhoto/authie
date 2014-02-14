//
//  MessagesViewController.m
//  authie
//
//  Created by Seth Hayward on 2/6/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "MessagesViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODMessage.h"
#import "RODHandle.h"
#import "RODThread.h"
#import "ThreadViewController.h"
#import "AppDelegate.h"

@implementation MessagesViewController
@synthesize sortedMessages;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.navigationItem setTitle:@"messages"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"messages-white-v1"];


    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sentDate"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *oldestToNewestMessages = [[RODItemStore sharedStore].authie.allMessages sortedArrayUsingDescriptors:sortDescriptors];
    
    sortedMessages = [[oldestToNewestMessages reverseObjectEnumerator] allObjects];
    
    // mark all messages as read
    NSArray *tempMessages = [NSArray arrayWithArray:[RODItemStore sharedStore].authie.allMessages];
    for (int i = 0; i<[tempMessages count]; i++) {
        RODMessage *m = [tempMessages objectAtIndex:i];
        m.seen = [NSNumber numberWithInt:1];
        [[RODItemStore sharedStore].authie.allMessages setObject:m atIndexedSubscript:i];
    }
    [[RODItemStore sharedStore] saveChanges];
    
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
    return [sortedMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    RODMessage *msg = [sortedMessages objectAtIndex:indexPath.row];
    cell.textLabel.text = msg.fromHandle.name;
    cell.detailTextLabel.text = msg.messageText;
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RODMessage *msg = [sortedMessages objectAtIndex:indexPath.row];
    NSLog(@"Message: %@", msg.thread.groupKey);
    
    RODThread *thread;
    for(int i = 0; i< [[RODItemStore sharedStore].authie.all_Threads count]; i++)
    {
        thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:i];
        if([thread.groupKey isEqualToString:msg.thread.groupKey]) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            appDelegate.threadViewController = [[ThreadViewController alloc] init];
            [appDelegate.threadViewController loadThread:i];
            [appDelegate.threadViewController reloadThread];
            [appDelegate.navigationViewController pushViewController:appDelegate.threadViewController animated:YES];
            break;
        }
    }
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

@end
