//
//  GraphicsSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/22/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "GraphicsSettingsCell.h"
#import "User.h"
#import "Api.h"
#import "PNUserPreferences.h"

@interface GraphicsSettingsCell()

@property (nonatomic, strong) PNLabel* sectionLabel;

@property (nonatomic, strong) PNLabel* showWallpaperLabel;
@property (nonatomic, strong) PNLabel* showAnimatedVideoLabel;

@property (nonatomic, strong) UISwitch* showWallpaperSwitch;
@property (nonatomic, strong) UISwitch* showAnimatedVideoSwitch;

@end

@implementation GraphicsSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

//        self.sectionLabel = [PNLabel labelWithText:@"Display preferences" andFont:FONT(14)];
//        [self addChild:self.sectionLabel];

//        self.showWallpaperSwitch = [[UISwitch alloc] init];
//        [self.showWallpaperSwitch addTarget:self action:@selector(showWallpaperSwitched) forControlEvents:UIControlEventValueChanged];
//        [self addChild:self.showWallpaperSwitch];
//
//        self.showWallpaperLabel = [PNLabel labelWithText:@"show wallpapers" andFont:FONT(14)];
//        [self addChild:self.showWallpaperLabel];

        self.showAnimatedVideoSwitch = [[UISwitch alloc] init];
        [self.showAnimatedVideoSwitch addTarget:self action:@selector(showAnimatedVideoSwitched) forControlEvents:UIControlEventValueChanged];
        [self addChild:self.showAnimatedVideoSwitch];

        self.ShowAnimatedVideoLabel = [PNLabel labelWithText:@"Animate video previews" andFont:FONT(14)];
        [self addChild:self.showAnimatedVideoLabel];

        self.bounds = CGRectMake(0,0,0,60);
    }
    return self;
}

- (void) layoutSubviews {

    PNUserPreferences* userPrefs = [PNUserPreferences shared];
    self.showWallpaperSwitch.on = [userPrefs boolPreference:kShowWallpaperPrefKey orDefault:YES];
    self.showAnimatedVideoSwitch.on = [userPrefs boolPreference:kShowAnimatedVideoPrefKey orDefault:YES];

    CGRect b = self.bounds;
    CGFloat vSpacing = 25;
    CGFloat curY = 0;
//    self.sectionLabel.frame = CGRectSetOrigin(20, 0, self.sectionLabel.frame);
//
//    curY = CGRectGetMaxY(self.sectionLabel.frame) + vSpacing;

//    self.showWallpaperSwitch.frame = CGRectSetOrigin(20, curY, self.showWallpaperSwitch.frame);
//    [self.showWallpaperLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.showWallpaperSwitch.frame)-50];
//    self.showWallpaperLabel.frame = CGRectSetOrigin(CGRectGetMaxX(self.showWallpaperSwitch.frame)+10, curY-5, self.showWallpaperLabel.frame);
//
//    curY = CGRectGetMaxY(self.showWallpaperLabel.frame) + vSpacing;

    self.showAnimatedVideoSwitch.frame = CGRectSetOrigin(20, curY, self.showAnimatedVideoSwitch.frame);
    [self.showAnimatedVideoLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.showAnimatedVideoSwitch.frame)-50];
    self.showAnimatedVideoLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.showAnimatedVideoSwitch.frame)+10, CGRectGetMidY(self.showAnimatedVideoSwitch.frame), self.showAnimatedVideoLabel.frame);

    [super layoutSubviews];
}

- (void)showWallpaperSwitched {
    [[PNUserPreferences shared] setPreference:kShowWallpaperPrefKey boolValue:self.showWallpaperSwitch.on];
}

- (void)showAnimatedVideoSwitched {
    [[PNUserPreferences shared] setPreference:kShowAnimatedVideoPrefKey boolValue:self.showAnimatedVideoSwitch.on];
}

@end
