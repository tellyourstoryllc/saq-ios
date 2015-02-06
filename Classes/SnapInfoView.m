//
//  SnapInfoController.m
//  NoMe
//
//  Created by Jim Young on 1/19/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "SnapInfoView.h"
#import "App.h"
#import "Api.h"

@interface SnapInfoView ()

@property (nonatomic, strong) UIImageView* sourceIcon;
@property (nonatomic, strong) PNLabel* sourceLabel;

@property (nonatomic, strong) UIImageView* timeIcon;
@property (nonatomic, strong) PNLabel* timeLabel;

@property (nonatomic, strong) UIImageView* permissionIcon;
@property (nonatomic, strong) PNLabel* permissionLabel;

@property (nonatomic, strong) PNButton* publicButton;
@property (nonatomic, strong) PNButton* friendsButton;
@property (nonatomic, strong) PNButton* privateButton;
@property (nonatomic, strong) PNButton* deleteButton;
@property (nonatomic, strong) PNButton* flagButton;

@end

@implementation SnapInfoView

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    self.backgroundColor = [COLOR(whiteColor) colorWithAlphaComponent:0.88];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;

    self.layer.borderColor = [COLOR(whiteColor) CGColor];
    self.layer.borderWidth = 2.f;

    self.sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    self.sourceIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.sourceLabel = [PNLabel labelWithText:@"unknown" andFont:FONT_B(16)];

    self.timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    self.timeIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.timeLabel = [PNLabel labelWithText:@"unknown" andFont:FONT(16)];

    self.permissionIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    self.permissionIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.permissionLabel = [PNLabel labelWithText:@"unknown" andFont:FONT(16)];

    CGFloat unselectedDesaturation = 66;

    self.publicButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.publicButton.buttonColor = COLOR(publicColor);
    self.publicButton.selectedColor = COLOR(publicColor);
    self.publicButton.unselectedColor = [COLOR(publicColor) desaturate:unselectedDesaturation];

    self.friendsButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.friendsButton.buttonColor = COLOR(friendColor);
    self.friendsButton.selectedColor = COLOR(friendColor);
    self.friendsButton.unselectedColor = [COLOR(friendColor) desaturate:unselectedDesaturation];

    self.privateButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.privateButton.buttonColor = COLOR(privateColor);
    self.privateButton.selectedColor = COLOR(privateColor);
    self.privateButton.unselectedColor = [COLOR(privateColor) desaturate:unselectedDesaturation];

    [self.publicButton setImage:[UIImage tintedImageNamed:@"globe" color:COLOR(blackColor)] forState:UIControlStateSelected];
    [self.friendsButton setImage:[UIImage tintedImageNamed:@"friends" color:COLOR(blackColor)] forState:UIControlStateSelected];
    [self.privateButton setImage:[UIImage tintedImageNamed:@"lock" color:COLOR(blackColor)] forState:UIControlStateSelected];

    [self.publicButton setImage:[UIImage tintedImageNamed:@"globe" color:[COLOR(publicColor) darken:10]] forState:UIControlStateNormal];
    [self.friendsButton setImage:[UIImage tintedImageNamed:@"friends" color:[COLOR(friendColor) darken:10]] forState:UIControlStateNormal];
    [self.privateButton setImage:[UIImage tintedImageNamed:@"lock" color:[COLOR(privateColor) darken:10]] forState:UIControlStateNormal];


    self.deleteButton = [[PNButton alloc] initWithFrame:CGRectZero];
    [self.deleteButton setImage:[UIImage tintedImageNamed:@"trash" color:[COLOR(redColor) desaturate:25]] forState:UIControlStateNormal];
    self.deleteButton.buttonColor = COLOR(redColor);


    self.flagButton = [[PNButton alloc] initWithFrame:CGRectZero];
    [self.flagButton setTitle:@"Report Inappropriate" forState:UIControlStateNormal];
    self.flagButton.buttonColor = COLOR(grayColor);

    [self addSubview:self.sourceIcon];
    [self addSubview:self.sourceLabel];
    [self addSubview:self.timeIcon];
    [self addSubview:self.timeLabel];
    [self addSubview:self.permissionIcon];
    [self addSubview:self.permissionLabel];

    [self addSubview:self.publicButton];
    [self addSubview:self.friendsButton];
    [self addSubview:self.privateButton];

    [self addSubview:self.deleteButton];
    [self addSubview:self.flagButton];

    [self.publicButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPublic)]];
    [self.privateButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPrivate)]];
    [self.friendsButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriends)]];

    [self.deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDelete)]];
    [self.flagButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFlag)]];

    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismiss)]];

    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    self.sourceIcon.frame = CGRectSetOrigin(10, 10, self.sourceIcon.frame);
    self.sourceLabel.frame = CGRectMakeCorners(CGRectGetMaxX(self.sourceIcon.frame)+10, CGRectGetMinY(self.sourceIcon.frame), b.size.width, CGRectGetMaxY(self.sourceIcon.frame));

    self.timeIcon.frame = CGRectSetOrigin(10, CGRectGetMaxY(self.sourceIcon.frame)+10, self.timeIcon.frame);
    self.timeLabel.frame = CGRectMakeCorners(CGRectGetMaxX(self.timeIcon.frame)+10, CGRectGetMinY(self.timeIcon.frame), b.size.width, CGRectGetMaxY(self.timeIcon.frame));

    self.permissionIcon.frame = CGRectSetOrigin(10, CGRectGetMaxY(self.timeIcon.frame)+10, self.permissionIcon.frame);
    self.permissionLabel.frame = CGRectMakeCorners(CGRectGetMaxX(self.permissionIcon.frame)+10, CGRectGetMinY(self.permissionIcon.frame), b.size.width, CGRectGetMaxY(self.permissionIcon.frame));

    CGFloat y = CGRectGetMaxY(self.permissionIcon.frame) + 20;
    CGFloat buttonSpacing = 10;
    CGFloat buttonHeight = 40;

    CGFloat buttonWidth = (b.size.width - 5*buttonSpacing) / 4;
    self.publicButton.frame = CGRectMake(buttonSpacing, y, buttonWidth, buttonHeight);
    self.friendsButton.frame = CGRectMake(CGRectGetMaxX(self.publicButton.frame)+buttonSpacing, y, buttonWidth, buttonHeight);
    self.privateButton.frame = CGRectMake(CGRectGetMaxX(self.friendsButton.frame)+buttonSpacing, y, buttonWidth, buttonHeight);
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.privateButton.frame)+buttonSpacing, y, buttonWidth, buttonHeight);
    self.flagButton.frame = CGRectMakeCorners(buttonSpacing, y, b.size.width-buttonSpacing, y+buttonHeight);

    self.flagButton.cornerRadius = buttonHeight/4;

    if (_permission && self.snap.user.isMe) {
        self.publicButton.hidden = NO;
        self.friendsButton.hidden = NO;
        self.privateButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.flagButton.hidden = YES;
    }
    else {
        self.publicButton.hidden = YES;
        self.friendsButton.hidden = YES;
        self.privateButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.flagButton.hidden = NO;
    }
}

- (void)setSnap:(SkyMessage *)snap {
    if (_snap == snap) return;

    [self.KVOController unobserve:_snap];
    _snap = snap;

    [self configureForSnap];

    [self.KVOController observe:_snap keyPath:@"updated_at" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {

                              [self configureForSnap];
                          }];
}

- (void)configureForSnap {
    if (_snap.user.isMe && [_snap isKindOfClass:[Story class]]) {
        Story* story = (Story*)_snap;
        _permission = story.permission;
    }

    if ([_snap.source isEqualToString:@"camera"]) {
        self.sourceLabel.text = @"Captured by KnowMe camera";
        self.sourceIcon.image = [UIImage tintedImageNamed:@"knowme-bw2" color:COLOR(blackColor)];
        self.timeLabel.text = [NSString stringWithFormat:@"Taken %@ ago", self.snap.created_at.timeAgoInWords];
    }
    else if ([_snap.source isEqualToString:@"library"]) {
        self.sourceLabel.text = @"Imported from photo library";
        self.sourceIcon.image = [UIImage tintedImageNamed:@"album" color:COLOR(blackColor)];
        self.timeLabel.text = [NSString stringWithFormat:@"Uploaded %@ ago", self.snap.created_at.timeAgoInWords];
    }
    else {
        self.sourceLabel.text = @"Unknown origin";
        self.sourceIcon.image = nil;
        self.timeLabel.text = [NSString stringWithFormat:@"Posted %@ ago", self.snap.created_at.timeAgoInWords];
    }

    self.timeIcon.image = [UIImage tintedImageNamed:@"timer" color:COLOR(blackColor)];

    self.publicButton.selected = NO;
    self.friendsButton.selected = NO;
    self.privateButton.selected = NO;

    if ([_permission isEqualToString:@"public"]) {
        self.publicButton.selected = YES;
        self.permissionLabel.text = @"Can be seen by anyone";
        self.permissionIcon.image = [UIImage tintedImageNamed:@"globe" color:COLOR(blackColor)];
    }
    else if ([_permission isEqualToString:@"friends"]) {
        self.friendsButton.selected = YES;
        self.permissionLabel.text = @"Seen only by friends";
//        self.permissionIcon.image = [UIImage imageNamed:@"friends"];
        self.permissionIcon.image = [UIImage tintedImageNamed:@"friends" color:COLOR(blackColor)];
    }
    else if ([_permission isEqualToString:@"private"]) {
        self.privateButton.selected = YES;
        self.permissionLabel.text = @"Can only be seen by you";
//        self.permissionIcon.image = [UIImage imageNamed:@"lock"];
        self.permissionIcon.image = [UIImage tintedImageNamed:@"lock" color:COLOR(blackColor)];
    }
    else {
        self.permissionLabel.text = nil;
        self.permissionIcon.image = nil;
    }


    for (PNButton* button in @[self.publicButton, self.friendsButton, self.privateButton]) {
        if (button.selected)
            [button setBorderWithColor:COLOR(blackColor) width:2.0];
        else
            [button setBorderWithColor:nil width:0.0];
    }
}

- (void)onDismiss {
    if ([self.delegate respondsToSelector:@selector(snapInfo:didDismiss:)]) {
        [self.delegate snapInfo:self didDismiss:_snap];
    }
}

- (void)setPermission:(NSString *)permission {

}

- (void)onPublic {
    [self updatePermissionTo:@"public"];
}

- (void)onFriends {
    [self updatePermissionTo:@"friends"];
}

- (void)onPrivate {
    [self updatePermissionTo:@"private"];
}

- (void)onDelete {
    NSLog(@"DELETE!!! %@", self.snap);
}

- (void)onFlag {
    NSLog(@"flageeELETE!!! %@", self.snap);

}

- (void)updatePermissionTo:(NSString*)permission {
    [(Story*)self.snap setPermission:permission];
    self.snap.updated_at = [NSDate date];
    [self.snap save];

    [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/update", self.snap.id]
                   parameters:@{@"permission":permission}
                     callback:nil];
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self);
}

@end
