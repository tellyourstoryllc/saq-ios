//
//  TinderVideoView.m
//  SnapCracklePop
//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "VideoCardView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Flurry.h"
#import "PNCircularProgressView.h"
#import "Story.h"

@interface VideoCardView()

@property (nonatomic, strong) AVPlayer* avPlayer;
@property (nonatomic, strong) AVPlayerItem* avPlayerItem;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;

@property (nonatomic, strong) UIView* moviePlayerFrame;
@property (nonatomic, strong) UIImageView *screenshotView;
@property (nonatomic, strong) UIImageView *videoOverlayView;

@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) PNCircularProgressView* circleProgress;

@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL shouldStartPlaying;


@end

@implementation VideoCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect b = self.bounds;

        self.backgroundColor = COLOR(blackColor);

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

        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,0,b.size.width,20)];
        UIImage *progressImage = [UIImage imageWithColor:COLOR(defaultNavigationColor) cornerRadius:0];
        UIImage *trackImage = [[UIImage imageWithColor:[UIColor clearColor] cornerRadius:0]
                               imageWithMinimumSize:CGSizeMake(4, 20)];
        self.progressView.trackImage = trackImage;
        self.progressView.progressImage = progressImage;
        self.progressView.alpha = 0.4;
        [self addSubview:self.progressView];

        self.circleProgress = [[PNCircularProgressView alloc] initWithFrame:CGRectMake(0,0,b.size.width/3,b.size.width/3)];
        self.circleProgress.lineWidth = 3;
        self.circleProgress.tintColor = COLOR(yellowColor);
        self.circleProgress.hidden = YES;
        [self addSubview:self.circleProgress];

        self.circleProgress.center = self.center;

        [self setContentMode:UIViewContentModeScaleAspectFit];
        [self hideControls];
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
    self.progressView.frame = CGRectMake(0,0,b.size.width,20);
    self.circleProgress.frame = CGRectMake(0,0,b.size.width/3,b.size.width/3);
    self.circleProgress.center = self.center;
    self.playerLayer.frame = self.bounds;
}

- (void)setMessage:(SkyMessage *)message {
    if (self.message == message)
        return;

    [self.message cancelMediaFetch];
    [super setMessage:message];

    self.screenshotView.image = nil;
    self.screenshotView.hidden = NO;
    self.videoOverlayView.image = nil;
    self.videoUrl = nil;
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    [self hideControls];
    [self stop];
}

- (void)_performPlay {
    if (self.snapCard.videoEnabled && !self.isPlaying && self.shouldStartPlaying && self.playerLayer.readyForDisplay) {
        self.isPlaying = YES;
        self.avPlayer.muted = !self.snapCard.audioEnabled;
        self.screenshotView.hidden = YES;

        if (CMTIME_IS_VALID(self.snapCard.shouldStartPlayingAtTime)) {
            [self.avPlayer seekToTime:self.snapCard.shouldStartPlayingAtTime];
            self.snapCard.shouldStartPlayingAtTime = CMTimeMake(0, -1);
        }

        [self.avPlayer play];
        self.shouldStartPlaying = NO;
        self.playbackTimer = self.playbackTimer ?: [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(playbackTicked:) userInfo:nil repeats:YES];
        self.playbackTimer.tolerance = 0.1;
    }
}

- (void)play {

    self.shouldStartPlaying = YES;

    if (!self.isLoading) {
        self.isLoading = YES;
        __block SkyMessage* loadingMessage = self.message;
        __block NSString* msgId = self.message.id;
        __weak VideoCardView* weakSelf = self;

        // This hack prevents progress indicator from showing if media is fetched quickly (i.e., from local cache)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.isLoading) {
                weakSelf.circleProgress.hidden = NO;
                weakSelf.circleProgress.frame = CGRectMake(0,0,weakSelf.bounds.size.width/3,weakSelf.bounds.size.width/3);
                weakSelf.circleProgress.center = weakSelf.center;
                [weakSelf.circleProgress startSpinProgressBackgroundLayer];
            }
        });

        void (^loadVideoBlock)(NSURL *videoUrl, UIImage *videoOverlay) = ^(NSURL *videoUrl, UIImage *videoOverlay) {
            weakSelf.videoUrl = videoUrl;
            weakSelf.videoOverlayView.image = videoOverlay;

            NSError* error;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];

            weakSelf.avPlayerItem = [AVPlayerItem playerItemWithURL:videoUrl];

            if (!weakSelf.avPlayer) {
                weakSelf.avPlayer = [AVPlayer playerWithPlayerItem:weakSelf.avPlayerItem];
                weakSelf.snapCard.videoPlayer = weakSelf.avPlayer;
                [weakSelf subscribeToNotifications];
            }
            else {
                [weakSelf.avPlayer replaceCurrentItemWithPlayerItem:weakSelf.avPlayerItem];
            }
        };

        void (^doneLoadingBlock)() = ^() {
            weakSelf.isLoading = NO;
            weakSelf.circleProgress.hidden = YES;
            [weakSelf.circleProgress stopSpinProgressBackgroundLayer];
        };

        [weakSelf.message fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
            on_main(^{
                doneLoadingBlock();
                if (videoUrl && weakSelf.shouldStartPlaying && loadingMessage == weakSelf.message) {
                    loadVideoBlock(videoUrl, videoOverlay);
                }
            });
        }];
    }
}

- (void)pause {
    [self.avPlayer pause];
    self.shouldStartPlaying = NO;
    self.isPlaying = NO;
}

- (void)stop {
    self.shouldStartPlaying = NO;
    if (!self.isPlaying) return;
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
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
        [self play];
    }
}

- (void)subscribeToNotifications {

    [self.avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pause)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pause)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    on_main(^{
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
    });
}

- (void)messageWasUpdated {
    self.screenshotView.image = nil;
    [self loadContentWithCompletion:nil];
}

#pragma mark - Notifications

- (void)playbackFinished:(NSNotification *)notification {
    if (notification.object != self.avPlayerItem) return;

    self.isPlaying = NO;
    self.shouldStartPlaying = YES;
    [self.avPlayer seekToTime:CMTimeMake(0,10)];

    // Delegate may end looping by calling [card willResignFeatured]
    if ([self.snapCard.delegate respondsToSelector:@selector(card:didFinishPresenting:)]) {
        [self.snapCard.delegate card:self.snapCard didFinishPresenting:self.message];
    }

    [self _performPlay];
}

- (void) playbackTicked:(NSTimer*)timer {
    CGFloat percent = 1.f*CMTimeGetSeconds(self.avPlayer.currentTime)/CMTimeGetSeconds(self.avPlayerItem.duration);
    [self.progressView setProgress:percent];
}

- (void)volumeChanged:(NSNotification *)notification {
    static id initialVolume;
    id volume = [[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"];

    if (self.isPlaying && initialVolume && [volume floatValue] > [initialVolume floatValue]) {
        [self overrideMute];
    } else {
        initialVolume = volume;
    }
}

- (void)overrideMute {
}

- (void)didEnterBackground {
}

- (void)didAppear {
}

- (void)didDisappear {
    [self stop];
    self.screenshotView.hidden = NO;
}

- (void)didBecomeFeatured {
    [self play];
}

- (void)willResignFeatured {
    [self cancelIfLoading];
    [self stop];
    self.screenshotView.hidden = NO;
}

- (void)loadContentWithCompletion:(void (^)())completion {
    if (!self.screenshotView.image) {
        __weak SkyMessage* msg = self.message;
        __weak VideoCardView* weakSelf = self;

        [msg fetchImagePreviewWithCompletion:^(UIImage *image) {
            on_main(^{
                if (msg == weakSelf.message) {
                    weakSelf.screenshotView.image = image.images ? image.images.firstObject : image;

                    if (weakSelf.avPlayer.status != AVPlayerStatusReadyToPlay) {
                        weakSelf.screenshotView.hidden = NO;
                    }

                    if ([weakSelf.snapCard.delegate respondsToSelector:@selector(card:didLoadContent:)]) {
                        [weakSelf.snapCard.delegate card:weakSelf.snapCard didLoadContent:weakSelf.message];
                    }
                }
                if (completion) completion();
            });
        }];

        [msg fetchOverlayWithCompletion:^(UIImage *overlay) {
            on_main(^{
                if (msg == weakSelf.message) {
                    weakSelf.videoOverlayView.image = overlay;
                }
            });
        }];
    }
}

- (void)cancelIfLoading {
    __weak VideoCardView* weakSelf = self;
    if (self.isLoading) {
        on_main(^{
            [weakSelf.message cancelMediaFetch];
            weakSelf.isLoading = NO;
            weakSelf.circleProgress.hidden = YES;
            [weakSelf.circleProgress stopSpinProgressBackgroundLayer];
        });
    }
}

- (void)updateOrientation {
    // ...
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
    [self.playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.avPlayer removeObserver:self forKeyPath:@"status"];
    self.avPlayer = nil;
    self.avPlayerItem = nil;
    self.snapCard.videoPlayer = nil;
    [self.playbackTimer invalidate];
}

@end
