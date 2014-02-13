//
//  ConfirmSnapViewController.m
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import "ConfirmSnapViewController.h"
#import "AppDelegate.h"
#import "RODHandle.h"
#import "RODItemStore.h"
#import <CoreLocation/CoreLocation.h>
#import <KxMenu/KxMenu.h>

@implementation ConfirmSnapViewController
@synthesize snap, key, handle, state;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    [self.snapView setImage:[UIImage alloc]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"ConfirmSnap";
    
    
    UIView *holder = [[UIView alloc] init];
    [holder setFrame:CGRectMake(0, 0, 200, 35)];
    
    UILabel *handleLabel = [[UILabel alloc] init];
    
    [handleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [handleLabel setFont:[UIFont systemFontOfSize:10]];
    [handleLabel setFrame:CGRectMake(0, 5, 200, 30)];
    [handleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [holder addSubview:handleLabel];
    
    self.navigationItem.titleView = holder;
    
    // dash post
    if([self.handle.name isEqualToString:@"dash"]) {
        handleLabel.text = [NSString stringWithFormat:@"%@'s dash post", self.handle.name];
    }     // wire post
    else if([self.handle.name isEqualToString:@"the wire"]) {
        handleLabel.text = nil;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        _currentLocation =  nil;
        
        
    } else {
        handleLabel.text = [NSString stringWithFormat:@"snap for %@", self.handle.name];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.snapView setImage:self.snap];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(trashMessage:)];

    self.navigationItem.leftBarButtonItem = cancel;

    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendSnap:)];
    
    self.navigationItem.rightBarButtonItem = send;

    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLocationView:)];
    [self.locationView addGestureRecognizer:tapView];
    
}

- (void)tappedLocationView:(UITapGestureRecognizer *)tapGesture
{
    
    
    [KxMenu showMenuInView:self.view
                  fromRect:self.locationView.frame
                 menuItems:@[
                             [KxMenuItem menuItem:@"None"
                                            image:[UIImage alloc]
                                           target:self
                                           action:@selector(menuItemAction:)],
                             [KxMenuItem menuItem:self.state
                                            image:[UIImage alloc]
                                           target:self
                                           action:@selector(menuItemAction:)]
                             ]];

}

- (void)menuItemAction:(KxMenuItem *)item
{
    
    if([item.title isEqualToString:@"None"]) {
        [self.placeName setText:@""];
    } else {
        [self.placeName setText:item.title];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    _currentLocation = locations[0];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    if (!geocoder)
        geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:
     ^(NSArray* placemarks, NSError* error){
         if ([placemarks count] > 0)
         {

             
             CLPlacemark *p = [placemarks objectAtIndex:0];
             [_locationManager stopUpdatingLocation];

             NSString *foundState = p.administrativeArea;

             NSString *path = [[NSBundle mainBundle] pathForResource: @"USStateAbbreviations" ofType: @"plist"];
             NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

             NSArray *temp = [dict allKeysForObject:foundState];
             NSString *stateKey = [temp lastObject];
             
             if([stateKey length] > 0) {
                 [self.placeName setText:[stateKey capitalizedString]];
                 self.state = [stateKey capitalizedString];
             }
             
             [self.locationView setHidden:NO];
             
         }
     }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedScreen:(id)sender {
    [self.snapCaption resignFirstResponder];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Tap to caption..."]) {
        [textView setText:@""];
    }
}

-(void)sendSnap:(id)sender
{
    
    if([self.snapCaption.text isEqualToString:@"Tap to caption..."]) {
        [self.snapCaption setText:@""];
    }

    UIImageWriteToSavedPhotosAlbum(self.snap, nil, nil, nil);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.dashViewController.imageToUpload = snap;
    appDelegate.dashViewController.keyToUpload = key;
    appDelegate.dashViewController.handleToUpload = handle;
    appDelegate.dashViewController.captionToUpload = self.snapCaption.text;
    
    if([handle.name isEqualToString:@"the wire"]) {
        appDelegate.dashViewController.locationToUpload = self.placeName.text;
    }
    
    [appDelegate.dashViewController setDoGetThreadsOnView:YES];
    [appDelegate.dashViewController setDoUploadOnView:YES];
    [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)trashMessage:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"trashed" message:@"Your message has been trashed." delegate:appDelegate.dashViewController cancelButtonTitle:@"ok" otherButtonTitles:nil];
        
    [appDelegate.dashViewController.navigationController popToRootViewControllerAnimated:YES];
    
    [alert show];
}

- (IBAction)addCaption:(id)sender {
//    [self.snapCaption setHidden:NO];
//    [self.snapCaption becomeFirstResponder];
    
}

- (IBAction)changePlaceName:(id)sender
{
    
}
@end
