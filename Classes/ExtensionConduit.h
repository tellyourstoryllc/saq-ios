//
//  SnapCracklePop
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
//  Use the filesystem to pass data between main app and extensions

#import "EGOCache.h"

typedef NS_ENUM(NSInteger, ExtensionConduitDataType) {
    ExtensionConduitDataTypePropertyList,
    ExtensionConduitDataTypeImage,
    ExtensionConduitDataTypeVideo
};

@interface ExtensionConduitItem : NSObject

@property (nonatomic, readonly) NSString* key;
@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSURL* videoUrl;
@property (nonatomic, readonly) UIImage* image;

@property (nonatomic, readonly) BOOL isSnap;
@property (nonatomic, readonly) BOOL isStory;

- (void)remove;

@end

@interface ExtensionConduit : EGOCache

+ (instancetype)shared;

// These are ordered from oldest to newest.
- (NSArray*)allStories;
- (NSArray*)allSnaps;

- (void)addStoryWithImage:(UIImage*)image properties:(NSDictionary*)props;
- (void)addSnapWithImage:(UIImage*)image properties:(NSDictionary*)props;

- (void)addStoryWithVideoUrl:(NSURL*)url properties:(NSDictionary*)props;
- (void)addSnapWithVideoUrl:(NSURL*)url properties:(NSDictionary*)props;

- (void)removeItemForKey:(NSString *)itemId;
- (void)removeAllStories;
- (void)removeAllSnaps;

- (void)pruneSnapsToCount:(int)maxCount;
- (void)pruneStoriesToCount:(int)maxCount;

@end
