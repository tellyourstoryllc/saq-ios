//
//  CLLocation+Nowhere.m
//  NoMe
//
//  Created by Jim Young on 12/25/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CLLocation+Nowhere.h"

@implementation CLLocation(Nowhere)

+ (CLLocation*)nowhere;
{
    static CLLocation* _nowhere;
    if (!_nowhere) {
        _nowhere = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    }
    return _nowhere;
}

- (BOOL)isNowhere {
    return [self distanceFromLocation:[CLLocation nowhere]] == 0.0;
}

@end
