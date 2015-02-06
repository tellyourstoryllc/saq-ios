//
//  TinderTextView.m
//  SnapCracklePop
//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TextCardView.h"
#import "CalloutBubble.h"

@interface TextCardView()

@property (nonatomic, strong) CalloutBubble* bubble;
@property (nonatomic, strong) PNLabel* label;

@end

@implementation TextCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR(blackColor);

        self.bubble = [[CalloutBubble alloc] initWithFrame:CGRectZero];
        self.bubble.calloutOffset = 20;
        [self addSubview:self.bubble];

        self.label = [[PNLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label];

        [self hideControls];
    }
    return self;
}

- (void)setMessage:(SkyMessage *)message {
    [super setMessage:message];
    if (message.text) {
        if (message.user.isMe)
            [self setText:message.text withCalloutPosition:CalloutBubblePositionRight bubbleColor:COLOR(orangeColor) textColor:COLOR(blackColor)];
        else
            [self setText:message.text withCalloutPosition:CalloutBubblePositionLeft bubbleColor:COLOR(blueColor) textColor:COLOR(whiteColor)];
    }
    else {
        self.label.text = nil;
        self.label.frame = CGRectZero;
    }
}

- (void)setText:(NSString*)text
withCalloutPosition:(CalloutBubblePosition)position
    bubbleColor:(UIColor*)bubbleColor
      textColor:(UIColor*)textColor {

    self.label.text = text;

    CGFloat minimumFontSize = 12.f;
    CGFloat bigFontSize = MAX(minimumFontSize, self.bounds.size.height / 5);
    CGFloat smallFontSize = MAX(minimumFontSize, self.bounds.size.height / 10);

    self.label.font = self.label.text.length < 100 ? FONT_B(bigFontSize) : FONT_B(smallFontSize);

    CGFloat maxWidth = self.bounds.size.width-20;
    [self.label sizeToFit];

    // If too wide to fit on one line..
    if (self.label.bounds.size.width > maxWidth)
        [self.label sizeToFitTextWidth:maxWidth];

    // If too tall...
    if (CGRectGetMaxY(self.label.frame) > self.bounds.size.height) {
        self.label.frame = CGRectInset(self.bounds, 12, 8);
        self.bubble.frame = CGRectInset(self.bounds, 4, 4);
    }
    else {
        if (position == CalloutBubblePositionRight)
            self.label.frame = CGRectSetMiddleRight(self.bounds.size.width-10, self.bounds.size.height/2, self.label.frame);
        else if (position == CalloutBubblePositionLeft)
            self.label.frame = CGRectSetMiddleLeft(10, self.bounds.size.height/2, self.label.frame);

        self.bubble.frame = CGRectInset(self.label.frame, -10, -8);
    }

    self.bubble.bubbleColor = bubbleColor;
    self.label.textColor = textColor;
    self.bubble.calloutPosition = position;

    if (position == CalloutBubblePositionRight)
        self.label.frame = CGRectOffset(self.label.frame, -5, 0);
    else if (position == CalloutBubblePositionLeft)
        self.label.frame = CGRectOffset(self.label.frame, 5, 0);
}

@end
