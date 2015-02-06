//
//  FastMediaLoader.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FastMediaLoader : NSObject

@property (nonatomic, assign, readonly) NSUInteger urlCount;
@property (nonatomic, assign, readonly) NSUInteger requestCount; // <-- number of unique REQUESTS (separate callbacks) to be serviced.
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;
@property (nonatomic, readonly) NSUInteger currentDownloadCount; // <-- number of unique items to be downloaded. (NOT THE SAME as request count)

@property (nonatomic, assign) BOOL lifo;

+ (FastMediaLoader*)shared;

- (void)loadImageForUrlString:(NSString*)urlString
               withCompletion:(void (^)(UIImage* image))completion ;

- (void)loadVideoForUrlString:(NSString*)urlString
               withCompletion:(void (^)(NSURL* videoUrl))completion ;

- (void)cancelRequestForUrlString:(NSString*)urlString;

@end