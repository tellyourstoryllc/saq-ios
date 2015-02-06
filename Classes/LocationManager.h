//
//  LocationManager.h
//  NoMe
//
//  Created by Jim Young on 11/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+Nowhere.h"

#define kLocationManagerMeterToMile 0.000621371

typedef void(^LocationManagerCallback)(CLLocation* location, NSError* error);
extern NSString * const kLocationManagerErrorDomain;

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;

+ (LocationManager*) manager;

+ (double)metersToMiles:(double)distance;
// Returns -1 if we do not know where we are located.
+ (double)currentUserDistanceFromLocation:(CLLocation *)location;
+ (NSString *)friendlyStringForLocationDistance:(CLLocation *)location;
+ (NSString *)friendlyStringForDistance:(double)distance;

- (void)requestWithCompletion:(LocationManagerCallback)completion;
- (void)requestUsingPrescreen:(BOOL)showPrescreen
               withCompletion:(LocationManagerCallback)completion;

@end
