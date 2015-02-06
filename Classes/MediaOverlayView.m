//
//  MediaOverlayView.m
//  FFM
//
//  Created by Jim Young on 4/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MediaOverlayView.h"
#import "AFNetworkReachabilityManager.h"
#import "PNUserPreferences.h"
#import "MediaOverlayView.h"
#import "UIImage+Utility.h"
#import "UserAvatarView.h"
#import "User.h"

@interface MediaOverlayView()

@property (nonatomic, strong) UIImageView* logo;
@property (nonatomic, strong) UserAvatarView* avatar;
@property (nonatomic, strong) PNLabel* label;

@property CGSize overlaySize;

@end

@implementation MediaOverlayView

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    self.userInteractionEnabled = NO;

    UIImage* overlayImage = [UIImage imageNamed:@"media-overlay-logo"];
    NSNumber* alpha = [Configuration settingFor:@"overlay_alpha"] ?: @(0.88f);

    if (overlayImage) {
        self.logo = [[UIImageView alloc] initWithImage:overlayImage];
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        self.logo.alpha = alpha.floatValue;
    }

    self.overlaySize = overlayImage.size;

    self.avatar = [[UserAvatarView alloc] initWithFrame:CGRectZero];
    self.avatar.alpha = alpha.floatValue;

    self.label = [[PNLabel alloc] initWithFrame:CGRectZero];
    self.label.textColor = COLOR(lightGrayColor);
    self.label.layer.shadowOffset = CGSizeMake(0,1);
    self.label.layer.shadowColor = [COLOR(blackColor) CGColor];
    self.label.layer.shadowRadius = 1.0;
    self.label.layer.shadowOpacity = 1.0;
    self.label.layer.anchorPoint = CGPointMake(0, 0);
    self.label.alpha = alpha.floatValue;
    [self addSubview:self.logo];
    [self addSubview:self.avatar];
    [self addSubview:self.label];

    return self;
}

- (void)setInfo:(NSDictionary *)info {

    static dispatch_semaphore_t sema;
    if (!sema) sema = dispatch_semaphore_create(0);

    _info = info;
    NSString* username = info[@"author"];
    if (username) {
        if ([info[@"source"] isEqualToString:@"camera"])
            self.label.text = [NSString stringWithFormat:@"Snapped by %@ in %@ - %@", username, kAppTitle, kWebrootURL];
        else if ([info[@"source"] isEqualToString:@"snapchat"])
            self.label.text = [NSString stringWithFormat:@"By %@. Saved with %@ - %@", username, kAppTitle, kWebrootURL];
        else
            self.label.text = [NSString stringWithFormat:@"Uploaded from library by %@ to %@ - %@", username, kAppTitle, kWebrootURL];

        [User fetchUserNamed:username completion:^(User *user) {
            self.avatar.user = user;
            [self layoutSubviews];
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, 5*NSEC_PER_SEC);
    }
    else {
        [self layoutSubviews];
    }
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    CGSize logoSize = [UIImage sizeOfScalingSize:self.overlaySize toSize:CGSizeMake(b.size.width*0.1, b.size.height*0.1)];
    self.logo.frame = CGRectMake(0,0,logoSize.width,logoSize.height);

    if (self.avatar.user.hasAvatar) {
        self.avatar.hidden = NO;
        self.avatar.frame = CGRectMake(0,0, CGRectGetHeight(self.logo.frame)/2, CGRectGetHeight(self.logo.frame)/2);
    }
    else {
        self.avatar.hidden = YES;
        self.avatar.frame = CGRectZero;
    }

    int randomOffset = arc4random_uniform(6);
    self.avatar.frame = CGRectSetTopRight(b.size.width-4, 4+randomOffset, self.avatar.frame);

    self.label.font = FONT_B(b.size.height*0.025);  // <-- specify font size as % of image.
    [self.label sizeToFit];

    CGAffineTransform xform = CGAffineTransformMakeTranslation(b.size.width, CGRectGetMaxY(self.avatar.frame)+4);
    xform = CGAffineTransformRotate(xform, M_PI_2);
    self.label.transform = xform;
}

@end
