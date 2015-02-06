//
//  FriendRequestController.h
//  NoMe
//
//  Created by Jim Young on 12/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSnapCollectionViewController.h"

@protocol FriendRequestDelegate <NSObject>

- (void)friendRequestShouldApprove:(User*)user;
- (void)friendRequestShouldIgnore:(User*)user;
- (void)friendRequestShouldView:(User*)user;

@end

@interface FriendRequestController : BaseSnapCollectionViewController

@property (nonatomic, readonly) NSInteger numberOfResults;
@property (nonatomic, assign) id<FriendRequestDelegate> delegate;

@end
