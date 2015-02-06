//
//  Logger.h
//  groups
//
//  Created by Jim Young on 12/9/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PNLogger.h"

#define PNLOG(eventString) [Logger log:eventString]
#define PCLOG(eventString) [Logger log:[NSString stringWithFormat:@"%@-%@", eventString, [self class]]]

@interface Logger : PNLogger

@end
