//
//  LikeOverlayView.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/17/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LikeOverlayView.h"
#import "AFNetworkReachabilityManager.h"
#import "PNUserPreferences.h"
#import "UIImage+Utility.h"
#import "User.h"
#import "App.h"

@interface LikeOverlayView()
@property (nonatomic, strong) PNInsetLabel* label;
@end

@implementation LikeOverlayView

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    self.userInteractionEnabled = NO;

    NSNumber* alpha = [Configuration settingFor:@"like_overlay_alpha"] ?: @(0.8f);

    self.label = [[PNInsetLabel alloc] initWithFrame:CGRectZero];
    self.label.textColor = COLOR(whiteColor);
    self.label.layer.shadowOffset = CGSizeMake(0,1);
    self.label.layer.shadowColor = [COLOR(blackColor) CGColor];
    self.label.layer.shadowRadius = 1.0;
    self.label.layer.shadowOpacity = 1.0;
    self.label.layer.anchorPoint = CGPointMake(0, 0);
    self.label.alpha = alpha.floatValue;
    self.label.backgroundColor = [COLOR(blackColor) colorWithAlphaComponent:0.2];
    self.label.insets = UIEdgeInsetsMake(8,20,8,20);
    [self addSubview:self.label];

    return self;
}

- (void)setMessage:(SkyMessage *)message {
    NSString* unregisteredFormatString = [Configuration stringFor:@"like_overlay_text_unregistered"] ?: @"%@ ❤️ this on %@ for iOS.\nGet it from the App Store.";
    NSString* registeredFormatString = [Configuration stringFor:@"like_overlay_text_registered"] ?: @"%@ ❤️ this.";

    if (message.user.registeredValue)
        self.label.text = [NSString stringWithFormat:registeredFormatString, [App username], kAppTitle];
    else
        self.label.text = [NSString stringWithFormat:unregisteredFormatString, [App username], kAppTitle];
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    self.label.font = HEADFONT(b.size.height*0.06);  // <-- specify font size as % of image.
    self.label.frame = CGRectMakeCorners(0, b.size.height*0.66, b.size.width, b.size.height);
}

@end
