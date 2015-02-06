//
//  StoryPublishView.h
//  NoMe
//
//  Created by Jim Young on 11/30/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrowButton.h"
#import "PNView.h"

@interface StoryPublishView : PNView

@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat buttonSpacing;

@property (nonatomic, strong) ArrowButton* privateButton;
@property (nonatomic, strong) ArrowButton* friendsButton;
@property (nonatomic, strong) ArrowButton* publicButton;

@property (nonatomic, strong) PNButton* messageButton;

- (void)startAnimating;
- (void)stopAnimating;

@end
