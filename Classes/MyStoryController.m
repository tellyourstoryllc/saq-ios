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

@property (strong) PNLabel* soundLabel;
@property (strong) UISwitch* soundSwitch;

@property (strong) PNButton* discardButton;
@property (strong) PNButton* publishButton;

@property (strong) PNButton* storyPlayButton;
@property (strong) PNButton* cameraPlayButton;

@property (strong) UIButton* optionsButton;

@property (strong) PNVideoURLView* videoView;

@property (strong) PNRichLabel* instructionLabel;
@property (strong) PNLabel* thanksLabel;

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
    self.activateButton.buttonColor = COLOR(blackColor);
    self.activateButton.hidden = NO;
    [self.activateButton addTarget:self action:@selector(onOpenCamera) forControlEvents:UIControlEventTouchDown];
    self.activateButton.titleLabel.numberOfLines = 0;
    self.activateButton.titleLabel.font = FONT_B(14);
    self.activateButton.titleEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
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

    self.soundLabel = [PNLabel labelWithText:@"Voice distortion: OFF" andFont:FONT_B(14)];
    self.soundLabel.textAlignment = NSTextAlignmentCenter;
    [self.recorderView addSubview:self.soundLabel];

    self.soundSwitch = [UISwitch new];
    [self.recorderView addSubview:self.soundSwitch];
    [self.soundSwitch addTarget:self action:@selector(onSound) forControlEvents:UIControlEventValueChanged];

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

    self.instructionLabel = [[PNRichLabel alloc] init];
    self.instructionLabel.font = FONT_B(20);
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

    self.optionsButton = [UIButton new];
    [self.optionsButton setTitle:@"Options" forState:UIControlStateNormal];
    [self.optionsButton setTitleColor:COLOR(blackColor) forState:UIControlStateNormal];
    [self.optionsButton addTarget:self action:@selector(onOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.storyView addSubview:self.optionsButton];

    [self.KVOController observe:self.camera keyPath:@"isRecording" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [weakSelf configureView];
                          }];

    [self.KVOController observe:self.camera keyPath:@"isComposing" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [weakSelf configureView];
                          }];

    self.user = [[Api sharedApi] currentUser];

    [self.KVOController observe:[Api sharedApi]
                        keyPath:@"currentUser"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.user = [[Api sharedApi] currentUser];
                          }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreCamera)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        if (self.activateButton.hidden)
            [self.camera startPreview];
        else
            [self.activateButton setTitle:@"Activate camera ❭" forState:UIControlStateNormal];
    }
    else {
        [self.activateButton setTitle:@"Allow Access to Mic & Camera ❭" forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAllPlayback];
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

    [self.soundLabel sizeToFitTextWidth:CGRectGetMinX(self.activateButton.frame)-8];
    self.soundLabel.frame = CGRectSetOrigin(CGRectGetMaxX(self.activateButton.frame)+4, CGRectGetMinY(self.activateButton.frame), self.soundLabel.frame);
    self.soundSwitch.frame = CGRectSetTopCenter(CGRectGetMidX(self.soundLabel.frame), CGRectGetMaxY(self.soundLabel.frame)+4, self.soundSwitch.frame);

    // Place discard button at top right corner of video frame
    self.discardButton.frame = CGRectSetCenter(CGRectGetMaxX(self.activateButton.frame), CGRectGetMinY(self.activateButton.frame), self.discardButton.frame);

    self.publishButton.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.camera.frame), self.publishButton.frame);

    self.storyPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.videoView.frame),
                                               CGRectGetMaxY(self.videoView.frame)+10,
                                               self.storyPlayButton.frame);

    self.cameraPlayButton.frame = CGRectSetTopCenter(CGRectGetMidX(self.activateButton.frame),
                                                    CGRectGetMaxY(self.activateButton.frame)+10,
                                                    self.cameraPlayButton.frame);

    self.optionsButton.frame = CGRectMakeCorners(0, b.size.height-40, b.size.width, b.size.height);

    self.instructionLabel.frame = CGRectMakeCorners(4, CGRectGetMaxY(self.camera.frame), b.size.width-4, b.size.height);

    self.thanksLabel.frame = self.instructionLabel.frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];

    self.instructionLabel.text = @"1. Tell what happened<br><br>2. Tell how you got through it<br><br>3. No last names";
}

- (void)setUser:(User *)user {

    if ([_user isEqual:user]) return;

    void (^updateBlock)(User*) = ^(User* user) {
        Story* story = user.last_story;
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
    [self.KVOController observe:_user keyPaths:@[@"updated_at"]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              updateBlock(self.user);
                              if (!self.camera.isRecording && [self isViewVisible])
                                  [self.camera startPreview];
                          }];

    updateBlock(user);
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

    __weak MyStoryController* weakSelf = self;

    on_main(^{
        weakSelf.filterLabel.hidden = !weakSelf.camera.isRecording;
        weakSelf.filterSwitch.hidden = !weakSelf.camera.isRecording;
        weakSelf.soundLabel.hidden = !weakSelf.camera.isRecording;
        weakSelf.soundSwitch.hidden = !weakSelf.camera.isRecording;

        weakSelf.discardButton.hidden = !weakSelf.camera.isComposing;
        weakSelf.publishButton.hidden = !weakSelf.camera.isComposing;
        weakSelf.cameraPlayButton.hidden = !weakSelf.camera.isComposing;

        weakSelf.instructionLabel.hidden = weakSelf.camera.isComposing;

        weakSelf.optionsButton.hidden = weakSelf.videoView.videoUrl == nil;

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

- (void)stopAllPlayback {
    [self.camera pauseVideoPlayback];
    [self.videoView stop];
    self.storyPlayButton.selected = NO;
    self.cameraPlayButton.selected = NO;
}

- (void)restoreCamera {
    if (!self.camera.isComposing)
        [self.camera startPreview];
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
        self.filterLabel.text = @"Anonymity filter: ON";

    }
    else {
        self.camera.currentFilterIndex = 0;
        self.filterLabel.text = @"Anonymity filter: OFF";
    }
}

- (void)onSound {
    if (self.soundSwitch.isOn) {
        self.camera.filteredAudio = YES;
        self.soundLabel.text = @"Voice distortion: ON";

    }
    else {
        self.camera.filteredAudio = NO;
        self.soundLabel.text = @"Voice distortion: OFF";
    }
}

- (void)onOptions {
    [self showOptions];
}

- (void)publishStory {
    if (!_draftUrl) return;

    NSDictionary* params = @{@"source":@"camera", @"permission":@"public"};
    [Story publishVideo:_draftUrl
                orImage:self.camera.rawScreenshot
            withOverlay:nil
                 params:params
             completion:^(Story *newStory) {
                 self.user = newStory.user;
                 [self.camera stopPreview];
             }];

    [self.meController openRegistration];

}

- (void)showOptions {
    PNActionSheet* as =
    [[PNActionSheet alloc] initWithTitle:nil
                              completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                  if (buttonIndex == 0)
                                      [self onDelete];
                                  NSLog(@"%d",buttonIndex);
                              }
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                        otherButtonArray:@[@"Delete My Story"]];
    [as showInView:self.view];
}

- (void)onDelete {
    Story* story = [[User me] last_story];
    if (!story.id) {
        NSLog(@"cannot delete! %@", story);
        return;
    }

    PNActionSheet* as =
    [[PNActionSheet alloc] initWithTitle:@"You cannot undo this action. Confirm?"
                              completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                  if (buttonIndex == 0) {
                                      [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/delete", story.id]
                                                     parameters:nil
                                                       callback:^(NSSet *entities, id responseObject, NSError *error) {
                                                           User* me = [[Api sharedApi] currentUser];
                                                           [me.managedObjectContext performBlock:^{
                                                               Story* story = me.last_story;
                                                               story.deletedValue = YES;
                                                               me.last_story = nil;
                                                               me.updated_at = [NSDate date];
                                                               [me.managedObjectContext saveToRootWithCompletion:^(BOOL success, NSError *err) {
                                                                   self.user = me;
                                                               }];
                                                           }];
                                                       }];
                                  }
                              }
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                        otherButtonArray:@[@"Yes, delete permanently"]];
    [as showInView:self.view];
}

@end

