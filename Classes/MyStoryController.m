//
//  MyStoryController.m
//  TellYourStory
//
//  Created by Jim Young on 2/9/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "MyStoryController.h"
#import "StoryCamera.h"
#import "SnapCardView.h"
#import "PNVideoURLView.h"
#import "PillLabel.h"

#import "Api.h"
#import "ArrowBox.h"
#import "StoryManager.h"
#import "GroupManager.h"

@interface MyStoryController()<PNCameraDelegate, CardViewDelegate>

@property (strong) UIView* recorderView;
@property (strong) UIView* storyView;

@property (strong) StoryCamera* camera;
@property (strong) PNButton* activateButton;

@property (strong) PNLabel* filterLabel;
@property (strong) UISwitch* filterSwitch;

@property (strong) PNButton* discardButton;
@property (strong) PNButton* publishButton;

@property (strong) PNButton* storyPlayButton;
@property (strong) PNButton* cameraPlayButton;

@property (strong) PNVideoURLView* videoView;

@property (strong) PNRichLabel* instructionLabel;

@property (nonatomic, strong) User* user;
@property (strong) NSURL* draftUrl;

@end

@implementation MyStoryController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.storyView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.recorderView = [[UIView alloc] initWithFrame:self.view.bounds];

    [self.view addSubview:self.storyView];
    [self.view addSubview:self.recorderView];

    CGRect b = self.view.bounds;
    __weak MyStoryController* weakSelf = self;

    self.view.backgroundColor = COLOR(whiteColor);

    self.activateButton = [[PNButton alloc] initWithFrame: CGRectMake(0,0,100,100)];
    self.activateButton.buttonColor = COLOR(turquoiseColor);
    self.activateButton.hidden = NO;
    [self.activateButton addTarget:self action:@selector(onOpenCamera) forControlEvents:UIControlEventTouchDown];
    self.activateButton.titleLabel.numberOfLines = 0;
    self.activateButton.titleLabel.font = FONT_B(16);
    [self.activateButton sizeToFit];
    [self.recorderView addSubview:self.activateButton];

    self.camera = [[StoryCamera alloc] initWithFrame:CGRectMake(0,0,b.size.width, 220)];
    self.camera.delegate = self;

    self.camera.frame = CGRectSetCenter(b.size.width/2, b.size.height/2, self.camera.frame);
    self.camera.alpha = 0.0;
    self.camera.cameraView.layer.borderColor = [COLOR(blackColor) CGColor];
    self.camera.cameraView.layer.borderWidth = 2.f;

    [self.recorderView addSubview:self.camera];

    self.filterLabel = [PNLabel labelWithText:@"Anonymity filter: OFF" andFont:FONT_B(14)];
    self.filterLabel.textAlignment = NSTextAlignmentCenter;
    [self.recorderView addSubview:self.filterLabel];

    self.filterSwitch = [UISwitch new];
    [self.recorderView addSubview:self.filterSwitch];
    [self.filterSwitch addTarget:self action:@selector(onFilter) forControlEvents:UIControlEventValueChanged];

//    self.soundButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,100,50)];
//    [self.soundButton setBorderWithColor:COLOR(blackColor) width:1.0];
//    [self.soundButton setTitle:@"Disguise" forState:UIControlStateNormal];
//    [self.recorderView addSubview:self.soundButton];
//    [self.soundButton setTappedBlock:^{
//        weakSelf.soundButton.selected = !weakSelf.soundButton.selected;
//        [weakSelf.camera setFilteredAudioPitchFactor:weakSelf.soundButton.selected ? @(2.0) : @(1.0)];
//    }];

    self.discardButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.discardButton.cornerRadius = 20;
    self.discardButton.buttonColor = COLOR(whiteColor);
    [self.discardButton setBorderWithColor:COLOR(blackColor) width:1.0];
    [self.discardButton setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [self.recorderView addSubview:self.discardButton];
    [self.discardButton setTappedBlock:^{
        [weakSelf.camera discard];
    }];

    self.publishButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,180,60)];
    self.publishButton.buttonColor = COLOR(turquoiseColor);
    self.publishButton.cornerRadius = 10;
    self.publishButton.titleLabel.font = FONT_B(18);
    [self.publishButton setTitleColor:COLOR(whiteColor) forState:UIControlStateNormal];
    [self.publishButton setTitle:@"Add My Story" forState:UIControlStateNormal];
    [self.recorderView addSubview:self.publishButton];
    [self.publishButton setTappedBlock:^{
        [weakSelf publishStory];
    }];

    self.storyPlayButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    self.storyPlayButton.buttonColor = COLOR(blackColor);
    self.storyPlayButton.cornerRadius = 30;
    [self.storyPlayButton setBorderWithColor:COLOR(blackColor) width:2.0];
    [self.storyPlayButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
    [self.storyPlayButton setImage:[UIImage tintedImageNamed:@"pause-icon" color:COLOR(blackColor)] forState:UIControlStateSelected];
    [self.storyView addSubview:self.storyPlayButton];

    [self.storyPlayButton setTappedBlock:^{
        if (weakSelf.videoView.isPlaying) {
            [weakSelf.videoView stop];
            weakSelf.storyPlayButton.selected = NO;
        }
        else {
            [weakSelf.videoView play];
            weakSelf.storyPlayButton.selected = YES;
        }
    }];

    self.cameraPlayButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    self.cameraPlayButton.buttonColor = COLOR(blackColor);
    self.cameraPlayButton.cornerRadius = 30;
    [self.cameraPlayButton setBorderWithColor:COLOR(blackColor) width:2.0];
    [self.cameraPlayButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
    [self.cameraPlayButton setImage:[UIImage tintedImageNamed:@"pause-icon" color:COLOR(blackColor)] forState:UIControlStateSelected];
    [self.recorderView addSubview:self.cameraPlayButton];

    [self.cameraPlayButton setTappedBlock:^{
        if (weakSelf.camera.player.isPlaying) {
            [weakSelf.camera pauseVideoPlayback];
            weakSelf.cameraPlayButton.selected = NO;
        }
        else {
            [weakSelf.camera startVideoPlayback];
            weakSelf.cameraPlayButton.selected = YES;
        }
    }];



    self.videoView = [PNVideoURLView new];
    self.videoView.userInteractionEnabled = NO;
    [self.storyView addSubview:self.videoView];

    [self configureView];

    [self.KVOController observe:self.camera keyPath:@"isRecording" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self configureView];
                          }];

    [self.KVOController observe:self.camera keyPath:@"isComposing" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self configureView];
                          }];

    self.user = [[Api sharedApi] currentUser];

    [self.KVOController observe:[Api sharedApi] keyPath:@"currentUser"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              self.user = [[Api sharedApi] currentUser];
                              [self configureView];
                          }];
}

- (void)viewDidAppear:(BOOL)animated {

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [self.activateButton setTitle:@"Tap to activate camera" forState:UIControlStateNormal];
    }
    else {
        [self.activateButton setTitle:@"Tap to allow Access to \nMic & Camera ❭" forState:UIControlStateNormal];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect b = self.view.bounds;

    self.activateButton.frame = CGRectSetCenter(b.size.width/2, b.size.height*(1-1/GOLDEN_MEAN), self.activateButton.frame);
    self.camera.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMinY(self.activateButton.frame), self.camera.frame);
    self.videoView.frame = self.activateButton.frame;

    [self.filterLabel sizeToFitTextWidth:CGRectGetMinX(self.activateButton.frame)-8];
    self.filterLabel.frame = CGRectSetTopRight(CGRectGetMinX(self.activateButton.frame)-4, CGRectGetMinY(self.activateButton.frame), self.filterLabel.frame);
    self.filterSwitch.frame = CGRectSetTopCenter(CGRectGetMidX(self.filterLabel.frame), CGRectGetMaxY(self.filterLabel.frame)+4, self.filterSwitch.frame);

    // Place discard button at top right corner of video frame
    self.discardButton.frame = CGRectSetCenter(CGRectGetMaxX(self.activateButton.frame), CGRectGetMinY(self.activateButton.frame), self.discardButton.frame);

    self.publishButton.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.camera.frame), self.publishButton.frame);

    self.storyPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.videoView.frame),
                                               CGRectGetMaxY(self.videoView.frame)+10,
                                               self.storyPlayButton.frame);

    self.cameraPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.activateButton.frame),
                                                    CGRectGetMaxY(self.activateButton.frame)+10,
                                                    self.cameraPlayButton.frame);
}

- (void)setUser:(User *)user {
    if ([_user isEqual:user]) return;

    [self.KVOController unobserve:_user];
    _user = user;
    [self.KVOController observe:_user keyPath:@"updated_at"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [[user last_story] fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
                                  self.videoView.videoUrl = videoUrl;
                                  [self configureView];
                              }];
                          }];

    [[user last_story] fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
        self.videoView.videoUrl = videoUrl;
    }];
}

- (void)onOpenCamera {

    [self.activateButton setTitle:nil forState:UIControlStateNormal];
    self.camera.alpha = 0.0;

    [UIView animateWithDuration:1.337 animations:^{
        self.activateButton.alpha = 0.0;
        self.camera.alpha = 1.0;
    }];

//    [self.label1 fadeOutOverDuration:1.0 fromColor:nil completion:nil afterDelay:0];

    [self.camera startPreviewWithCompletion:^(BOOL success) {
        self.activateButton.hidden = YES;
    }];

}

- (void)configureView {
    self.filterLabel.hidden = !self.camera.isRecording;
    self.filterSwitch.hidden = !self.camera.isRecording;

    self.discardButton.hidden = !self.camera.isComposing;
    self.publishButton.hidden = !self.camera.isComposing;
    self.cameraPlayButton.hidden = !self.camera.isComposing;

    if (self.videoView.videoUrl) {
        self.storyView.hidden = NO;
        self.recorderView.hidden = YES;
    }
    else {
        self.storyView.hidden = YES;
        self.recorderView.hidden = NO;
    }
}

#pragma mark camera delegate mathods

- (void)camera:(id)recorder didRecord:(NSURL*)videoUrl
{
    _draftUrl = videoUrl;
    PNCamera* camera = (PNCamera*)recorder;
    camera.player.muted = NO;
    camera.player.backgroundColor = COLOR(darkGrayColor);
    camera.player.screenshot = camera.snapshot;
    [camera stopPreview];
}

- (void)cameraDidFailToRecord:(id)recorder {
}

- (void)cameraidShutoff:(id)recorder {
}

- (void)onFilter {
    if (self.filterSwitch.isOn) {
        self.camera.currentFilterIndex = 1;
        [self.camera setFilteredAudioPitchFactor:@(2.0)];
        self.filterLabel.text = @"Anonymity filter: ON";

    }
    else {
        self.camera.currentFilterIndex = 0;
        [self.camera setFilteredAudioPitchFactor:@(1.0)];
        self.filterLabel.text = @"Anonymity filter: OFF";
    }
}

- (void)publishStory {
    if (!_draftUrl) return;

    NSDictionary* params = @{@"source":@"camera", @"permission":@"public"};
    [Story publishVideo:_draftUrl
                orImage:nil
            withOverlay:nil
                 params:params
             completion:^(Story *newStory) {
                 [self.meController openRegistration];
             }];
}

- (void)showOptions {

}

@end

