//
//  DualBulgeFilter.m
//
//
//  Created by Jim Young on 3/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MultiBulgeFilter.h"

@implementation MultiBulgeFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageBulgeDistortionFilter* bulge1 = [[GPUImageBulgeDistortionFilter alloc] init];
        GPUImageBulgeDistortionFilter* bulge2 = [[GPUImageBulgeDistortionFilter alloc] init];
        GPUImageBulgeDistortionFilter* bulge3 = [[GPUImageBulgeDistortionFilter alloc] init];

        bulge1.center = CGPointMake(0.3, 0.4);
        bulge2.center = CGPointMake(0.7, 0.4);

        bulge3.radius = 0.5;

        NSArray* philters = @[
                              bulge1,
                              bulge2,
                              bulge3
                              ];
        [self setFilters:philters];
    }
    return self;
}
@end

