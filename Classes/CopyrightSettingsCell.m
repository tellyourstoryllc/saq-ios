//
//  CopyrightSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/11/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "CopyrightSettingsCell.h"

@implementation CopyrightSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        PNLabel* label = [PNLabel labelWithText:@" © Copyright 2014 Perceptual Networks, Inc. Portions of this product include software licensed under various open source licenses, and are available on the Legal Info page linked above." andFont:FONT(11)];
        label.textColor = COLOR(grayColor);
        [label sizeToFitTextWidth:300];
        [self addChild:label];
        self.paddingY = 20;
        self.centerX = YES;
        [self sizeToFit];
    }
    return self;
}

@end
