//
//  SnapCache.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/25/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCache.h"
#import "PNSupport.h"
#import "SDImageCache.h"

@interface SnapCache()
@property (nonatomic, strong) SDImageCache* sd_imageCache;
@end

@implementation SnapCache

+ (instancetype)shared {
    static SnapCache* instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* directory = [[PNSupport documentPath] stringByAppendingPathComponent:@"snapcache"];
        instance = [[[self class] alloc] initWithCacheDirectory:directory];
        NSTimeInterval oneYear = 365 * 24 * 60 * 60;
        instance.defaultTimeoutInterval = oneYear;
        instance.sd_imageCache = [SDImageCache sharedImageCache];
    });

    return instance;
}


// Stick a SDImageCache in front to cache in memory
- (UIImage*)imageFromDataForKey:(NSString *)key {
    UIImage* img = [self.sd_imageCache imageFromMemoryCacheForKey:key];
    if (!img) {
        NSString* filename = [[self urlForKey:key] path];
        img = [UIImage imageWithContentsOfFile:filename];
        [self.sd_imageCache storeImage:img forKey:key toDisk:NO];
    }
    return img;
}

@end
