//
//  ConfirmSnapViewController.h
//  authie
//
//  Created by Seth Hayward on 1/13/14.
//  Copyright (c) 2014 bitwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GAITrackedViewController.h>
#import <CoreLocation/CoreLocation.h>
@class RODHandle;

@interface ConfirmSnapViewController : GAITrackedViewController <UITextViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *cog;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (weak, nonatomic) IBOutlet UITextView *snapCaption;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) UIImage *snap;
@property (strong, nonatomic) RODHandle *handle;
- (IBAction)addCaption:(id)sender;
- (IBAction)changePlaceName:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSString *state;


@end
