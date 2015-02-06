//
//  DefaultNoobPanelController.h
//
//  Created by Jim Young on 3/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PanelViewController.h"
#import "Group.h"
#import <CoreLocation/CoreLocation.h>

@interface DefaultNoobPanelController : PanelViewController

// Info for registration.
@property (nonatomic, strong) NSURL* videoFileURL;
@property (nonatomic, strong) UIImage* videoOverlay;
@property (nonatomic, strong) UIImage* videoScreenshot;

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* password;

@property (nonatomic, strong) NSDate* birthdate;
@property (nonatomic, strong) NSString* gender;

@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) NSString* locationName;

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSString* phoneVerification;

@property (nonatomic, strong) id forceNewUserFunnel;

- (void)reset;

@end
