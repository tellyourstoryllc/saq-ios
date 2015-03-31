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
#import "AlertView.h"
#import "SharePreferenceController.h"
#import "PNUserPreferences.h"

@interface MyStoryController()<PNCameraDelegate, CardViewDelegate, SharePreferenceDelegate>

@property (nonatomic, strong) Story* story;

@property (strong) UIView* recorderView;
@property (strong) UIView* storyView;

@property (strong) StoryCamera* camera;
@property (strong) PNButton* activateButton;

@property (strong) PNLabel* filterLabel;
@property (strong) UISwitch* filterSwitch;
@property (strong) PNLabel* soundLabel;
@property (strong) UISwitch* soundSwitch;

@property (strong) PNButton* discardButton;
@property (strong) PNButton* publishButton;

@property (strong) PNButton* storyPlayButton;
@property (strong) PNButton* cameraPlayButton;

@property (strong) PNVideoURLView* videoView;

@property (strong) PNRichLabel* instructionLabel;
@property (strong) PNLabel* thanksLabel;
@property (strong) PNLabel* statusLabel;

@property (strong) PNRichLabel* tosLabel;

@property (strong) PNLabel* shareLabel;
@property (strong) UISwitch* shareSwitch;
@property (strong) PNLabel* anywhereLabel;
@property (strong) UISwitch* anywhereSwitch;

@property (strong) NSURL* draftUrl;

@property (strong) NSString* shareSetting;  // If set, story needs to be updated with this setting.
@property (assign) BOOL needsShareSetting;

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

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.activateButton = [[PNButton alloc] initWithFrame: CGRectMake(0,0,100,100)];
    self.activateButton.buttonColor = COLOR(blackColor);
    self.activateButton.hidden = NO;
    [self.activateButton addTarget:self action:@selector(onOpenCamera) forControlEvents:UIControlEventTouchDown];
    self.activateButton.titleLabel.numberOfLines = 0;
    self.activateButton.titleLabel.font = FONT_B(14);
    self.activateButton.titleEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    [self.recorderView addSubview:self.activateButton];

    self.camera = [[StoryCamera alloc] initWithFrame:CGRectMake(0,0,b.size.width, 230)];
    self.camera.delegate = self;

    self.camera.frame = CGRectSetCenter(b.size.width/2, b.size.height/3, self.camera.frame);
    self.camera.alpha = 0.0;
    self.camera.cameraView.layer.borderColor = [COLOR(grayColor) CGColor];
    self.camera.cameraView.layer.borderWidth = 2.f;

    [self.recorderView addSubview:self.camera];

    self.filterLabel = [PNLabel labelWithText:@"Blur face: OFF" andFont:FONT_B(14)];
    self.filterLabel.textAlignment = NSTextAlignmentCenter;
    [self.recorderView addSubview:self.filterLabel];

    self.filterSwitch = [UISwitch new];
    self.filterSwitch.tintColor = COLOR(grayColor);
    self.filterSwitch.onTintColor = COLOR(turquoiseColor);
    [self.recorderView addSubview:self.filterSwitch];
    [self.filterSwitch addTarget:self action:@selector(onFilter) forControlEvents:UIControlEventValueChanged];

    self.soundLabel = [PNLabel labelWithText:@"Disguise voice: OFF" andFont:FONT_B(14)];
    self.soundLabel.textAlignment = NSTextAlignmentCenter;
    [self.recorderView addSubview:self.soundLabel];

    self.soundSwitch = [UISwitch new];
    self.soundSwitch.tintColor = COLOR(grayColor);
    self.soundSwitch.onTintColor = COLOR(turquoiseColor);
    [self.recorderView addSubview:self.soundSwitch];
    [self.soundSwitch addTarget:self action:@selector(onSoundSwitch) forControlEvents:UIControlEventValueChanged];

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
    self.discardButton.buttonColor = COLOR(defaultBackgroundColor);
    [self.discardButton setBorderWithColor:COLOR(grayColor) width:1.0];
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
    [self.publishButton setTitle:@"Submit Story" forState:UIControlStateNormal];
    [self.recorderView addSubview:self.publishButton];
    [self.publishButton setTappedBlock:^{
        [weakSelf publishStory];
    }];

    self.tosLabel = [[PNRichLabel alloc] init];
    self.tosLabel.text = @"By submitting, you agree to the <a href=http://tellyourstory.org/legal/tos>Terms of Service</a>";
    self.tosLabel.font = FONT(12);
    self.tosLabel.textAlignment = RTTextAlignmentCenter;
    [self.tosLabel sizeToFitTextWidth:self.view.bounds.size.width];
    [self.recorderView addSubview:self.tosLabel];

    self.instructionLabel = [[PNRichLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-16, 100)];
    self.instructionLabel.font = FONT_B(16);
    self.instructionLabel.text = @"1. Tell what happened<br><br>2. Tell how you dealt with it<br><br>3. No last names";
    [self.recorderView addSubview:self.instructionLabel];

    self.thanksLabel = [PNLabel new];
    self.thanksLabel.textAlignment = NSTextAlignmentCenter;
    [self.storyView addSubview:self.thanksLabel];

    self.storyPlayButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
    self.storyPlayButton.buttonColor = COLOR(blackColor);
    self.storyPlayButton.cornerRadius = 30;
    [self.storyPlayButton setBorderWithColor:COLOR(blackColor) width:2.0];
    [self.storyPlayButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
    [self.storyPlayButton setImage:[UIImage tintedImageNamed:@"pause-icon" color:COLOR(blackColor)] forState:UIControlStateSelected];
    [self.storyView addSubview:self.storyPlayButton];

    [self.storyPlayButton setTappedBlock:^{
        if (weakSelf.videoView.isPlaying) {
            [weakSelf.videoView pause];
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
        if (weakSelf.camera.player.isPlaying)
            [weakSelf.camera pauseVideoPlayback];
        else
            [weakSelf.camera startVideoPlayback];
    }];

    [self.KVOController observe:self.camera.player keyPath:@"isPlaying"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.cameraPlayButton.selected = weakSelf.camera.player.isPlaying;
                          }];

    self.videoView = [PNVideoURLView new];
    self.videoView.userInteractionEnabled = NO;
    self.videoView.autoReplay = NO;
    [self.storyView addSubview:self.videoView];

    [self.KVOController observe:self.videoView keyPath:@"isPlaying"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.storyPlayButton.selected = weakSelf.videoView.isPlaying;
                          }];

    self.statusLabel = [PNLabel new];
    self.statusLabel.font = FONT_B(18);
    [self.storyView addSubview:self.statusLabel];

    self.shareLabel = [PNLabel labelWithText:@"Make my video available on YouTube" andFont:FONT_B(14)];
    [self.storyView addSubview:self.shareLabel];

    self.shareSwitch = [UISwitch new];
    self.shareSwitch.tintColor = COLOR(grayColor);
    self.shareSwitch.onTintColor = COLOR(turquoiseColor);
    [self.storyView addSubview:self.shareSwitch];
    [self.shareSwitch addTarget:self action:@selector(onShareSwitch) forControlEvents:UIControlEventValueChanged];

    self.anywhereLabel = [PNLabel labelWithText:@"The YouTube video can be seen on other sites" andFont:FONT_B(14)];
    [self.storyView addSubview:self.anywhereLabel];

    self.anywhereSwitch = [UISwitch new];
    self.anywhereSwitch.tintColor = COLOR(grayColor);
    self.anywhereSwitch.onTintColor = COLOR(turquoiseColor);
    [self.storyView addSubview:self.anywhereSwitch];
    [self.anywhereSwitch addTarget:self action:@selector(onAnywhereSwitch) forControlEvents:UIControlEventValueChanged];

    [self.KVOController observe:self.camera
                       keyPaths:@[@"isRecording", @"isPreviewing", @"isComposing"]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [weakSelf configureView];
                          }];

    self.user = [User me];

    [self.KVOController observe:[Api sharedApi]
                        keyPath:@"currentUser"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.user = [User me];
                          }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreCamera)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self onSound];
    [self onFilter];

    if (!self.camera.isComposing && [self isViewVisible]) {
        BOOL started = [self.camera startPreviewIfAuthorized];
        if (started) {
            self.activateButton.hidden = YES;
            self.camera.alpha = 1.0;
        }
        else {
            [self.activateButton setTitle:@"START ❭" forState:UIControlStateNormal];
        }
    }

    if (self.needsShareSetting && _story && !_story.blurredValue) {
        self.needsShareSetting = NO;
        SharePreferenceController* vc = [SharePreferenceController new];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAllPlayback];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect b = self.view.bounds;

    self.instructionLabel.frame = CGRectSetOrigin(8, 80, self.instructionLabel.frame);

    self.activateButton.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.instructionLabel.frame)+20, self.activateButton.frame);
    self.camera.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMinY(self.activateButton.frame), self.camera.frame);
//    self.videoView.frame = self.activateButton.frame;
    self.videoView.frame = CGRectSetTopCenter(b.size.width/2, 80, self.activateButton.frame);

    self.filterSwitch.frame = CGRectSetBottomCenter(b.size.width/6, CGRectGetMaxY(self.activateButton.frame)+60, self.filterSwitch.frame);
    [self.filterLabel sizeToFitTextWidth:CGRectGetMinX(self.activateButton.frame)-8];
    self.filterLabel.frame = CGRectSetTopCenter(b.size.width/6, CGRectGetMaxY(self.filterSwitch.frame), self.filterLabel.frame);

    self.soundSwitch.frame = CGRectSetBottomCenter(5*b.size.width/6, CGRectGetMaxY(self.activateButton.frame)+60, self.soundSwitch.frame);
    [self.soundLabel sizeToFitTextWidth:CGRectGetMinX(self.activateButton.frame)-8];
    self.soundLabel.frame = CGRectSetTopCenter(5*b.size.width/6, CGRectGetMaxY(self.soundSwitch.frame), self.soundLabel.frame);

    // Place discard button at top right corner of video frame
    self.discardButton.frame = CGRectSetCenter(CGRectGetMaxX(self.activateButton.frame), CGRectGetMinY(self.activateButton.frame), self.discardButton.frame);

    self.publishButton.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.camera.frame), self.publishButton.frame);

    self.storyPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.videoView.frame),
                                               CGRectGetMaxY(self.videoView.frame)+10,
                                               self.storyPlayButton.frame);

    self.cameraPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.activateButton.frame),
                                                    CGRectGetMaxY(self.activateButton.frame)+10,
                                                    self.cameraPlayButton.frame);

    self.thanksLabel.frame = self.instructionLabel.frame;
    self.statusLabel.frame = CGRectSetTopCenter(CGRectGetMidX(self.storyPlayButton.frame), CGRectGetMaxY(self.storyPlayButton.frame)+8, self.statusLabel.frame);
    self.tosLabel.frame = CGRectSetBottomCenter(CGRectGetMidX(self.publishButton.frame), CGRectGetMinY(self.publishButton.frame), self.tosLabel.frame);

    //
    [self.shareLabel sizeToFitTextWidth:b.size.width/2];
    self.shareLabel.frame = CGRectSetTopCenter(b.size.width/2 + CGRectGetWidth(self.shareSwitch.frame)/2, CGRectGetMaxY(self.statusLabel.frame)+40, self.shareLabel.frame);

    self.shareSwitch.frame = CGRectSetMiddleRight(CGRectGetMinX(self.shareLabel.frame)-10, CGRectGetMidY(self.shareLabel.frame), self.shareSwitch.frame);

    [self.anywhereLabel sizeToFitTextWidth:b.size.width/2];
    self.anywhereLabel.frame = CGRectSetTopCenter(b.size.width/2 + CGRectGetWidth(self.anywhereSwitch.frame)/2, CGRectGetMaxY(self.shareLabel.frame)+10, self.anywhereLabel.frame);

    self.anywhereSwitch.frame = CGRectSetMiddleRight(CGRectGetMinX(self.anywhereLabel.frame)-10, CGRectGetMidY(self.anywhereLabel.frame), self.anywhereSwitch.frame);


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)setUser:(User *)user {

    if ([_user isEqual:user]) return;

    void (^updateBlock)(User*) = ^(User* user) {
        Story* story = user.last_story;
        self.story = story;

        if (story) {
            [story fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
                self.videoView.videoUrl = videoUrl;
                [self configureView];
            }];

            [story fetchImagePreviewWithCompletion:^(UIImage *image) {
                self.videoView.screenshot = image;
            }];

            if (story.likes_countValue) {
                if (story.likes_countValue == 1)
                    self.thanksLabel.text = @"1 person thanked you for your story.";
                else
                    self.thanksLabel.text = [NSString stringWithFormat:@"%d people thanked you for your story.", story.likes_countValue];
            }
            else
                self.thanksLabel.text = nil;
        }
        else {
            self.videoView.videoUrl = nil;
            self.videoView.screenshot = nil;
            [self configureView];
        }
    };

    [self.KVOController unobserve:_user];
    _user = user;
    [self.KVOController observe:_user keyPaths:@[@"updated_at", @"last_story"]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              updateBlock(self.user);
                              if (!self.camera.isRecording && [self isViewVisible])
                                  [self.camera startPreviewIfAuthorized];
                          }];

    updateBlock(user);
}

- (void)setStory:(Story *)story {
    if (_story == story)
        return;

    [self.KVOController unobserve:_story];
    _story = story;
    [self.KVOController observe:_story keyPath:@"updated_at"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self updateStatus];
                              [self updateShareControls];
                          }];

    on_main(^{
        [self updateStatus];
        [self updateShareControls];

        if ([_story.shareable_to isEqualToString:@"anywhere"]) {
            self.shareSwitch.on = YES;
            self.anywhereSwitch.on = YES;
        } else if ([_story.shareable_to isEqualToString:@"youtube"]) {
            self.shareSwitch.on = YES;
            self.anywhereSwitch.on = NO;
        }
        else {
            self.shareSwitch.on = NO;
            self.anywhereSwitch.on = NO;
            self.needsShareSetting = ![[PNUserPreferences shared] boolPreference:@"share_completed" orDefault:NO];
        }
    });
}

- (void)onOpenCamera {

    void (^block)() = ^() {
        [self.activateButton setTitle:nil forState:UIControlStateNormal];
        self.camera.alpha = 0.0;

        [UIView animateWithDuration:1.337 animations:^{
            self.activateButton.alpha = 0.0;
            self.camera.alpha = 1.0;
        }];

        [self.camera startPreviewWithCompletion:^(BOOL success) {
            self.activateButton.hidden = YES;
        }];
    };

    AlertView* av = [[AlertView alloc] initWithTitle:@"Allow Camera and Mic?"
                                             message:@"Access to your camera and microphone are needed to record your story."
                                      andButtonArray:@[@"Yes", @"Not Now"]];

    [av showWithCompletion:^(NSInteger buttonIndex) {
        if (buttonIndex == 0)
            block();
    }];
}

- (void)configureView {

    __weak MyStoryController* weakSelf = self;

    on_main(^{
        BOOL hideControls = !weakSelf.camera.isRecording && !weakSelf.camera.isPreviewing;
        weakSelf.filterLabel.hidden = hideControls;
        weakSelf.filterSwitch.hidden = hideControls;
        weakSelf.soundLabel.hidden = hideControls;
        weakSelf.soundSwitch.hidden = hideControls;

        weakSelf.discardButton.hidden = !weakSelf.camera.isComposing;
        weakSelf.publishButton.hidden = !weakSelf.camera.isComposing;
        weakSelf.cameraPlayButton.hidden = !weakSelf.camera.isComposing;

        weakSelf.instructionLabel.hidden = weakSelf.camera.isComposing;
        weakSelf.tosLabel.hidden = weakSelf.publishButton.hidden;

        if (weakSelf.videoView.videoUrl) {
            weakSelf.storyView.hidden = NO;
            weakSelf.recorderView.hidden = YES;
        }
        else {
            weakSelf.storyView.hidden = YES;
            weakSelf.recorderView.hidden = NO;
        }
    });
}

- (void)updateStatus {
    if ([_user.last_story.status isEqualToString:@"review"])
        self.statusLabel.text = @"In Review";
    else
        self.statusLabel.text = nil;

    [self.statusLabel sizeToFit];
    self.statusLabel.frame = CGRectSetTopCenter(CGRectGetMidX(self.storyPlayButton.frame), CGRectGetMaxY(self.storyPlayButton.frame)+8, self.statusLabel.frame);
}

- (void)updateShareControls {
    if ([_user.last_story blurredValue]) {
        self.shareSwitch.hidden = YES;
        self.anywhereSwitch.hidden = YES;
    }
    else {
        self.anywhereSwitch.hidden = !self.shareSwitch.isOn;
    }

    self.shareLabel.hidden = self.shareSwitch.hidden;
    self.anywhereLabel.hidden = self.anywhereSwitch.hidden;

    if (self.needsShareSetting && _story && !_story.blurredValue) {
        self.needsShareSetting = NO;
        SharePreferenceController* vc = [SharePreferenceController new];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)stopAllPlayback {
    [self.camera pauseVideoPlayback];
    [self.videoView stop];
    self.storyPlayButton.selected = NO;
    self.cameraPlayButton.selected = NO;
}

- (void)restoreCamera {
    if (!self.camera.isComposing)
        [self.camera startPreviewIfAuthorized];
}

#pragma mark camera delegate mathods

- (void)camera:(id)recorder didRecord:(NSURL*)videoUrl
{
    self.cameraPlayButton.selected = NO;

    _draftUrl = videoUrl;
    BaseCamera* camera = (BaseCamera*)recorder;
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
        self.filterLabel.text = @"Blur face: ON";
        self.camera.detectFacesPeriod = -1.0; // do as fast as you can
    }
    else {
        self.camera.currentFilterIndex = 0;
        self.filterLabel.text = @"Blur face: OFF";
        self.camera.detectFacesPeriod = 1.5; // normal slow setting
    }
}

- (void)onSoundSwitch {
    if (self.soundSwitch.isOn) {
        AlertView* av = [[AlertView alloc] initWithTitle:@"Disguise Voice" message:@"How do you want your voice altered?" andButtonArray:@[@"Lower pitch", @"Raise pitch"]];
        [av showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0)
                self.camera.audioFilter.pitchOne = -5;
            else
                self.camera.audioFilter.pitchOne = 7;
        }];
    }

    [self onSound];
}

- (void)onSound {
    if (self.soundSwitch.isOn) {
        self.camera.filteredAudio = YES;
        self.soundLabel.text = @"Disguise voice: ON";

    }
    else {
        self.camera.filteredAudio = NO;
        self.soundLabel.text = @"Disguise voice: OFF";
    }
}

- (void)publishStory {

    if (!_draftUrl) return;

    BOOL blurred = self.soundSwitch.isOn || self.filterSwitch.isOn;
    NSDictionary* params = @{@"source":@"camera", @"permission":@"public", @"blurred":@(blurred)};
    __weak MyStoryController* weakSelf = self;
    [Story publishVideo:_draftUrl
                orImage:self.camera.rawScreenshot
            withOverlay:nil
                 params:params
             completion:^(Story *newStory) {
                 weakSelf.user = newStory.user;
                 weakSelf.story = newStory;
                 [weakSelf.camera stopPreview];

                 if (weakSelf.shareSetting) {
                     [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/update", newStory.id]
                                    parameters:@{@"shareable_to":weakSelf.shareSetting}
                                      callback:^(NSSet *entities, id responseObject, NSError *error) {
                                          if (!error)
                                              weakSelf.shareSetting = nil;
                                      }];
                 }
             }];

    if (![[User me] registeredValue]) {
        AlertView* av = [[AlertView alloc] initWithTitle:@"Submitting Story.."
                                                 message:@"We strongly suggest you create an account. This will allow you to log-in and edit/change/delete your story in the future"
                                          andButtonArray:@[@"OK", @"Not Now"]];
        [av showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                self.needsShareSetting = YES;
                [self.meController openRegistration];
            }
            else if (!blurred) {
                SharePreferenceController* vc = [SharePreferenceController new];
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            }
        }];
    }
    else { // Already registered.
        if (!blurred) {
            SharePreferenceController* vc = [SharePreferenceController new];
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)sharePreferenceController:(SharePreferenceController*)controller didSelectPreference:(NSString*)sharePreference {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [[PNUserPreferences shared] setPreference:@"share_completed" boolValue:YES];
    if (self.story && sharePreference) {
        [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/update", self.story.id]
                       parameters:@{@"shareable_to":sharePreference}
                         callback:nil];
    }
    else
        self.shareSetting = sharePreference;
}

- (void)onShareSwitch {
    if (!self.shareSwitch.isOn)
        self.anywhereSwitch.on = NO;
    [self updateShareControls];
    [self updateApiShare];
}

- (void)onAnywhereSwitch {
    [self updateShareControls];
    [self updateApiShare];
}

- (NSString*)shareSettingForSwitches {
    if (self.shareSwitch.isOn && self.anywhereSwitch.isOn)
        return @"anywhere";
    else if (self.shareSwitch.isOn)
        return @"youtube";
    else
        return @"nowhere";
}

- (void)updateApiShare {
    [[PNUserPreferences shared] setPreference:@"share_completed" boolValue:YES];

    __block NSString* share = [self shareSettingForSwitches];
    __weak MyStoryController* weakSelf = self;

    // Wait 1.5s before updating API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[weakSelf shareSettingForSwitches] isEqualToString:share] && ![self.story.shareable_to isEqualToString:share]) {
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/update", self.story.id]
                           parameters:@{@"shareable_to":share}
                             callback:nil];
        }
    });
}

@end

