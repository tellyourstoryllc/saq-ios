//
//  PasteBoardObserver.h
//  NoMe
//
//  Created by Jim Young on 12/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasteBoardManager : NSObject

+ (instancetype)manager;

- (void)importWithCompletion:(void (^)(UIImage* image, NSDictionary* metadata))completion;

@end