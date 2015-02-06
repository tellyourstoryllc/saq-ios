//
//  Logger.m
//  peanut
//
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.

#import "Logger.h"
#import "PNSupport.h"
#import "Flurry.h"

#define kLogEventsFlushThreshold 50

@implementation Logger

- (void)didLogEvents:(NSDictionary *)eventDict {
    [Flurry logEvent:eventDict[@"event"] withParameters:eventDict[@"parameters"]];
    NSLog(@"%@", eventDict[@"event"]);
}

- (void)flush {}

@end