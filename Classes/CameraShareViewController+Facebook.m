//
//  CameraShareViewController+Facebook.m
//
//
//  Created by Jim Young on 3/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CameraShareViewController+Facebook.h"
#import "CameraShareViewController+MediaInfo.h"
#import "PNFacebookAdapter.h"
#import "AlertView.h"
#import "StatusView.h"
#import "PNVideoCompressor.h"
#import "PNVideoComposer.h"
#import "MediaOverlayView.h"
#import "Api.h"
#import "PNBackgroundTaskElf.h"

@interface PublishFacebookView : PNView <UITextViewDelegate>

@property (nonatomic, strong) PNTextView* textView;
@property (nonatomic, strong) UIImage* screenshot;
@property (nonatomic, strong) PNButton* publishButton;
@property (nonatomic, strong) PNButton* cancelButton;
@property (nonatomic, copy) void(^completion)(BOOL cancelled);

- (void) showInView:(UIView*)view
     withCompletion:(void (^)(BOOL cancelled))completion;
- (void) dismiss;
@end

@implementation StoryShareViewController (Facebook)

- (void) publishToFacebook {

    [[PNFacebookAdapter shared]
     authorizeWithLogin:YES
     completion:^(BOOL authorized, NSError *error, PNFacebookAdapter *adapter) {

         if (authorized) {

             void (^fail)() = ^{ [AlertView showWithTitle:@"Upload Failed" andMessage:nil]; };

             PublishFacebookView* tv = [[PublishFacebookView alloc] init];

             void (^onSuccess)() = ^{
                 [self onSendSuccess];
                 if (self.info[@"forward_message_id"])
                     [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/export", self.info[@"forward_message_id"]]
                                    parameters:@{@"method":@"other"}
                                      callback:nil];
             };

             [tv showInView:self.view withCompletion:^(BOOL cancelled) {
                 [tv dismiss];
                 if (cancelled) {
                     [Logger log:@"share.facebook.cancel"];
                 }
                 else {

                     if ([self.delegate respondsToSelector:@selector(shareControllerWillFacebook:)])
                         [self.delegate shareControllerWillFacebook:self];

                     [PNBackgroundTaskElf doIt:^(PNBackgroundTaskElf *elf) {

                         if (self.videoURL) {
                             [self watermarkVideoUrl:self.videoURL
                                              preset:AVAssetExportPresetLowQuality
                                      withCompletion:^(NSURL *watermarkedVideoUrl, NSError *error) {

                                          [adapter postVideo:watermarkedVideoUrl
                                                       title:@""
                                                 description:tv.textView.text
                                              withCompletion:^(id result, NSError *error) {
                                                  if (error) {
                                                      NSLog(@"facebook fail.1");
                                                      fail();
                                                      [Logger log:@"share.facebook.video.fail"];
                                                  } else {
                                                      [StatusView showTitle:@"Finished" message:@"The video has been posted to Facebook." completion:nil duration:3.0];
                                                      [Logger log:@"share.facebook.video.success"];

                                                      // SUCCESS
                                                      onSuccess();
                                                  }
                                                  [elf doneIt];
                                              }];
                                      }];
                         }
                         else if (self.processedImage) {

                             UIImage* imageToPublish = [self imageByWatermarking:[self processedImage]];

                             [adapter postPhoto:imageToPublish
                                          title:@""
                                 withCompletion:^(id result, NSError *error) {
                                     if (error) {
                                         NSLog(@"facebook fail.2 %@", error);
                                         fail();
                                         [Logger log:@"share.facebook.image.fail"];
                                     } else {
                                         [StatusView showTitle:@"Finished" message:@"The photo has been posted to Facebook." completion:nil duration:3.0];
                                         [Logger log:@"share.facebook.image.success"];
                                         onSuccess();
                                     }
                                     [elf doneIt];
                                 }];
                         }
                     }];
                 }
             }];
         }
         else {
             [AlertView showWithTitle:@"Unable to access your Facebook"
                           andMessage:@"Make sure you are logged into Facebook and Settings app > Privacy > Facebook is enabled."];
             [Logger log:@"share.facebook.noauth"];
         }

     }]; // FB
}

@end

@implementation PublishFacebookView

- (void)showInView:(UIView *)view withCompletion:(void (^)(BOOL))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        _completion = completion;
        self.frame = CGRectSetBottomCenter(view.bounds.size.width/2, 0, self.frame); // Offscreen. Keyboard notifcation moves it onscreen.
        [view addSubview:self];
        [self.textView becomeFirstResponder];
        [view setNeedsDisplay];
    });
}

- (void) keyboardDidSomething {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect vr = [self.superview frameMinusKeyboard];
        self.frame = CGRectSetBottomCenter(vr.size.width/2, vr.size.height-10, self.frame);
    }];
}

- (id)init {
    if (self = [super init]) {
        self.textView = [[PNTextView alloc] initWithFrame:CGRectMake(0,0,280,100)];
        self.textView.font = [[Theme current] fontWithSize:18];
        self.textView.delegate = self;
        [self addChild:self.textView];

        self.publishButton = [[PNButton alloc] initWithFrame:CGRectMake(0,110,180,40)];
        self.publishButton.buttonColor = COLOR(facebookBlue);
        [self.publishButton setTitle:@"Post to Timeline" forState:UIControlStateNormal];
        [self.publishButton addTarget:self action:@selector(publishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.publishButton];

        self.cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(190,110,90,40)];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.cancelButton];

        self.alpha = 0.88;
        [self sizeToFit];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidSomething)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidSomething)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [Logger log:@"share.facebook.show"];
        
    }
    return self;
}

- (void)publishButtonTapped {
    if (self.completion) self.completion(NO);
}

- (void)cancelButtonTapped {
    if (self.completion) self.completion(YES);
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end