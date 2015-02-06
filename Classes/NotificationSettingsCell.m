//
//  EmailPrefsSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "NotificationSettingsCell.h"
#import "User.h"
#import "Api.h"
#import "IosPreference.h"
#import "UserPreference.h"

@interface NotificationSettingsCell()

@property (nonatomic, strong) PNLabel* emailOneToOneLabel;
@property (nonatomic, strong) PNLabel* pushOneToOneLabel;

@property (nonatomic, strong) UISwitch* emailOneToOneSwitch;
@property (nonatomic, strong) UISwitch* pushOneToOneSwitch;

@end

@implementation NotificationSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {


        self.emailOneToOneSwitch = [[UISwitch alloc] init];
        [self.emailOneToOneSwitch addTarget:self action:@selector(emailOneToOneSwitched) forControlEvents:UIControlEventValueChanged];
        [self addChild:self.emailOneToOneSwitch];

        self.emailOneToOneLabel = [PNLabel labelWithText:@"Email notifications" andFont:FONT(14)];
        [self addChild:self.emailOneToOneLabel];

        self.pushOneToOneSwitch = [[UISwitch alloc] init];
        [self.pushOneToOneSwitch addTarget:self action:@selector(pushOneToOneSwitched) forControlEvents:UIControlEventValueChanged];
        [self addChild:self.pushOneToOneSwitch];

        self.pushOneToOneLabel = [PNLabel labelWithText:@"Push notifications" andFont:FONT(14)];
        [self addChild:self.pushOneToOneLabel];
        
        self.bounds = CGRectMake(0,0,0,120);
    }
    return self;
}

- (void) layoutSubviews {

    IosPreference *ios_pref = [IosPreference any];
    UserPreference *user_pref = [UserPreference any];
    
    if (user_pref) {
        self.emailOneToOneSwitch.on = [user_pref server_one_to_one_emailValue];
    }

    if(ios_pref) {
        self.pushOneToOneSwitch.on = [ios_pref server_one_to_oneValue];
    }

    CGRect b = self.bounds;
    CGFloat vSpacing = 25;
    CGFloat curY = 10;

    self.emailOneToOneSwitch.frame = CGRectSetOrigin(20, curY, self.emailOneToOneSwitch.frame);
    [self.emailOneToOneLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.emailOneToOneSwitch.frame)-50];
    self.emailOneToOneLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.emailOneToOneSwitch.frame)+10, CGRectGetMidY(self.emailOneToOneSwitch.frame), self.emailOneToOneLabel.frame);

    curY = CGRectGetMaxY(self.emailOneToOneSwitch.frame) + vSpacing;

    self.pushOneToOneSwitch.frame = CGRectSetOrigin(20, curY, self.pushOneToOneSwitch.frame);
    [self.pushOneToOneLabel sizeToFitTextWidth:b.size.width-CGRectGetWidth(self.pushOneToOneSwitch.frame)-50];
    self.pushOneToOneLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.pushOneToOneSwitch.frame)+10, CGRectGetMidY(self.pushOneToOneSwitch.frame), self.pushOneToOneLabel.frame);


    [super layoutSubviews];
}

- (void)emailOneToOneSwitched {
    NSString* value = self.emailOneToOneSwitch.on ? @"true" : @"false";
    [[Api sharedApi] postPath:@"/preferences/update"
                   parameters:@{@"server_one_to_one_email":value, @"server_mention_email":value}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                     }];
}

- (void)pushOneToOneSwitched {
    NSString* value = self.pushOneToOneSwitch.on ? @"true" : @"false";
    [[Api sharedApi] postPath:@"/ios_device_preferences/update"
                   parameters:@{@"server_one_to_one":value, @"server_mention":value}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                     }];
}

@end
