//
//  VideoDoodleController.m
//  FFM
//
//  Created by Jim Young on 4/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "VideoDoodleController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "PNKit.h"
#import "PNUserPreferences.h"
#import "PNVideoComposer.h"

@interface VideoDoodleController ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;

@end

@implementation VideoDoodleController

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor whiteColor];

    __weak VideoDoodleController* weakSelf = self;

    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:self.moviePlayer.view];

    self.graffitiView = [[GraffitiView alloc] init];
    self.graffitiView.graffitiDelegate = self;
    [self.view addSubview:self.graffitiView];

    // KVO
    [self.graffitiView addObserver:self forKeyPath:@"isTexting" options:NSKeyValueObservingOptionNew context:nil];
    [self.graffitiView addObserver:self forKeyPath:@"isDrawing" options:NSKeyValueObservingOptionNew context:nil];

    self.cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
    self.cancelButton.cornerRadius = 0;
    [self.cancelButton maskWithImage:[UIImage imageNamed:@"x"] inverted:YES];
    self.cancelButton.buttonColor = COLOR(grayColor);
    self.cancelButton.alpha = 0.66f;
    [self.cancelButton setBorderWithColor:[COLOR(blackColor) colorWithAlphaComponent:0.66f] width:1.0];
    [self.view addSubview:self.cancelButton];
    [self.cancelButton setTappedBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(videoPreviewDidCancel:)])
            [weakSelf.delegate videoPreviewDidCancel:weakSelf];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.graffitiView.buttonOffset = CGPointMake(0, -1*self.moviePlayer.view.frame.origin.y);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.moviePlayer play];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect b = self.view.bounds;
    self.moviePlayer.view.frame = b;
    self.graffitiView.frame = self.moviePlayer.view.frame;

    self.cancelButton.frame = CGRectSetOrigin(10, 10, self.cancelButton.frame);
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.moviePlayer.contentURL = videoURL;
}

- (void)updateControlsWithAnimation:(BOOL)animate {

}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void) graffitiDidStartEditing:(GraffitiView*)graffitiController {
    self.cancelButton.hidden = YES;
}

- (void) graffitiDidEndEditing:(GraffitiView*)graffitiController {
    self.cancelButton.hidden = NO;
}

- (void)playbackStateChanged:(NSNotification *)notification {
    [self updateControlsWithAnimation:NO];
}

- (void)playbackFinished:(NSNotification *)notification {
    [self.moviePlayer play];
}

- (void)loadStateChanged:(NSNotification *)notification {
    [self.view setNeedsLayout];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [self.graffitiView removeObserver:self forKeyPath:@"isTexting"];
    [self.graffitiView removeObserver:self forKeyPath:@"isDrawing"];
}

@end
