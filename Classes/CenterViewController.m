//
//  CameraViewController.m
//
//
//  Created by Jim Young on 2/25/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
#import "App.h"
#import "Story.h"
#import "CenterViewController.h"
#import "Directory.h"
#import "GraffitiView.h"
#import "PNVideoComposer.h"
#import "StatusView.h"
#import "GroupViewController.h"
#import "AFNetworking.h"
#import "PNProgress.h"
#import "PNUserPreferences.h"
#import "PNVideoCompressor.h"
#import "MediaOverlayView.h"
#import "AppViewController.h"

#import "TutorialBubble.h"
#import "PNFaceDetector.h"
#import "UIView+PostStoryAnimation.h"

@interface CenterCameraViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) MainCamera* camcorder;
@property (nonatomic, strong) Group* group;
@property (nonatomic, weak) CenterViewController* centerController;
@property (nonatomic, assign) BOOL isAppearing;

@end

@interface CenterViewController()
@property (nonatomic,strong) CenterCameraViewController* cameraController;
@end

@implementation CenterCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[AFNetworkReachabilityManager sharedManager] addObserver:self forKeyPath:@"reachable" options:NSKeyValueObservingOptionNew context:nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(blackColor);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCamcorder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self isViewVisible]) {
            [self.camcorder startPreview];
        }
    });

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateControlsOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    self.isAppearing = YES;
}

- (void)initCamcorder {
    if (!self.camcorder) {
        self.camcorder = [[MainCamera alloc] init];
        self.camcorder.carousel = self.centerController.mainController.carousel;
        [self.view insertSubview:self.camcorder atIndex:0];

        [self.camcorder.leftArrowButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriends)]];
        [self.camcorder.unreadMessages addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMessages)]];
        [self.camcorder.rightArrowButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMe)]];
        [self.camcorder.friendRequests addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriends)]];
        [self.camcorder.importButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImport)]];

        [self.camcorder.publishView.privateButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostPrivate)]];
        [self.camcorder.publishView.friendsButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostFriends)]];
        [self.camcorder.publishView.publicButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostPublic)]];

    }
    self.camcorder.controller = self;
    self.camcorder.pickerDelegate = self.centerController;
    self.camcorder.delegate = self.centerController;
    self.camcorder.frame = self.view.bounds; //CGRectMakeCorners(0, 20, b.size.width, b.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isAppearing = NO;
    if ([App isCrappyDevice])
        [self.camcorder stopPreview];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b = self.view.bounds;

    // Shitty hack:
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        self.camcorder.frame = CGRectMakeCorners(0, 64, b.size.width, b.size.height);
    }
    else {
        self.camcorder.frame = CGRectMakeCorners(0, 0, b.size.width, b.size.height);
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.view setNeedsLayout];
}

- (void)updateControlsOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGAffineTransform transform;

    if (orientation == UIDeviceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        transform = CGAffineTransformMakeRotation(M_PI);
    }
    else {
        transform = CGAffineTransformIdentity;
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.camcorder setTransformForControls:transform];
                     }];
}

- (void) didBecomeActive {
    if (self.camcorder) return;

    if (self.view.window) {
        [self initCamcorder];
        if (self.camcorder.isComposing)
            [self.camcorder restartVideoPlayback];
        else
            [self.camcorder startPreview];
    }
}

- (void) willEnterForeground {
    if (self.camcorder) return;

    if (self.view.window) {
        [self initCamcorder];
        if (self.camcorder.isComposing)
            [self.camcorder restartVideoPlayback];
        else
            [self.camcorder startPreview];
    }
}

- (void) didEnterBackground {
    if (!self.camcorder.isComposing) {
        self.camcorder.delegate = nil;
        [self.camcorder shutoffCamera];
        self.camcorder.pickerDelegate = nil;
        [self.camcorder removeFromSuperview];
        self.camcorder = nil;
    }
}

- (void) onMessages {
    [[AppViewController sharedAppViewController] openOverview];
}

- (void) onMe {
    [[AppViewController sharedAppViewController] openProfileForUser:[User me]];
}

- (void) onFriends {
    [[AppViewController sharedAppViewController] openFriends];
}

- (void) onImport {
    [self.camcorder stopPreview];
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self.centerController;
    picker.mediaTypes = @[(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie];
    [self.centerController presentViewController:picker animated:YES completion:nil];
}

// Allow deck to swipe if not swiping between filters.
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    CGPoint p = [gestureRecognizer locationInView:self.camcorder.swipeActivationView];
//    BOOL inside = CGRectContainsPoint(self.camcorder.swipeActivationView.bounds, p);
//    return !inside;
//}

// Post action handlers:

- (void)onPostPublic
{
    [TutorialConfirmation presentLesson:@"post_public"
                                  title:@"Public Story"
                                message:@"This story will be visible to anyone on KnowMe."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [self.camcorder publishWithParams:@{@"permission":@"public"}];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }
     ];
}

- (void) onPostFriends
{
    [TutorialConfirmation presentLesson:@"post_friends"
                                  title:@"Friends Only"
                                message:@"Only people you have added as a friend will be able to view this story."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [self.camcorder publishWithParams:@{@"permission":@"friends"}];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }
     ];
}

- (void) onPostPrivate
{
    [TutorialConfirmation presentLesson:@"post_private"
                                  title:@"Private Story"
                                message:@"Nobody but you will be able to see it unless you later change the permissions."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [self.camcorder publishWithParams:@{@"permission":@"private"}];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }
     ];
}

- (void) dealloc {
    [[AFNetworkReachabilityManager sharedManager] removeObserver:self forKeyPath:@"reachable"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.camcorder.delegate = nil;
    self.camcorder.pickerDelegate = nil;
}

@end

@implementation CenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(defaultBackgroundColor);
    if (!self.cameraController) {
        self.cameraController = [[CenterCameraViewController alloc] initWithNibName:nil bundle:nil];
        self.cameraController.centerController = self;
    }
    [self setCurrentViewController:self.cameraController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cameraController.camcorder.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)openCameraForGroup:(Group*)group withCompletion:(void (^)(BaseCamera*))completion {
    self.group = group;

    MainCamera* cam = (MainCamera*)self.cameraController.camcorder;

    cam.rightArrowButton.hidden = group ? YES : NO;

    __weak CenterViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCurrentViewController:self.cameraController
                            transition:UIViewAnimationOptionTransitionNone
                              duration:0.0
                        withAnimations:nil
                            completion:^(BOOL finished) {
                                [weakSelf setNeedsStatusBarAppearanceUpdate];
                                if (completion) completion(cam);
                            }];
    });
}

- (void)openGroup:(Group*)group {
    if (!group) return;

    // Don't interrupt recordings
    if (self.cameraController.camcorder.isRecording) return;

    [self.mainController openGroup:group];
}

- (void)openCamera {
    [self openCameraForGroup:nil withCompletion:nil];
}

- (void)openCameraWithCompletion:(void (^)(BaseCamera*))completion {
    [self openCameraForGroup:nil withCompletion:completion];
}

- (void)openCameraForGroup:(Group*)group {
    [self openCameraForGroup:group withCompletion:nil];
}

- (void)stopCamera {
    [self.cameraController.camcorder stopPreview];
}

# pragma mark CamcorderDelegate methods

- (void)camera:(PNCamera*)recorder
publishedImage:(UIImage *)image
      andVideo:(NSURL *)videoUrl
    withParams:(NSDictionary *)inputParams {

    BaseCamera* camcorder = (BaseCamera*)recorder;

    __block NSMutableDictionary* params = [inputParams mutableCopy];
    __block UIImage* overlay = camcorder.overlay;
    [params setValue:@"camera" forKey:@"source"];

    NSString* caption = camcorder.caption;
    if (caption.length)
        [params setValue:caption forKey:@"attachment_overlay_text"];

    [Story publishVideo:videoUrl
                orImage:image
            withOverlay:overlay
                 params:params
             completion:nil];

    [[[[AppViewController sharedAppViewController] mainController] carousel] setScrollEnabled:YES];

    [self.view animateStoryPostWithImage:image
                                 overlay:overlay
                              initiation:^{
                                  [self.cameraController.camcorder discard];
                              }
                              completion:nil];
}

- (void)cameraDidCancel:(id)recorder {
    if (self.group) {
        [self openGroup:self.group];
    }
    else {
        [[AppViewController sharedAppViewController] openOverview];
    }

    [self logAction:@"exit_camera"];
}

- (void)camera:(id)recorder didSnapshot:(UIImage*)screenshot {

// Snapshot was taken, but don't do anything. Wait for publish view gestures to
// trigger posting.

//    CGSize screensize = self.cameraController.camcorder.frame.size;
//
//    // Crop screenshot image to match what user sees on screen.
//    // But not if image is huge, or else we might run out of memory!
//    if (screensize.width < 1500 && screensize.height < 1500) {
//        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
//            screensize = CGSizeMake(screensize.height, screensize.width);
//        }
//        CGSize newSize = [UIImage sizeOfScalingSize:screensize toSize:screenshot.size];
//
//        vc.photo = [screenshot imageByScalingAspectFillToSize:newSize];
//    }
//    else {
//        vc.photo = screenshot;
//    }
//
//    [self presentViewController:vc animated:NO completion:nil];
}

- (void)camera:(id)recorder didRecord:(NSURL*)videoUrl {
    [recorder startVideoPlayback];
}

- (void)camera:(id)recorder didExceedMaxDuration:(CGFloat)duration {
    [StatusView showTitle:@"Time limit reached" message:nil completion:nil duration:3];
}

- (void)cameraDidFailToRecord:(id)recorder {
    [StatusView showTitle:@"Device not ready" message:@"Please try again!" completion:nil duration:3];
    [recorder startPreview];

    // Log it.
    NSString* logString = [NSString stringWithFormat:@"video_record_fail.%@", [PNSupport deviceName]];
    PNLOG(logString);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return (self.currentViewController == self.cameraController);
}

#pragma mark UIImagePickerControllerDelegate methods

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    NSURL* videoURL = info[UIImagePickerControllerMediaURL];

    NewMediaEditController* vc = [[NewMediaEditController alloc] init];
    vc.view.backgroundColor = COLOR(blackColor);
    vc.info = @{@"source":@"library"};

    [picker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:vc animated:YES completion:^{
            if (videoURL)
                vc.videoUrl = videoURL;
            else if (image)
                vc.photo = image;
        }];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// Log activity
- (void)logAction:(NSString*)action withParameters:(NSDictionary*)params {
    PNLOG(action);
}

- (void)logAction:(NSString*)action {
    [self logAction:action withParameters:nil];
}

- (void)dealloc {
    self.cameraController.camcorder.delegate = nil;
}

@end