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
#import <FBGlowLabel/FBGlowLabel.h>

#import "ColorPickerClasses/RSColorPickerView.h"

@class RSBrightnessSlider;
@class RSOpacitySlider;

@class RODHandle;

@interface ConfirmSnapViewController : GAITrackedViewController <UITextViewDelegate, CLLocationManagerDelegate, RSColorPickerViewDelegate>
{
    BOOL dragging;
}
- (IBAction)btnCaption:(id)sender;
@property (weak, nonatomic) IBOutlet FBGlowLabel *labelCaption;
@property (weak, nonatomic) IBOutlet UIImageView *cog;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *snapView;
@property (weak, nonatomic) IBOutlet UIImageView *fontView;
@property (weak, nonatomic) IBOutlet UIImageView *colorView;

@property (weak, nonatomic) IBOutlet UITextView *snapCaption;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) UIImage *snap;
@property (strong, nonatomic) RODHandle *handle;

- (IBAction)changePlaceName:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *font;
@property (strong, nonatomic) NSString *textColor;

@property (nonatomic) UIColor *selectedColor;
- (IBAction)brightnessSlider:(id)sender;

@property (nonatomic) RSColorPickerView *colorPicker;
//@property (nonatomic) RSBrightnessSlider *brightnessSlider;
//@property (nonatomic) RSOpacitySlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;


@end
