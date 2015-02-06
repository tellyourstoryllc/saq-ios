//
//  StoryCollectionCell.m
//  SnapCracklePop
//
//  Created by Jim Young on 9/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryCollectionCell.h"
#import "GraphicsSettingsCell.h"

@interface StoryCollectionCell()

@property (nonatomic, strong) PNLabel* usernameLabel;
@property (nonatomic, assign) BOOL cardWasFeatured;
@property (nonatomic, assign) UIViewContentMode savedContentMode;

@property (nonatomic, strong) PNButton* playButton;
@property (nonatomic, strong) UIView* permissionView;

@end

@implementation StoryCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGRect b = self.contentView.bounds;

        self.usernameLabel = [[PNLabel alloc] initWithFrame:self.contentView.bounds];
        self.usernameLabel.textAlignment = NSTextAlignmentCenter;
        self.usernameLabel.transform = CGAffineTransformMakeRotation(-M_PI/3.f);
        self.usernameLabel.font = USERFONT(18);

        [self.contentView addSubview:self.usernameLabel];

        CGFloat minDim = MIN(self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        CGFloat buttonDim = minDim/2.5;
        self.playButton = [[PNButton alloc] initWithFrame:CGRectMake(0, 0, buttonDim, buttonDim)];
        [self.playButton maskWithImage:[UIImage imageNamed:@"play-icon"] inverted:YES];
        self.playButton.cornerRadius = buttonDim/2;
        self.playButton.center = self.contentView.center;
        self.playButton.userInteractionEnabled = NO;
        self.playButton.buttonColor = [COLOR(whiteColor) colorWithAlphaComponent:0.33];
        self.playButton.hidden = YES;
        [self.contentView addSubview:self.playButton];

        self.permissionView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMakeCorners(0, b.size.height*0.95, b.size.width, b.size.height))];
        [self.contentView addSubview:self.permissionView];

        UILongPressGestureRecognizer* press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didPress:)];
        press.minimumPressDuration = 0.2;
        [self addGestureRecognizer:press];
    }

    return self;
}

- (void)didPress:(UIGestureRecognizer*)gesture {

    static BOOL navBarWasHidden;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.window addSubview:self.card];
        self.card.frame = self.window.bounds;
        self.cardWasFeatured = self.card.isFeatured;
        self.savedContentMode = self.card.contentMode;

        if (self.cardWasFeatured)
            [self.card willResignFeatured]; // <-- in case video was already running

        self.card.audioEnabled = YES;
        self.card.contentMode = UIViewContentModeScaleAspectFit;
        [self.card didBecomeFeatured];
        [self.card.message markViewed];

        navBarWasHidden = self.controller.navigationController.isNavigationBarHidden;
        [self.controller.navigationController setNavigationBarHidden:YES];
        [self.controller setNeedsStatusBarAppearanceUpdate];

        PNLOG(@"story_tiles.press");

    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.contentView insertSubview:self.card belowSubview:self.usernameLabel];
        self.card.frame = self.bounds;
        self.card.audioEnabled = NO;
        [self.card willResignFeatured];

        [self.controller.navigationController setNavigationBarHidden:navBarWasHidden];
        [self.controller setNeedsStatusBarAppearanceUpdate];

        if (self.cardWasFeatured)
            [self.card didBecomeFeatured];

        self.card.contentMode = self.savedContentMode;
    }
}

- (void)setUser:(User *)user {
    if (_user == user) return;

    [_user removeObserver:self forKeyPath:@"last_story"];
    _user = user;
    [_user addObserver:self forKeyPath:@"last_story" options:NSKeyValueObservingOptionNew context:nil];

    if (!user.last_story && user.last_story_at) {
        [user updateLastStory];
    }

    self.usernameLabel.text = user.displayName;
    self.usernameLabel.textColor = COLOR(whiteColor);

    self.story = user.last_story;
}

- (void)setStory:(Story *)story {

    if (_story == story) return;

    [self.KVOController unobserve:_story];
    _story = story;
    self.card.message = self.story;
    self.card.userInteractionEnabled = NO;
    [self.card hideControls];
    self.playButton.hidden = YES;
    [self updateBorder];

    [self.card loadContentWithCompletion:^{
        self.playButton.hidden = !self.card.hasVideo;
    }];

    [self.KVOController observe:_story keyPath:@"updated_at" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        on_main(^{
            [self updateBorder];
        });
    }];
}

- (void)updateBorder {
    if (_story.user.isMe) {
        if (_story.isPublic) {
            self.permissionView.backgroundColor = [COLOR(publicColor) colorWithAlphaComponent:0.8];
        }
        else if (_story.isFriends) {
            self.permissionView.backgroundColor = [COLOR(friendColor) colorWithAlphaComponent:0.8];
        }
        else {
            self.permissionView.backgroundColor = nil;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    _story = _user.last_story;
    self.card.message = self.story;
    [self.card loadContent];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.user = nil;
    self.story = nil;
    self.playButton.hidden = YES;
    [self.card hideControls];
}

- (void)dealloc {
    [self prepareForReuse];
}

@end
