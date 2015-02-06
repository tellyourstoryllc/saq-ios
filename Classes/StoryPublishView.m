//
//  StoryPublishView.m
//  NoMe
//
//  Created by Jim Young on 11/30/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryPublishView.h"

@interface StoryPublishView() {
    NSTimer* _animationTimer;
    int _animationCounter;
}
@end

@implementation StoryPublishView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.privateButton = [ArrowButton new];
    self.privateButton.arrowColor = COLOR(privateColor);
    [self.privateButton setImage:[UIImage tintedImageNamed:@"lock" color:[COLOR(whiteColor) colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
    [self addChild:self.privateButton];

    self.friendsButton = [ArrowButton new];
    self.friendsButton.arrowColor = COLOR(friendColor);
    [self.friendsButton setImage:[UIImage tintedImageNamed:@"friends" color:[COLOR(blackColor) colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
    [self addChild:self.friendsButton];

    self.publicButton = [ArrowButton new];
    self.publicButton.arrowColor = COLOR(publicColor);
    [self.publicButton setImage:[UIImage tintedImageNamed:@"globe" color:[COLOR(blackColor) colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
    [self addChild:self.publicButton];

    self.buttonSpacing = 20;
    self.buttonWidth = 60;
    self.buttonHeight = 60;

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect buttonRect = CGRectMake(0, 0, self.buttonWidth, self.buttonHeight);
    self.publicButton.frame = buttonRect;
    self.friendsButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.publicButton.frame)+self.buttonSpacing, 0, buttonRect);
    self.privateButton.frame =  CGRectSetOrigin(CGRectGetMaxX(self.friendsButton.frame)+self.buttonSpacing, 0, buttonRect);

    NSArray* buttons = @[self.privateButton, self.friendsButton, self.publicButton];
    for (ArrowButton* button in buttons) {
        button.rightArrowWidth = self.buttonWidth/5;
        button.leftArrowWidth = -self.buttonWidth/5;
    }
}

- (void)startAnimating {
    if (_animationTimer)
        return;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cycleAnimation) userInfo:nil repeats:YES];
}

- (void)stopAnimating {
    [_animationTimer invalidate];
    _animationTimer = nil;
}

- (void)cycleAnimation {
    int steps = 10;
    _animationCounter = (_animationCounter + 1) % steps;

    float solid = 1.0;
    float fade = 0.8;

    self.privateButton.alpha = fade;
    self.friendsButton.alpha = fade;
    self.publicButton.alpha = fade;

    switch (_animationCounter) {
        case 0:
            self.publicButton.alpha = solid;
            break;

        case 1:
            self.friendsButton.alpha = solid;
            break;

        case 2:
            self.privateButton.alpha = solid;
            break;

        default:
            break;
    }
}

@end