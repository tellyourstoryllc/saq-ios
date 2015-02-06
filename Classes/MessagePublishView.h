//
//  MessagePublishView.h
//  NoMe
//
//  Created by Jim Young on 12/29/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNView.h"
#import "ArrowButton.h"

@interface MessagePublishView : PNView

@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat buttonHeight;

@property (nonatomic, strong) ArrowButton* sendButton;

@end