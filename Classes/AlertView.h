//
//  AlertView.h
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PNAlertView.h"

typedef enum {
    AlertViewAlignMiddle,
    AlertViewAlignHigh,
    AlertViewAlignLow,
} AlertViewAlignment;

@interface AlertView : PNAlertView

@property AlertViewAlignment verticalAlignment;

- (void) showAfterPresent:(void (^)())afterPresent
           withCompletion:(void (^)(NSInteger buttonIndex))completion;

@end
