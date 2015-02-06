//
//  MessagePublishView.m
//  NoMe
//
//  Created by Jim Young on 12/29/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MessagePublishView.h"

@interface MessagePublishView() {
    NSTimer* _animationTimer;
    int _animationCounter;
}
@end

@implementation MessagePublishView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.sendButton = [ArrowButton new];
    self.sendButton.arrowColor = COLOR(privateColor);
    [self.sendButton setImage:[UIImage tintedImageNamed:@"lock" color:[COLOR(whiteColor) colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
    [self addChild:self.sendButton];

    self.buttonWidth = 60;
    self.buttonHeight = 60;

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect buttonRect = CGRectMake(0, 0, self.buttonWidth, self.buttonHeight);
    self.sendButton.frame = buttonRect;
    self.sendButton.rightArrowWidth = self.buttonWidth/5;
    self.sendButton.leftArrowWidth = -self.buttonWidth/5;
}

@end