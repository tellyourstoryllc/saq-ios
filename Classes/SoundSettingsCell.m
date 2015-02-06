//
//  SoundSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "SoundSettingsCell.h"
#import "User.h"
#import "Api.h"
#import "PNUserPreferences.h"

@interface SoundSettingsCell()

@property (nonatomic, strong) PNLabel* soundReceiveLabel;
@property (nonatomic, strong) UISwitch* soundReceiveSwitch;

@end

@implementation SoundSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.soundReceiveSwitch = [[UISwitch alloc] init];
        [self.soundReceiveSwitch addTarget:self action:@selector(soundReceiveSwitched) forControlEvents:UIControlEventValueChanged];
        [self addChild:self.soundReceiveSwitch];

        self.soundReceiveLabel = [PNLabel labelWithText:@"New message sounds" andFont:FONT(14)];
        [self addChild:self.soundReceiveLabel];

        self.bounds = CGRectMake(0,0,0,60);
    }
    return self;
}

- (void) layoutSubviews {

    PNUserPreferences* userPrefs = [PNUserPreferences shared];
    self.soundReceiveSwitch.on = [userPrefs boolPreference:kReceiveSoundPrefKey orDefault:YES];

    CGRect b = self.bounds;
    CGFloat curY = 0;

    self.soundReceiveSwitch.frame = CGRectSetOrigin(20, curY, self.soundReceiveSwitch.frame);
    [self.soundReceiveLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.soundReceiveSwitch.frame)-50];
    self.soundReceiveLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.soundReceiveSwitch.frame)+10, CGRectGetMidY(self.soundReceiveSwitch.frame), self.soundReceiveLabel.frame);

    [super layoutSubviews];
}

- (void)soundReceiveSwitched {
    [[PNUserPreferences shared] setPreference:kMentionSoundPrefKey boolValue:self.soundReceiveSwitch.on];
    [[PNUserPreferences shared] setPreference:kOneToOneSoundPrefKey boolValue:self.soundReceiveSwitch.on];
    [[PNUserPreferences shared] setPreference:kReceiveSoundPrefKey boolValue:self.soundReceiveSwitch.on];
}

@end
