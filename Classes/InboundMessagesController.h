//
//  InboundMessagesController.h
//  NoMe
//
//  Created by Jim Young on 12/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkyMessage.h"
#import "BaseSnapCollectionViewController.h"

@protocol InboundMessagesDelegate <NSObject>

- (void)inboundMessagesDidOpenGroup:(Group*)group;
- (void)inboundMessagesDidClearGroup:(Group*)group;

@end

@interface InboundMessagesController : BaseSnapCollectionViewController

@property (nonatomic, readonly) NSInteger numberOfResults;
@property (nonatomic, assign) id<InboundMessagesDelegate> delegate;

@end
