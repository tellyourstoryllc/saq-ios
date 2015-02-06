//
//  ArrowBox.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/12/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ArrowBox.h"

@implementation ArrowBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (self.arrowColor) {
        UIBezierPath *path = [UIBezierPath bezierPath];

        if (self.leftArrowWidth >= 0)
            [path moveToPoint:CGPointMake(self.leftArrowWidth,0)];
        else
            [path moveToPoint:CGPointMake(0,0)];

        if (self.rightArrowWidth >= 0) {
            [path addLineToPoint:CGPointMake(rect.size.width-self.rightArrowWidth, 0)];
            [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height/2)];
            [path addLineToPoint:CGPointMake(rect.size.width-self.rightArrowWidth, rect.size.height)];
        }
        else {
            [path addLineToPoint:CGPointMake(rect.size.width, 0)];
            [path addLineToPoint:CGPointMake(rect.size.width+self.rightArrowWidth, rect.size.height/2)];
            [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
        }

        if (self.leftArrowWidth >= 0) {
            [path addLineToPoint:CGPointMake(self.leftArrowWidth, rect.size.height)];
            [path addLineToPoint:CGPointMake(0, rect.size.height/2)];
        }
        else {
            [path addLineToPoint:CGPointMake(0, rect.size.height)];
            [path addLineToPoint:CGPointMake(-self.leftArrowWidth, rect.size.height/2)];
        }

        [path closePath];
        [self.arrowColor setFill];
        [path fillWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}

- (void)setArrowColor:(UIColor *)arrowColor {
    _arrowColor = arrowColor;
    [self setNeedsDisplay];
}

@end
