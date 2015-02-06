//
//  BandwidthSettingsCell.m
//
//
//  Created by Jim Young on 3/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "BandwidthSettingsCell.h"
#import "User.h"
#import "PNUserPreferences.h"

@interface BandwidthSettingsCell()

@property (nonatomic, strong) PNLabel* saveBandwidthLabel;
@property (nonatomic, strong) UISwitch* saveBandwidthSwitch;

@end

@implementation BandwidthSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.saveBandwidthSwitch = [[UISwitch alloc] init];
        [self.saveBandwidthSwitch addTarget:self action:@selector(saveBandwidthSwitched) forControlEvents:UIControlEventValueChanged];
        [self addChild:self.saveBandwidthSwitch];

        self.saveBandwidthLabel = [PNLabel labelWithText:@"Conserve bandwidth" andFont:FONT(14)];
        [self addChild:self.saveBandwidthLabel];

        self.bounds = CGRectMake(0,0,0,60);
    }
    return self;
}

- (void) layoutSubviews {

    PNUserPreferences* userPrefs = [PNUserPreferences shared];
    self.saveBandwidthSwitch.on = [userPrefs boolPreference:kSaveBandwidthPrefKey orDefault:NO];

    CGRect b = self.bounds;
    CGFloat curY = 0;

    self.saveBandwidthSwitch.frame = CGRectSetOrigin(20, curY, self.saveBandwidthSwitch.frame);
    [self.saveBandwidthLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.saveBandwidthSwitch.frame)-50];
    self.saveBandwidthLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.saveBandwidthSwitch.frame)+10, CGRectGetMidY(self.saveBandwidthSwitch.frame), self.saveBandwidthLabel.frame);

    [super layoutSubviews];
}

- (void)saveBandwidthSwitched {
    [[PNUserPreferences shared] setPreference:kSaveBandwidthPrefKey boolValue:self.saveBandwidthSwitch.on];
}

@end
