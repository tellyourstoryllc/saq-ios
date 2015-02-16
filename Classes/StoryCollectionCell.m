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
        CGFloat buttonDim = minDim/4;
        self.playButton = [[PNButton alloc] initWithFrame:CGRectMake(4, 4, buttonDim, buttonDim)];
        [self.playButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage tintedImageNamed:@"pause-icon" color:COLOR(blackColor)] forState:UIControlStateSelected];
        self.playButton.userInteractionEnabled = NO;
        self.playButton.buttonColor = [COLOR(blackColor) colorWithAlphaComponent:0.7];
        self.playButton.backgroundColor = [COLOR(whiteColor) colorWithAlphaComponent:0.8];
        [self.contentView addSubview:self.playButton];

    }

    return self;
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

    _story = story;
    self.card.message = self.story;
    self.card.userInteractionEnabled = NO;
    [self.card hideControls];
    self.playButton.hidden = YES;

    [self.card loadContentWithCompletion:^{
        self.playButton.hidden = !self.card.hasVideo;
    }];

}

- (void)didBecomeFeatured {
    [super didBecomeFeatured];
    self.playButton.selected = YES;
}

- (void)willResignFeatured {
    [super willResignFeatured];
    self.playButton.selected = NO;
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
    [self.card hideControls];
}

- (void)dealloc {
    [self prepareForReuse];
}

@end
