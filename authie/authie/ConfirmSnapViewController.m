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
@synthesize snap, key, handle, state, selectedColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        self.font = @"LucidaTypewriter";
        self.textColor = @"#FFFFFF";
        self.selectedColor = NO;
        
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

    [self.locationView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLocationView:)];
    [self.locationView addGestureRecognizer:tapView];
    
    
    [self.fontView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapFont = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFontView:)];
    [self.fontView addGestureRecognizer:tapFont];

    [self.colorView setUserInteractionEnabled:YES];

    UITapGestureRecognizer *tapColor = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedColorView:)];
    [self.colorView addGestureRecognizer:tapColor];

}

- (void)tappedColorView:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"Tapped color view.");
	
    
    // View that displays color picker (needs to be square)
    _colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(20.0, 10.0, 280.0, 280.0)];
    
    // Optionally set and force the picker to only draw a circle
    //    [_colorPicker setCropToCircle:YES]; // Defaults to NO (you can set BG color)
    
    // Set the selection color - useful to present when the user had picked a color previously
    //[_colorPicker setSelectionColor:[self randomColorOpaque:YES]];
    
    //    [_colorPicker setSelectionColor:[UIColor colorWithRed:1 green:0 blue:0.752941 alpha:1.000000]];
    //    [_colorPicker setSelection:CGPointMake(269, 269)];
    
    // Set the delegate to receive events
    [_colorPicker setDelegate:self];

    self.selectedColor = NO;

    [self.view addSubview:_colorPicker];
    
}

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    
    // Get color data
    UIColor *color = [cp selectionColor];
    
    CGFloat r, g, b, a;
    [[cp selectionColor] getRed:&r green:&g blue:&b alpha:&a];
    
    // Update important UI
    //_colorPatch.backgroundColor = color;
    //_brightnessSlider.value = [cp brightness];
    //_opacitySlider.value = [cp opacity];
    
    
    // Debug
    NSString *colorDesc = [NSString stringWithFormat:@"rgba: %f, %f, %f, %f", r, g, b, a];
    NSLog(@"%@", colorDesc);
    int ir = r * 255;
    int ig = g * 255;
    int ib = b * 255;
    int ia = a * 255;
    colorDesc = [NSString stringWithFormat:@"rgba: %d, %d, %d, %d", ir, ig, ib, ia];
    NSLog(@"%@", colorDesc);
    //_rgbLabel.text = colorDesc;

    
    if(self.selectedColor == YES) {
        [_colorPicker removeFromSuperview];        
    }
    
    self.selectedColor = YES;

    
    NSLog(@"%@", NSStringFromCGPoint(cp.selection));
    
    color = nil;
}


- (void)tappedFontView:(UITapGestureRecognizer *)tapGesture
{
    
    NSLog(@"TappedFontView.");

    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    KxMenuItem *lucida = [KxMenuItem menuItem:@"Lucida Typewriter"
                                      image:[UIImage alloc]
                                     target:self
                                     action:@selector(fontMenuItemAction:)];
    
    KxMenuItem *futura = [KxMenuItem menuItem:@"Futura-Medium"
                                          image:[UIImage alloc]
                                         target:self
                                         action:@selector(fontMenuItemAction:)];
    
    [items insertObject:lucida atIndex:0];
    [items insertObject:futura atIndex:1];
    
    
    [KxMenu showMenuInView:self.view
                  fromRect:self.fontView.frame
                 menuItems:items];
    
}

- (void)fontMenuItemAction:(KxMenuItem *)item
{

    if([item.title isEqualToString:@"Lucida Typewriter"]) {
        UIFont *lucidaTypewriter = [UIFont fontWithName:@"LucidaTypewriter" size:20.0f];
        [self.snapCaption setFont:lucidaTypewriter];
        self.font = @"LucidaTypewriter";
    }
    
    if([item.title isEqualToString:@"Futura-Medium"]) {
        UIFont *lucidaTypewriter = [UIFont fontWithName:@"Futura-Medium" size:20.0f];
        [self.snapCaption setFont:lucidaTypewriter];
        self.font = @"Futura-Medium";
    }
    
}


- (void)tappedLocationView:(UITapGestureRecognizer *)tapGesture
{
    
    NSLog(@"Tapped location view.");
    
    NSMutableArray *items = [[NSMutableArray alloc] init];

    
    KxMenuItem *none = [KxMenuItem menuItem:@"None"
                                     image:[UIImage alloc]
                                    target:self
                                    action:@selector(menuItemAction:)];

    KxMenuItem *cityItem = [KxMenuItem menuItem:self.city
                                      image:[UIImage alloc]
                                     target:self
                                     action:@selector(menuItemAction:)];
    
    KxMenuItem *stateItem = [KxMenuItem menuItem:self.state
                                      image:[UIImage alloc]
                                     target:self
                                     action:@selector(menuItemAction:)];
    
    [items insertObject:none atIndex:0];
    
    if(self.city.length > 0) {
        [items insertObject:cityItem atIndex:1];
    }
    
    if(self.state.length > 0) {
        [items insertObject:stateItem atIndex:2];
    }
    
    [KxMenu showMenuInView:self.view
                  fromRect:self.locationView.frame
                 menuItems:items];

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
             
             self.city = p.subAdministrativeArea;
             
//             NSLog(@"subAdministrativeArea: %@", p.subAdministrativeArea);
//             NSLog(@"subLocalitly: %@", p.subLocality);
//             NSLog(@"thoroughfare: %@", p.thoroughfare);
//             NSLog(@"areas of interest: %@", p.areasOfInterest);
             
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
- (IBAction)btnCaption:(id)sender {
}

@end
