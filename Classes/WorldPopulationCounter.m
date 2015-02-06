//
//  WorldPopulationCounter.m
//  NoMe
//
//  Created by Jim Young on 11/12/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "WorldPopulationCounter.h"

@interface WorldPopulationCounter() {
    NSTimer* _timer;
    NSDate* _t0;
    double _population0;
}

@end

@implementation WorldPopulationCounter

+ (instancetype) shared {
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePopulation) userInfo:nil repeats:YES];
    [_timer fire];

    _population0 = 7000000000.f;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _t0 = [dateFormatter dateFromString:@"2011-10-31"];

    [self updatePopulation];
    return self;
}

- (void)updatePopulation {
    float growthRate = 0.0116;
    double pop = _population0 * exp2(growthRate*[_t0 timeIntervalSinceNow]/(-60*60*24*365));
    self.population = pop;
}

@end
