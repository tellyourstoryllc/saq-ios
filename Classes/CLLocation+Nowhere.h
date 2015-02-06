//
//  CLLocation+Nowhere.h
//  NoMe
//
//  Created by Jim Young on 12/25/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocation(Nowhere)

+ (CLLocation*)nowhere;
- (BOOL)isNowhere;

@end
