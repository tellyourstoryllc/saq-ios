//
//  StoryManager.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryManager : NSObject

@property (nonatomic) int unreadCount;
@property (nonatomic) int totalCount;
@property (nonatomic, strong) NSMutableArray* unreadStories;
@property (nonatomic, assign) BOOL isLoading;

+ (StoryManager*)manager;

- (void)updateUnreadCount;
- (void)loadPublicFeedWithParams:(NSDictionary*)params
                   andCompletion:(void (^)(NSSet* stories))completion;
- (void)loadFriendFeedWithParams:(NSDictionary*)params
                   andCompletion:(void (^)(NSSet* stories))completion;
- (void)fillExtensionConduit;

@end
