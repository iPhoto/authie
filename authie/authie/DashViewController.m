//
//  DashViewController.m
//  authie
//
//  Created by Seth Hayward on 1/10/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "DashViewController.h"
#import "RODItemStore.h"
#import "RODImageStore.h"
#import "RODHandle.h"
#import <MRProgress/MRProgress.h>
#import "MiniThreadViewController.h"
#import "RODThread.h"
#import "RODAuthie.h"
#import "NSDate+PrettyDate.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "ConfirmSnapViewController.h"

@implementation DashViewController
@synthesize handle, contentSize, imageToUpload, keyToUpload, handleToUpload, captionToUpload, doUploadOnView, imagePicker, selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        _items = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSnap:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.titleView = [[RODItemStore sharedStore] generateHeaderView];
    
    self.navigationItem.title = @"Dashboard";
    
    self.imagePicker = [[UIImagePickerController alloc] init];

}

- (void)sendSnap:(id)sender
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.selectContactViewController animated:YES];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self populateScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    if(self.doUploadOnView) {
        [self doUpload];
    }
    
    if(self.doGetThreadsOnView) {
        [self getThreads];
        self.doGetThreadsOnView = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 40, 40)];
    [button_menu setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    self.navigationItem.leftBarButtonItem = leftDrawerButton;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSArray *viewsToRemove = [self.scroll subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    
    //[self populateScrollView];
}

- (void)getThreads
{
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"downloading, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.navigationController.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];

        [[RODItemStore sharedStore] getThreadsFromHandle:handle.publicKey];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
            [self populateScrollView];
            [progressView dismiss:YES];
        });
    });
    
}

- (void)populateScrollView
{
    
    MiniThreadViewController *mini;
    int yOffset = 0;
    
    int photo_height = 400;

    // remove the threads that were there before
    [[self.scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    

    [_items removeAllObjects];

    for(int i=0; i < [[RODItemStore sharedStore].authie.all_Threads count]; i++) {
        
        if(i > 10) break;
        
        RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:i];
        mini = [[MiniThreadViewController alloc] init];

        UIImage *image =[[RODImageStore sharedStore] imageForKey:thread.groupKey];

        mini.view.frame = CGRectMake(0, yOffset, self.scroll.frame.size.width, photo_height);
        [mini.view setClipsToBounds:YES];

        [mini.snapView setContentMode:UIViewContentModeScaleAspectFill];
        [mini.snapView setImage:image];

        
        [mini.labelDate setText:[NSString stringWithFormat:@"snapped by %@ %@", thread.fromHandle.name, [thread.startDate prettyDate]]];
        
        [mini.heartsView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapHearts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeart:)];
        [mini.heartsView addGestureRecognizer:tapHearts];
        
        
        
        [mini.snapView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
        [mini.snapView addGestureRecognizer:tapView];
        
        int mini_tag = i*100;
        int imageview_tag = (i+100)*1000;
        int report_tag = (i+900)*2000;
        mini.heartsView.tag = mini_tag;
        mini.snapView.tag = imageview_tag;
        mini.reportView.tag = report_tag;
        
        if(thread.caption == (id)[NSNull null] || thread.caption.length == 0 ) {
            mini.labelCaption.text = @"";
        } else {
            mini.labelCaption.text = thread.caption;
        }
        
        mini.heartsCount.text = [NSString stringWithFormat:@"%i", [thread.hearts intValue]];
        
        
        [mini.reportView setHidden:YES];

        [mini.view layoutSubviews];
        
        //photo_height = mini.snapView.image.size.height + 10;
        
        yOffset = yOffset + photo_height;
        
        [_items addObject:mini];
        
        [self.scroll addSubview:mini.view];
        
    }

    self.contentSize = yOffset;
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.contentSize)];
    
}

- (void)tappedImageView:(UITapGestureRecognizer *)tapGesture
{
    
    int thread_index = ([tapGesture.view tag] / 1000) - 100;
    
    //MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    RODThread *thread = [[RODItemStore sharedStore].authie.all_Threads objectAtIndex:thread_index];
    
    Boolean is_authorize_request = NO;
    
    if([thread.authorizeRequest isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        
        appDelegate.authorizeContactViewController = [[AuthorizeContactViewController alloc] init];
        [appDelegate.dashViewController.navigationController pushViewController:appDelegate.authorizeContactViewController animated:YES];
        is_authorize_request = YES;
        
    } else {
        
        appDelegate.threadViewController = [[ThreadViewController alloc] init];        
        [appDelegate.dashViewController.navigationController pushViewController:appDelegate.threadViewController animated:YES];
        
    }
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    [progressView setTitleLabelText:@""];
    [self.view.window addSubview:progressView];
    [progressView show:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [[RODImageStore sharedStore] preloadImageAndShowScreen:thread_index];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
            if(is_authorize_request == YES) {
                [appDelegate.authorizeContactViewController loadThread:thread_index];
            } else {
                [appDelegate.threadViewController loadThread:thread_index];
            }
            
            [progressView dismiss:YES];
            
            
        });
    });
    
}


- (void)clickedHeart:(UITapGestureRecognizer *)tapGesture
{
 
    NSLog(@"clicked heart...");
    
    int thread_index = [tapGesture.view tag] / 100;
    RODThread *thread = [[RODItemStore sharedStore].loadedThreadsFromAuthor objectAtIndex:thread_index];
    
    // run update interface code before calling web service
    MiniThreadViewController *lil_t = [_items objectAtIndex:thread_index];
    int more_hearts = [thread.hearts intValue] + 1;
    [lil_t.heartsCount setText:[NSString stringWithFormat:@"%i", more_hearts]];
    thread.hearts = [NSNumber numberWithInt:more_hearts];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        
        [[RODItemStore sharedStore] giveLove:thread.groupKey];
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
        });
    });
    
    
}

- (void)resetUploadVariables
{
    self.doUploadOnView = NO;
    self.keyToUpload = @"";
    self.imageToUpload = [UIImage alloc];
    self.captionToUpload = @"";
}

- (void)doUpload
{
    
    // Block whole window
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"uploading, pls chill a moment";
    progressView.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self.navigationController.view.window addSubview:progressView];
    
    [progressView show:YES];
    
    [[RODImageStore sharedStore] setImage:self.imageToUpload forKey:self.keyToUpload];
    NSLog(@"Created key: %@", self.keyToUpload);
    [[RODItemStore sharedStore] createSelfie:self.keyToUpload];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        [[RODItemStore sharedStore] startThread:self.handleToUpload.publicKey forKey:self.keyToUpload withCaption:self.captionToUpload];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [self resetUploadVariables];
            [[RODItemStore sharedStore] loadThreads];
            [progressView dismiss:YES];
            
        });
    });
    
}



- (void)addContact
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"request authorization"
                                                    message:@"if you want to add someone, you will need to send verification. we suggest a selfie. enter their handle to begin."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"take image", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
}

- (void)showAuthorizationRequestImagePicker
{
    self.imagePicker = nil;
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self.imagePicker setDelegate:self];
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [[RODItemStore sharedStore] addContact:name];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    NSString *key = (__bridge NSString *)newUniqueIDString;
    
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    
    // now push to confirm snap
    //...
    
    ConfirmSnapViewController *confirm = [[ConfirmSnapViewController alloc] init];
    confirm.snap = image;
    confirm.key = key;
    confirm.handle = self.selected;
    
    [self.navigationController pushViewController:confirm animated:YES];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    self.imagePicker = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.dashViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
    
    [appDelegate.contactsViewController.navigationController popToRootViewControllerAnimated:YES];
    
    [alert show];
    
}


@end
