//
//  PillLabel.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PillLabel.h"

@interface PillLabel()

@end

@implementation PillLabel

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.rightCap = YES;
    }
    return self;
}

- (void) drawRect:(CGRect)rect {

    UIRectCorner corners = 0;
    if (self.leftCap)
        corners |= UIRectCornerTopLeft | UIRectCornerBottomLeft;

    if (self.rightCap)
        corners |= UIRectCornerTopRight|UIRectCornerBottomRight;

    if (self.topCap)
        corners |= UIRectCornerTopRight|UIRectCornerTopLeft;

    if (self.bottomCap)
        corners |= UIRectCornerBottomLeft|UIRectCornerBottomRight;

    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect
                                                      byRoundingCorners:corners
                                                            cornerRadii:CGSizeMake(rect.size.height/2,rect.size.height/2)];
    [self.pillColor setFill];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal alpha:1.0];

    [super drawTextInRect:CGRectMake(self.insets.left,
                                     self.insets.top,
                                     rect.size.width-self.insets.left-self.insets.right,
                                     rect.size.height-self.insets.top-self.insets.bottom)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize originalSize = [super sizeThatFits:size];
    return CGSizeMake(originalSize.width+self.insets.left+self.insets.right, originalSize.height+self.insets.top+self.insets.bottom);
}

- (CGSize)sizeThatFitsTextWidth:(CGFloat)width {
    CGSize originalSize = [super sizeThatFitsTextWidth:width];
    return CGSizeMake(originalSize.width+self.insets.left+self.insets.right, originalSize.height+self.insets.top+self.insets.bottom);
}

@end
