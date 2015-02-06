//
//  LocationManager.m
//  NoMe
//
//  Created by Jim Young on 11/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LocationManager.h"
#import "PNUIAlertView.h"

NSString * const kLocationManagerErrorDomain = @"LocationManagerError";

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *coreLocationManager;
@property (nonatomic, assign) BOOL skipAlert;
@property (nonatomic, strong) NSMutableArray* callbacks;

@end

@implementation LocationManager

+ (LocationManager*) manager {
    static LocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LocationManager alloc] init];
    });
    return sharedManager;
}

+ (double)metersToMiles:(double)distance {
    return (distance * kLocationManagerMeterToMile);
}

+ (double)currentUserDistanceFromLocation:(CLLocation *)location {
    NSParameterAssert(location);
    CLLocation *currentLocation = self.manager.currentLocation;
    return currentLocation ? [currentLocation distanceFromLocation:location] : -1;
}

+ (NSString *)friendlyStringForDistance:(double)distance {
    double miles = distance * kLocationManagerMeterToMile;
    if (miles > 0) {
        if (miles > 20) {
            return @"20+ mi away";
        } else if (miles <= 1) {
            return @"<1 mi away";
        } else {
            return [NSString stringWithFormat:@"%i mi away", (int)miles];
        }
    } else {
        return nil;
    }
}

+ (NSString *)friendlyStringForLocationDistance:(CLLocation *)location {
    double distance = [self currentUserDistanceFromLocation:location];
    return [self friendlyStringForDistance:distance];
}

- (id)init {
    self = [super init];
    if (self) {
        self.coreLocationManager = [[CLLocationManager alloc] init];
        self.coreLocationManager.delegate = self;
    }
    return self;
}

- (void)requestWithCompletion:(LocationManagerCallback)completion {
    [self requestUsingPrescreen:YES withCompletion:completion];
}

- (void)requestUsingPrescreen:(BOOL)showPrescreen
                   withCompletion:(LocationManagerCallback)completion {

    if (!self.callbacks)
        self.callbacks = [NSMutableArray new];

    if (completion) {
        [self.callbacks addObject:[completion copy]];
    }
    else {
        LocationManagerCallback dummyBlock = ^(CLLocation* location, NSError* error) { return; };
        [self.callbacks addObject:[dummyBlock copy]];
    };

    NSError *error = [self errorForAuthorizationStatus:[CLLocationManager authorizationStatus]];

    if (error) {
        [self performCallbacksWithLocation:nil andError:error];
        return;
    }
    else if (self.callbacks.count > 1)
        return;

    void (^doRequest)() = ^() {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [self.coreLocationManager requestWhenInUseAuthorization];
        }
        else {
            [self.coreLocationManager startUpdatingLocation];
        }
    };

    void (^preRequest)() = ^() {

        if ([CLLocationManager locationServicesEnabled]) {
            NSString* permissionRequestTitle = @"Allow Location";
            NSString* permissionRequestMessage = [NSString stringWithFormat:@"To find and meet people near you, please Allow access to your location. Your exact location is NEVER revealed."];

            PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:permissionRequestTitle
                                                                message:permissionRequestMessage
                                                         andButtonArray:@[@"Skip", @"Allow"]];

            [alert showWithCompletion:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    doRequest();
                }
                else {
                    NSError* error = [NSError errorWithDomain:kLocationManagerErrorDomain code:kCLAuthorizationStatusNotDetermined userInfo:nil];
                    [self performCallbacksWithLocation:nil andError:error];
                }
            }];
        }
        else {
            [PNAlertView showWithTitle:@"Location Unavailable"
                            andMessage:@"Location services are disabled on this device. Please enable them in settings and try again."];
        }
    };

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorized:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.coreLocationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if (showPrescreen)
                preRequest();
            else
                doRequest();

            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            break;
        default:
            break;
    }

}

- (void)performCallbacksWithLocation:(CLLocation*)location andError:(NSError*)error {

    NSArray* callbacks = self.callbacks;
    self.callbacks = nil;

    for (LocationManagerCallback callback in callbacks) {
        callback(location, error);
    }
}

- (BOOL)canGetLocation {
    return [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if (status == kCLAuthorizationStatusDenied)
        [Logger log:@"location.denied"];

    NSError *error = [self errorForAuthorizationStatus:status];
    if (error)
        [self performCallbacksWithLocation:self.currentLocation andError:error];
    else
        [self.coreLocationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = (CLLocation*)[locations lastObject];
    [self.coreLocationManager stopUpdatingLocation];
    [self performCallbacksWithLocation:self.currentLocation andError:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.coreLocationManager stopUpdatingLocation];
    [self performCallbacksWithLocation:nil andError:error];
}

//--

- (NSError *)errorForAuthorizationStatus:(CLAuthorizationStatus)status {
    NSError *error = nil;
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusNotDetermined:
            break;

        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:kLocationManagerErrorDomain code:status userInfo:nil];
            break;
        default:
            break;
    }
    return error;
}

@end
