//
//  FastMediaLoader.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
//
//  Modeled after SDWebImageDownloader

#import "FastMediaLoader.h"
#import "SDWebImageManager.h"
#import "Api.h"

typedef void(^MediaLoaderVideoCompletionBlock)(NSURL* videoUrl);

@interface FastMediaLoader()
@property (nonatomic, strong) NSMutableDictionary* urlRequests; // urlString -> operation
@property (nonatomic, strong) NSMutableDictionary* urlRequestCounts; // urlString -> # of requests waiting for operation
@property (strong, nonatomic) NSMutableDictionary *urlCallbacks; // urlString -> array of callback blocks

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (strong, nonatomic) dispatch_queue_t barrierQueue;

@property (weak, nonatomic) NSOperation* lastAddedOperation;

@end

@implementation FastMediaLoader

+ (FastMediaLoader*)shared {

    static FastMediaLoader *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FastMediaLoader new];

        // Configure the cache
        SDImageCache* cache = [SDImageCache sharedImageCache];
        cache.shouldDecompressImages = NO;
        cache.maxCacheSize = 10000000;
        cache.maxCacheAge = 86400;
    });

    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadQueue = [NSOperationQueue new];
        self.urlRequests = [NSMutableDictionary dictionaryWithCapacity:8];
        self.urlRequestCounts = [NSMutableDictionary dictionaryWithCapacity:8];
        self.urlCallbacks = [NSMutableDictionary dictionaryWithCapacity:8];
        self.barrierQueue = dispatch_queue_create("com.perceptualnet.FastMediaLoader_barrier", DISPATCH_QUEUE_CONCURRENT);
        self.maxConcurrentDownloads = 2;

        // Add observer to see if entered background.
    }
    return self;
}

// Just rely on SDWebImage to handle images.
- (void)loadImageForUrlString:(NSString*)urlString
               withCompletion:(void (^)(UIImage* image))completion {

    if (!urlString) {
        if (completion)
            completion(nil);
        return;
    }

    [self incrementCountForRequest:urlString];
    on_default(^{
        id operation = [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:urlString]
                                                                       options:SDWebImageRetryFailed
                                                                      progress:nil
                                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                         [self.urlRequests removeObjectForKey:urlString];
                                                                         [self resetCountForRequest:urlString];

                                                                         if (completion) completion(image);
                                                                     }];

        if ([operation isKindOfClass:[NSOperation class]])
            [self.urlRequests setObject:operation forKey:urlString];
    });
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (NSString*)_cacheKeyForVideo:(NSURL*)url {
    return [NSString stringWithFormat:@"%@%@.mp4", [url.absoluteString md5], url.absoluteString.lastPathComponent];
}

- (void)setSuspended:(BOOL)suspended {
    [self.downloadQueue setSuspended:suspended];
}

- (void)loadVideoForUrlString:(NSString*)urlString
               withCompletion:(void (^)(NSURL* videoUrl))completion {

    if (!urlString) {
        if (completion)
            completion(nil);
        return;
    }

    NSURL* url = [NSURL URLWithString:urlString];
    NSString* cacheKey = [self _cacheKeyForVideo:url];
    EGOCache* cache = [EGOCache globalCache];

    if ([cache hasCacheForKey:cacheKey]) {
        if (completion)
            completion([cache urlForKey:cacheKey]);
    }
    else {

        [self incrementCountForRequest:urlString];

        __weak FastMediaLoader* weakSelf = self;

        [self addVideoCompletion:completion
                    forUrlString:urlString
                  onFirstRequest:^{

                      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                      request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData; // We are caching in EGOCache, so disable NSURLCache
                      [request addValue:@"video/*" forHTTPHeaderField:@"Accept"];
                      [request setTimeoutInterval:133.7];

                      AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                      [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

                          FastMediaLoader *strongSelf = weakSelf;
                          if (!strongSelf) return;  // huh?

                          [cache setData:operation.responseData forKey:cacheKey withTimeoutInterval:86400 completion:nil];

                          NSString *tempDirectory = NSTemporaryDirectory();
                          NSString *tempPath = [tempDirectory stringByAppendingFormat:@"/temp.%@", url.pathExtension];
                          BOOL success = [operation.responseData writeToFile:tempPath atomically:YES];

                          [strongSelf.urlRequests removeObjectForKey:urlString];
                          [strongSelf resetCountForRequest:urlString];

                          NSArray *callbacksForURL = [strongSelf callbacksForUrlString:urlString];
                          [strongSelf removeCallbacksForUrlString:urlString];

                          for (MediaLoaderVideoCompletionBlock kumpletion in callbacksForURL) {
                              if (success) {
                                  kumpletion([NSURL fileURLWithPath:tempPath]);
                              }
                              else {
                                  kumpletion(nil);
                              }
                          }

                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                          FastMediaLoader *strongSelf = weakSelf;
                          if (!strongSelf) return;  // huh?
                          [strongSelf.urlRequests removeObjectForKey:urlString];
                          [strongSelf resetCountForRequest:urlString];

                          NSArray *callbacksForURL = [strongSelf callbacksForUrlString:urlString];
                          [strongSelf removeCallbacksForUrlString:urlString];

                          for (MediaLoaderVideoCompletionBlock kumpletion in callbacksForURL) {
                              kumpletion(nil);
                          }
                      }];

                      AFHTTPResponseSerializer* serializer = [AFHTTPResponseSerializer serializer];
                      serializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mpeg", @"video/mp4", nil];
                      op.responseSerializer = serializer;

                      [[weakSelf downloadQueue] addOperation:op];
                      [weakSelf.urlRequests setObject:op forKey:urlString];

                      if (weakSelf.lifo) {
                          [weakSelf.lastAddedOperation addDependency:op];
                          weakSelf.lastAddedOperation = op;
                      }
                  }
         ];
    }
}

- (void)addVideoCompletion:(void (^)(NSURL* videoUrl))videoCompletion
              forUrlString:(NSString*)urlString
            onFirstRequest:(void (^)())onFirst {

    if (!urlString) {
        if (videoCompletion)
            videoCompletion(nil);
        return;
    }

    dispatch_barrier_async(self.barrierQueue, ^{
        BOOL first = NO;
        if (!self.urlCallbacks[urlString]) {
            self.urlCallbacks[urlString] = [NSMutableArray new];
            first = YES;
        }

        // Handle single download of simultaneous download request for the same URL
        NSMutableArray *callbacksForURL = self.urlCallbacks[urlString];
        if (videoCompletion)
            [callbacksForURL addObject:[videoCompletion copy]];

        // Is this line necessary??
        self.urlCallbacks[urlString] = callbacksForURL;

        if (first)
            onFirst();
    });
}

- (NSArray *)callbacksForUrlString:(NSString *)urlString {
    __block NSArray *callbacksForURL;
    dispatch_sync(self.barrierQueue, ^{
        callbacksForURL = self.urlCallbacks[urlString];
    });
    return [callbacksForURL copy];
}

- (void)removeCallbacksForUrlString:(NSString *)urlString {
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.urlCallbacks removeObjectForKey:urlString];
    });
}

- (void)cancelRequestForUrlString:(NSString*)urlString {
    if (!urlString) return;

    NSOperation* op = (NSOperation*)[self.urlRequests objectForKey:urlString];
    if (!op) {
        // no operation. nothing to cancel.
    }
    else {
        NSInteger count = [self countForRequest:urlString];
        if (count > 1) {
            NSLog(@"Cannot cancel %@ ", urlString);
            [self decrementCountForRequest:urlString];
        }
        else {
            [op cancel];
            [self.urlRequests removeObjectForKey:urlString];
            [self.urlRequestCounts removeObjectForKey:urlString];
            NSLog(@"Cancelled media request for: %@", urlString);
        }
    }
}

- (NSInteger)countForRequest:(NSString*)urlString {
    NSNumber* currentCount = [self.urlRequestCounts objectForKey:urlString];
    return currentCount.integerValue;
}

- (NSInteger)incrementCountForRequest:(NSString*)urlString {

    NSInteger newCount = [self countForRequest:urlString] + 1;
    if (newCount)
        [self.urlRequestCounts setObject:[NSNumber numberWithInteger:newCount] forKey:urlString];
    else
        [self.urlRequestCounts removeObjectForKey:urlString];

    return newCount;
}

- (NSInteger)decrementCountForRequest:(NSString*)urlString {
    NSInteger newCount = [self countForRequest:urlString] - 1;
    if (newCount)
        [self.urlRequestCounts setObject:[NSNumber numberWithInteger:newCount] forKey:urlString];
    else
        [self.urlRequestCounts removeObjectForKey:urlString];

    return newCount;
}

- (void)resetCountForRequest:(NSString*)urlString {
    [self.urlRequestCounts removeObjectForKey:urlString];
}

- (NSUInteger) urlCount {
    return self.urlRequests.count;
}

- (NSUInteger) requestCount {
    __block int total = 0;
    [self.urlRequestCounts enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber* count, BOOL *stop) {
        total += count.intValue;
    }];
    return total;
}

@end
