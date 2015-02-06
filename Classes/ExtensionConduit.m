//
//  SharedCache.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ExtensionConduit.h"
#import "NSArray+Map.h"

@interface ExtensionConduitItem()
@property (nonatomic, assign) ExtensionConduit* conduit;
@property (nonatomic, strong) NSDictionary* properties;
@end

@implementation ExtensionConduit

+ (instancetype)shared {
    static ExtensionConduit* instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSURL* baseFileUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kAppGroupId];
        NSString* directory = [baseFileUrl.path stringByAppendingPathComponent:@"wigitcondooit"];
        NSLog(@"conduit directory: %@", directory);
        instance = [[[self class] alloc] initWithCacheDirectory:directory];
        NSTimeInterval oneWeek = 7 * 24 * 60 * 60;
        instance.defaultTimeoutInterval = oneWeek;
    });

    return instance;
}

- (UIImage*)imageFromDataForKey:(NSString *)key {
    NSString* filename = [[self urlForKey:key] path];
    return [UIImage imageWithContentsOfFile:filename];
}

- (NSArray*)allStories {
    NSMutableArray* props = [NSMutableArray new];
    for (NSString* key in self.allKeysSorted) {
        if ([key hasPrefix:@"story"] && [key hasSuffix:@"properties"]) {
            id plist = [self plistForKey:key];
            if (plist)
                [props addObject:plist];
            else {
                NSLog(@"missing plist for story %@", key);
                [self removeCacheForKey:key];
            }
        }
    }

    return [props mapUsingBlock:^id(NSDictionary* plist) {
        ExtensionConduitItem* item = [ExtensionConduitItem new];
        item.conduit = self;
        item.properties = plist;
        return item;
    }];
}

- (NSArray*)allSnaps {
    NSMutableArray* props = [NSMutableArray new];
    for (NSString* key in self.allKeysSorted) {
        if ([key hasPrefix:@"snap"] && [key hasSuffix:@"properties"]) {
            id plist = [self plistForKey:key];
            if (plist)
                [props addObject:plist];
            else {
                NSLog(@"missing plist for snap %@", key);
                [self removeCacheForKey:key];
            }
        }
    }

    return [props mapUsingBlock:^id(NSDictionary* plist) {
        ExtensionConduitItem* item = [ExtensionConduitItem new];
        item.conduit = self;
        item.properties = plist;
        return item;
    }];
}

- (void)addStoryWithImage:(UIImage*)image properties:(NSDictionary*)props
{
    NSString* baseId = [self newStoryItemKey];

    NSString* dataKey = [baseId stringByAppendingString:@"image"];
    [self setImage:image forKey:dataKey];

    NSMutableDictionary* p = [props mutableCopy];
    p[@"key"] = baseId;
    p[@"type"] = @"image";
    p[@"datakey"] = dataKey;
    [self setPlist:p forKey:[baseId stringByAppendingString:@"properties"]];

}

- (void)addSnapWithImage:(UIImage*)image properties:(NSDictionary*)props
{
    NSString* baseId = [self newSnapItemKey];

    NSString* dataKey = [baseId stringByAppendingString:@"image"];
    [self setImage:image forKey:dataKey];

    NSMutableDictionary* p = [props mutableCopy];
    p[@"key"] = baseId;
    p[@"type"] = @"image";
    p[@"datakey"] = dataKey;
    [self setPlist:p forKey:[baseId stringByAppendingString:@"properties"]];
}

- (void)addStoryWithVideoUrl:(NSURL*)url properties:(NSDictionary*)props
{
    if (!url) return;
    
    NSString* baseId = [self newStoryItemKey];

    NSString* name = url.lastPathComponent ?: @"movie.mp4";
    NSString* dataKey = [baseId stringByAppendingString:name];
    [self copyFilePath:url.path asKey:dataKey];

    NSMutableDictionary* p = [props mutableCopy];
    p[@"key"] = baseId;
    p[@"type"] = @"video";
    p[@"datakey"] = dataKey;
    [self setPlist:p forKey:[baseId stringByAppendingString:@"properties"]];
}

- (void)addSnapWithVideoUrl:(NSURL*)url properties:(NSDictionary*)props
{
    if (!url) return;
    
    NSString* baseId = [self newSnapItemKey];

    NSString* dataKey = [baseId stringByAppendingString:url.lastPathComponent];
    [self copyFilePath:url.path asKey:dataKey];

    NSMutableDictionary* p = [props mutableCopy];
    p[@"key"] = baseId;
    p[@"type"] = @"video";
    p[@"datakey"] = dataKey;
    [self setPlist:p forKey:[baseId stringByAppendingString:@"properties"]];
}

// Probably slow..
- (void)removeItemForKey:(NSString *)key {
    for (NSString* qi in self.allKeys) {
        if ([qi hasPrefix:key] && [qi hasSuffix:@"properties"]) {
            NSDictionary* props = [self plistForKey:qi];
            if (props[@"datakey"])
                [self removeCacheForKey:props[@"datakey"]];
            [self removeCacheForKey:qi];
            return;
        }
    }
}

- (void)removeAllStories
{
    for (NSString* key in self.allKeys) {
        if ([key hasPrefix:@"story_"]) {
            [self removeCacheForKey:key];
        }
    }
}

- (void)removeAllSnaps
{
    for (NSString* key in self.allKeys) {
        if ([key hasPrefix:@"snap_"]) {
            [self removeCacheForKey:key];
        }
    }
}

- (void)pruneSnapsToCount:(int)maxCount {
    NSArray* snaps = self.allSnaps;
    int excess = snaps.count - maxCount;
    if (excess > 0) {
        for (int x=0; x < excess; x++) {
            ExtensionConduitItem* item = snaps[x];
            [self removeItemForKey:item.key];
        }
    }
}

- (void)pruneStoriesToCount:(int)maxCount {
    NSArray* stories = self.allStories;

    int excess = stories.count - maxCount;
    if (excess > 0) {
        for (int x=0; x < excess; x++) {
            ExtensionConduitItem* item = stories[x];
            [self removeItemForKey:item.key];
        }
    }
}

//--

- (NSString*)newSnapItemKey {
    return [NSString stringWithFormat:@"snap_%f_", [[NSDate date] timeIntervalSince1970]];
}

- (NSString*)newStoryItemKey {
    return [NSString stringWithFormat:@"story_%f_", [[NSDate date] timeIntervalSince1970]];
}

- (NSArray*)allKeysSorted {
    NSArray* result = [self.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [key1 compare:key2 options:nil];
    }];
    return result;
}

@end

@implementation ExtensionConduitItem

- (NSString*)key {
    return self.properties[@"key"];
}

- (NSURL*) videoUrl {
    return [self.conduit urlForKey:self.properties[@"datakey"]];
}

- (UIImage*) image {
    return [self.conduit imageForKey:self.properties[@"datakey"]];
}

- (BOOL) isSnap {
    return [self.key hasPrefix:@"snap_"];
}

- (BOOL) isStory {
    return [self.key hasPrefix:@"story_"];
}

- (void) remove {
    [self.conduit removeItemForKey:self.key];
}

@end
