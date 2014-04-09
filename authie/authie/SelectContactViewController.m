//
//  SelectContactViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "SelectContactViewController.h"
#import "RODItemStore.h"
#import "RODAuthie.h"
#import "RODHandle.h"
#import "AppDelegate.h"
#import "RODImageStore.h"
#import "ConfirmSnapViewController.h"
#import "RODThread.h"
#import "ContactItemCell.h"
#import "AddContactCell.h"
#import <NBUImagePicker/NBUImagePickerController.h>
#import <NBUImagePicker/NBUMediaInfo.h>
#import <NBUImagePicker/NBUCameraViewController.h>
#import "RODCameraViewController.h"

@implementation SelectContactViewController
@synthesize editingContacts, tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
    }
    return self;
}

- (UIView *)addContactCell
{
    if (!_addContactCell) {
        [[NSBundle mainBundle] loadNibNamed:@"AddContactCell" owner:self options:nil];
    }
    
    return _addContactCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.tableView setRowHeight:100];
    
    UINib *nib = [UINib nibWithNibName:@"ContactItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ContactItemCell"];

    UIView *footer = self.addContactCell;
    [self.tableView setTableFooterView:footer];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    CGRect navItem = CGRectMake(0, 0, 120, 44);
    UILabel *navLabel = [[UILabel alloc] initWithFrame:navItem];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:10.0f];
    
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = @"send snap to:";
    self.navigationItem.titleView = navLabel;
    
    self.navigationItem.leftBarButtonItem = [[RODItemStore sharedStore] generateMenuItem:@"house-v5-white"];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    editingContacts = NO;

    self.screenName = @"SelectContact";

    [self.tableView reloadData];
    
}

- (IBAction)addContact:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add"
                                                    message:@"to add a friend, enter their Authie handle and send a snap (for example, a selfie) so they know it's you."
                                                                                                                                                                                                                                                                                                   delegate:self
                                          cancelButtonTitle:@"cancel"
                                          otherButtonTitles:@"take image", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 311;
    [alert show];
    
}

- (void)showAuthorizationRequestImagePicker
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RODCameraViewController *cvc = [[RODCameraViewController alloc] init];
    [cvc.RODCamera setFrame:appDelegate.dashViewController.navigationController.view.window.frame];
    [cvc.view setFrame:appDelegate.dashViewController.navigationController.view.window.frame];
    [cvc.view layoutSubviews];
    
    cvc.selected = self.selected;
    
    [self.navigationController pushViewController:cvc animated:YES];

}


-(IBAction)enableBlocking:(id)sender
{
    
    if(editingContacts == YES) {

        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self setEditingContacts:NO];
        
    } else {
        
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self setEditingContacts:YES];
    }
    
    [self.tableView reloadData];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendSnap:(id)sender
{
    NSLog(@"bye.");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger countContacts = [[RODItemStore sharedStore].authie.all_Contacts count];
    NSLog(@"Contacts: %i", countContacts);
    return countContacts;
    
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Hello: %i", indexPath.row);
    
    // figure out if this is the last row or not
    
//    NSInteger lastRowIndex = [tableView numberOfRowsInSection:0] - 1;
//    
//    if(indexPath.row == lastRowIndex) {
//        // last row
//
//        AddContactCell *addContactCell = [tableView dequeueReusableCellWithIdentifier:@"AddContactCell"];
//        
//        UITapGestureRecognizer *tapAdd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addContact:)];
//        [addContactCell.btnAdd addGestureRecognizer:tapAdd];
//        
//        UITapGestureRecognizer *tapEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enableBlocking:)];
//        [addContactCell.btnEdit addGestureRecognizer:tapEdit];
//        
//        [addContactCell.btnAdd.titleLabel setText:@"Add"];
//        
//        if(editingContacts == YES) {
//            [addContactCell.btnEdit.titleLabel setText:@"Done"];
//        } else {
//            [addContactCell.btnEdit.titleLabel setText:@"Edit"];
//        }
//                                          
//        return addContactCell;
//        
//    } else {
        // contact item row
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];

    NSLog(@"found: %@", handle.name);

    //UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"ContactItemCell" forIndexPath:indexPath];
    ContactItemCell *cell = [tv dequeueReusableCellWithIdentifier:@"ContactItemCell" forIndexPath:indexPath];
    
    [cell.contactName setText:handle.name];

//    cell.textLabel.text = handle.name;
    
    UIImage *mostRecent = [UIImage alloc];
    
    if(handle.mostRecentSnap == (id)[NSNull null] || handle.mostRecentSnap.length == 0) {
        // nothing
        
        mostRecent = [UIImage imageNamed:@"heart-green-filled-v1"];
        
        
    } else {
        mostRecent = [[RODImageStore sharedStore] imageForKey:handle.mostRecentSnap];
    }
    
    
    if(editingContacts == YES && indexPath.row > 0) {
        [cell.buttonBlock setHidden:NO];
        [cell.buttonRemove setHidden:NO];
        
        UITapGestureRecognizer *tapBlock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlock:)];
        [cell.buttonBlock addGestureRecognizer:tapBlock];
        
        UITapGestureRecognizer *tapRemove = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemove:)];
        [cell.buttonRemove addGestureRecognizer:tapRemove];
        
        [cell.buttonRemove setTag:(indexPath.row * 1000)];
        [cell.buttonBlock setTag:(indexPath.row * 1000) + 500000];
                
    } else {
        [cell.buttonBlock setHidden:YES];
        [cell.buttonRemove setHidden:YES];
    }
    
    [cell.mostRecentSnap setImage:mostRecent];
    
    return cell;
        
//    }
//    
    
}

- (void)tapBlock:(UITapGestureRecognizer *)tapGesture
{
    int row = (tapGesture.view.tag - 500000) / 1000;
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:row];
    
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"block" message:[NSString stringWithFormat:@"block %@? they will be unable to send you snaps.", handle.name] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"block", nil];
    
    self.selected = handle;

    
    a.tag = 200;
    [a show];
    
}

- (void)tapRemove:(UITapGestureRecognizer *)tapGesture
{
    int row = (tapGesture.view.tag) / 1000;
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:row];
    
    self.selected = handle;
    
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"remove" message:[NSString stringWithFormat:@"remove %@ as a contact?", handle.name] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"remove", nil];
    a.tag = 100;
    [a show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex == 0) {
        // cancel button
        return;
    }

    UIAlertView *bye;

    // figure out if it's a remove or a block
    switch(alertView.tag) {
        case 100:
            NSLog(@"clicked remove: %@", self.selected.name);
            [[RODItemStore sharedStore] removeContact:self.selected];
            [self.tableView reloadData];
            bye = [[UIAlertView alloc] initWithTitle:@"bye" message:[NSString stringWithFormat:@"%@ is removed from your list.", self.selected.name] delegate:self cancelButtonTitle:@"good" otherButtonTitles:nil];
            [bye show];
            break;
        case 200:
            NSLog(@"clicked block");
            [[RODItemStore sharedStore] addBlock:self.selected.publicKey];
            [self.tableView reloadData];
            
            bye = [[UIAlertView alloc] initWithTitle:@"bye" message:[NSString stringWithFormat:@"%@ is blocked.", self.selected.name] delegate:self cancelButtonTitle:@"good" otherButtonTitles:nil];
            [bye show];
            break;
        case 311:
            // add contact
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                [[RODItemStore sharedStore] addContact:name fromDash:NO];
            }

            break;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectRowAtIndexPath");
    
    
    if(editingContacts == YES) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    RODHandle *handle = [[RODItemStore sharedStore].authie.all_Contacts objectAtIndex:indexPath.row];
    self.selected = handle;
    
    RODCameraViewController *cvc = [[RODCameraViewController alloc] init];
    [cvc.RODCamera setFrame:self.navigationController.view.window.frame];
    [cvc.view setFrame:self.navigationController.view.window.frame];
    [cvc.view layoutSubviews];

    cvc.selected = self.selected;

    [self.navigationController pushViewController:cvc animated:YES];
    
    
}

@end
