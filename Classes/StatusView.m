//
//  StatusView.m
//  groups
//
//  Created by Jim Young on 11/30/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR(purpleColor);

        self.titleLabel.textColor = COLOR(whiteColor);
        self.titleLabel.font = [UIFont fontWithName:@"Lato-Black" size:21];

        self.messageLabel.textColor = COLOR(whiteColor);
        self.messageLabel.font = FONT(18);

        self.layer.cornerRadius = 5;

        self.verticalPadding = 10;
        self.horizontalPadding = 8;
    }
    return self;
}

- (CGSize) sizeThatFits:(CGSize)size {
    CGSize sz = [super sizeThatFits:size];
    return sz;
}

@end
