//
//  TopBubble.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CalloutBubble.h"

@interface CalloutBubble()
@property (nonatomic,strong) UIImage* bubbleImage;
@end

@implementation CalloutBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel = [[PNLabel alloc] init];
        [self addChild:self.textLabel];

        [self addObserver:self forKeyPath:@"calloutPosition" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"calloutOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"bubbleColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    switch (self.calloutPosition) {
        case CalloutBubblePositionNone:
            self.textLabel.frame = CGRectMakeCorners(4,10,b.size.width-4, b.size.height-4);
            break;
            
        case CalloutBubblePositionTop:
            self.textLabel.frame = CGRectMakeCorners(4,10,b.size.width-4, b.size.height-10);
            break;

        case CalloutBubblePositionBottom:
            self.textLabel.frame = CGRectMakeCorners(4,4,b.size.width-4, b.size.height-10);
            break;

        case CalloutBubblePositionLeft:
            self.textLabel.frame = CGRectMakeCorners(10,4,b.size.width-10, b.size.height-4);
            break;

        case CalloutBubblePositionRight:
            self.textLabel.frame = CGRectMakeCorners(4,10,b.size.width-10, b.size.height-4);
            break;

    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.superview)
        [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {

    if (CGRectIsEmpty(rect)) return;
    if (!self.bubbleColor) return;

    if (!self.bubbleImage) {
        if (self.calloutPosition == CalloutBubblePositionNone) {
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, rect.size}
                                        cornerRadius:4.0] addClip];
            CGContextSetFillColorWithColor(context, [self.bubbleColor CGColor]);
            UIRectFill(rect);
            self.bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }
        else if (self.calloutPosition == CalloutBubblePositionBottom) {
            UIImage* leftMask = [[UIImage imageNamed:@"bottom-bubble-left-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 28, 8)];
            UIImage* rightMask = [[UIImage imageNamed:@"bottom-bubble-right-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 8, 28, 4)];

            UIGraphicsBeginImageContextWithOptions(rect.size, NO, leftMask.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [self.bubbleColor CGColor]);
            UIRectFill(rect);

            CGRect leftRect = CGRectMake(0, 0, self.calloutOffset, rect.size.height);
            CGRect rightRect = CGRectMake(self.calloutOffset, 0, rect.size.width-self.calloutOffset, rect.size.height);

            [leftMask drawInRect:leftRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            [rightMask drawInRect:rightRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            self.bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }
        else if (self.calloutPosition == CalloutBubblePositionTop) {
            UIImage* leftMask = [[UIImage imageNamed:@"top-bubble-left-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 4, 4, 8)];
            UIImage* rightMask = [[UIImage imageNamed:@"top-bubble-right-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 8, 4, 4)];

            UIGraphicsBeginImageContextWithOptions(rect.size, NO, leftMask.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [self.bubbleColor CGColor]);
            UIRectFill(rect);

            CGRect leftRect = CGRectMake(0, 0, self.calloutOffset, rect.size.height);
            CGRect rightRect = CGRectMake(self.calloutOffset, 0, rect.size.width-self.calloutOffset, rect.size.height);

            [leftMask drawInRect:leftRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            [rightMask drawInRect:rightRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            self.bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if (self.calloutPosition == CalloutBubblePositionLeft) {
            UIImage* topMask = [[UIImage imageNamed:@"left-bubble-top-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 28, 8, 4)];
            UIImage* bottomMask = [[UIImage imageNamed:@"left-bubble-bottom-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 28, 4, 4)];

            UIGraphicsBeginImageContextWithOptions(rect.size, NO, topMask.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [self.bubbleColor CGColor]);
            UIRectFill(rect);

            CGRect topRect = CGRectMake(0, 0, rect.size.width, self.calloutOffset);
            CGRect bottomRect = CGRectMake(0, self.calloutOffset, rect.size.width, rect.size.height-self.calloutOffset);

            [topMask drawInRect:topRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            [bottomMask drawInRect:bottomRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            self.bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if (self.calloutPosition == CalloutBubblePositionRight) {
            UIImage* topMask = [[UIImage imageNamed:@"right-bubble-top-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 8, 28)];
            UIImage* bottomMask = [[UIImage imageNamed:@"right-bubble-bottom-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 4, 4, 28)];

            UIGraphicsBeginImageContextWithOptions(rect.size, NO, topMask.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [self.bubbleColor CGColor]);
            UIRectFill(rect);

            CGRect topRect = CGRectMake(0, 0, rect.size.width, self.calloutOffset);
            CGRect bottomRect = CGRectMake(0, self.calloutOffset, rect.size.width, rect.size.height-self.calloutOffset);
            
            [topMask drawInRect:topRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            [bottomMask drawInRect:bottomRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
            self.bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    [self.bubbleImage drawInRect:rect];
    [super drawRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sz = [self.textLabel sizeThatFits:size];
    if (self.calloutPosition == CalloutBubblePositionBottom || self.calloutPosition == CalloutBubblePositionTop)
        return CGSizeMake(sz.width+30, sz.height+40);
    else
        return CGSizeMake(sz.width+40, sz.height+30);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self)
        self.bubbleImage = nil;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"calloutPosition"];
    [self removeObserver:self forKeyPath:@"calloutOffset"];
    [self removeObserver:self forKeyPath:@"bubbleColor"];
    [self removeObserver:self forKeyPath:@"frame"];
}

@end
