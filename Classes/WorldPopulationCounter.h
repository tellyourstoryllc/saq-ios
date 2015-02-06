//
//  WorldPopulationCounter.h
//  NoMe
//
//  Created by Jim Young on 11/12/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorldPopulationCounter : NSObject

@property (nonatomic, assign) double population;

+ (instancetype) shared;

@end
