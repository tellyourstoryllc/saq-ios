//
//  VideoURLView.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "VideoURLView.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoURLView()

@property (nonatomic, strong) AVPlayer* avPlayer;
@property (nonatomic, strong) AVPlayerItem* avPlayerItem;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;

@property (nonatomic, strong) UIView* moviePlayerFrame;
@property (nonatomic, strong) UIImageView *screenshotView;
@property (nonatomic, strong) UIImageView *videoOverlayView;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL shouldStartPlaying;

@end

@implementation VideoURLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect b = self.bounds;

        self.moviePlayerFrame = [[UIView alloc] initWithFrame:b];
        self.moviePlayerFrame.userInteractionEnabled = NO;
        [self addSubview:self.moviePlayerFrame];

        self.screenshotView = [[UIImageView alloc] initWithFrame:b];
        self.screenshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.screenshotView];

        self.videoOverlayView = [[UIImageView alloc] initWithFrame:b];
        self.videoOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.videoOverlayView.userInteractionEnabled = NO;
        [self addSubview:self.videoOverlayView];

        [self setContentMode:UIViewContentModeScaleAspectFit];
    }

    return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.screenshotView.contentMode = contentMode;
    self.videoOverlayView.contentMode = contentMode;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
    self.moviePlayerFrame.frame = b;
    self.screenshotView.frame = b;
    self.videoOverlayView.frame = b;
    self.playerLayer.frame = self.bounds;
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    self.screenshotView.image = nil;
    self.screenshotView.hidden = NO;
    self.videoOverlayView.image = nil;
    _videoUrl = videoUrl;
    [self removeAvPlayer];
}

- (void)setScreenshot:(UIImage *)screenshot {
    _screenshot = screenshot;
    self.screenshotView.image = screenshot;
}

- (void)setOverlay:(UIImage *)overlay {
    _overlay = overlay;
    self.videoOverlayView.image = overlay;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.avPlayer.muted = muted;
}

- (void)_performPlay {
    if (!self.isPlaying && self.shouldStartPlaying && self.playerLayer.readyForDisplay) {
        self.isPlaying = YES;
        self.avPlayer.muted = self.muted;
        [self.avPlayer play];
        self.shouldStartPlaying = NO;
    }
}

- (void)play {

    self.shouldStartPlaying = YES;

    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    self.avPlayerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];

    [self unsubscribeFromNotifications]; // <-- just in case.
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    [self subscribeToNotifications];
}

- (void)pause {
    [self.avPlayer pause];
    self.shouldStartPlaying = NO;
    self.isPlaying = NO;
}

- (void)stop {
    self.shouldStartPlaying = NO;
    if (!self.isPlaying) return;
    [self.avPlayer pause];
    [self.avPlayer seekToTime:CMTimeMake(0,10)];
    self.isPlaying = NO;
}

- (void)updateOverlaysWithAnimation:(BOOL)animate {
}

- (void)setFrame:(CGRect)frame {
    BOOL frameChanged = !CGRectEqualToRect(self.frame, frame);
    [super setFrame:frame];

    if (frameChanged && self.isPlaying) {
        [self stop];
        [self removeAvPlayer];
        [self play];
    }
}

- (void)subscribeToNotifications {
    [self.avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayerItem];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.avPlayer removeObserver:self forKeyPath:@"status"];
    [self.playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
        if (object == self.avPlayer && [keyPath isEqualToString:@"status"] && self.avPlayer.status == AVPlayerStatusReadyToPlay) {
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            [self.playerLayer addObserver:self
                               forKeyPath:@"readyForDisplay"
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                                  context:nil];
            self.playerLayer.videoGravity = self.contentMode == UIViewContentModeScaleAspectFill ? AVLayerVideoGravityResizeAspectFill : AVLayerVideoGravityResizeAspect; // <-- equivalent to contentMode
            self.playerLayer.frame = self.bounds;
            [self.moviePlayerFrame.layer addSublayer:self.playerLayer];

            if (self.shouldStartPlaying) [self _performPlay];
        }

        if (object == self.playerLayer) {
            self.screenshotView.hidden = self.playerLayer.readyForDisplay;
            if (self.shouldStartPlaying) [self _performPlay];
        }
}

#pragma mark - Notifications

- (void)playbackFinished:(NSNotification *)notification {
    self.isPlaying = NO;
    self.shouldStartPlaying = YES;
    [self.avPlayer seekToTime:CMTimeMake(0,10)];
    [self _performPlay];
}

- (void)removeAvPlayer {
    [self unsubscribeFromNotifications];
    [self stop];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.avPlayer = nil;
    self.avPlayerItem = nil;
    self.screenshotView.hidden = NO;
}

- (void)dealloc {
    [self removeAvPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
