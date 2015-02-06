//
//  MessageCamera.m
//  NoMe
//
//  Created by Jim Young on 12/29/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MessageCamera.h"
#import "ArrowButton.h"

@interface MessageCamera()

@property (nonatomic, strong) ArrowButton* sendButton;

@end

@implementation MessageCamera

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.sendButton = [[ArrowButton alloc] initWithFrame:CGRectMake(0,0,100,60)];
    self.sendButton.arrowColor = COLOR(purpleColor);
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:COLOR(whiteColor) forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = HEADFONT(20);
    self.sendButton.rightArrowWidth = 15;
    self.sendButton.leftArrowWidth = -15;
    [self.sendButton addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];

    [self.composeView addSubview:self.sendButton];

    [self.publishButton removeFromSuperview];

    [self.cancelButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    self.showCancelButton = YES;

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.sendButton.frame = CGRectSetBottomCenter(self.bounds.size.width/2, self.bounds.size.height-4, self.sendButton.frame);
}

- (void)onSend {
    [self publishTapped];
}

@end
