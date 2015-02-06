//
//  UnreadMessageObserver.h
//  groups
//
//  Created by Cragin Godley on 12/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupManager : NSObject

@property (nonatomic) int unreadCount;
@property (nonatomic) int totalCount;
@property (nonatomic,strong) NSMutableArray* unreadGroups;
@property (nonatomic,readonly) NSArray* groups;
@property (nonatomic, assign) BOOL isLoading;

+ (GroupManager*) manager;

- (void) updateUnreadCount;
- (void) refreshGroupsWithCompletion:(void (^)(NSSet* groups))completion;
- (void) fillExtensionConduit;

@end
