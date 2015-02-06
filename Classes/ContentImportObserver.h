//
//  ContentImportObserver.h
//  NoMe
//
//  Created by Jim Young on 12/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentImportObserver : NSObject

+ (instancetype)shared;

- (void)performObservation;

@end
