//
//  CloseSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/14/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "CloseSettingsCell.h"
#import "App.h"
#import "AlertView.h"

@interface CloseSettingsCell()
@end

@implementation CloseSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [[PNButton alloc] initWithFrame:CGRectMake(0,0,280,40)];
        [self.button setTitle:@"Done" forState:UIControlStateNormal];
        [self.button setBorderWithColor:COLOR(darkGrayColor) width:1.0];
        self.button.buttonColor = [UIColor clearColor];
        self.button.titleLabel.font = FONT(14);
        [self.button setTitleColor:COLOR(darkGrayColor) forState:UIControlStateNormal];

        [self addChild:self.button];

        self.paddingY = 20;
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    self.button.frame = CGRectSetTopRight(self.bounds.size.width-20, 0, self.button.frame);
    [super layoutSubviews];
}

@end
