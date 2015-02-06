//
//  CameraShareViewController+Twitter.m
//
//
//  Created by Jim Young on 3/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CameraShareViewController+Twitter.h"
#import "CameraShareViewController+MediaInfo.h"
#import "Api.h"
#import "PNTwitterAdapter.h"
#import "AlertView.h"
#import "StatusView.h"
#import "PNVideoCompressor.h"
#import "PNVideoComposer.h"
#import "MediaOverlayView.h"

@interface PublishTwitterView : PNView <UITextViewDelegate>

@property (nonatomic, strong) PNTextView* textView;
@property (nonatomic, strong) UIImage* screenshot;
@property (nonatomic, strong) PNButton* publishButton;
@property (nonatomic, strong) PNButton* cancelButton;
@property (nonatomic, copy) void(^completion)(BOOL cancelled);

- (void) showInView:(UIView*)view
     withCompletion:(void (^)(BOOL cancelled))completion;
- (void) dismiss;

@end

@implementation StoryShareViewController (Twitter)

- (void) publishToTwitter {

    // A hairy async mess.
    // (1) auth twitter
    // (3) upload video to group
    // (4) post screenshot to twitter

    [[PNTwitterAdapter shared] authorizeWithCompletion:^(NSArray *accounts, NSError *error, PNTwitterAdapter *adapter) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (error) {
                [AlertView showWithTitle:@"Twitter Access Disabled" andMessage:@"Go to Settings app > Privacy > Twitter to enable access."];
                [Logger log:@"share.twitter.noauth"];
            }
            else if (accounts.count == 0) {
                [AlertView showWithTitle:@"No Twitter Accounts" andMessage:@"You are not signed into Twitter on this device."];
                [Logger log:@"share.twitter.noaccounts"];
            }
            else {

                PublishTwitterView* tv = [[PublishTwitterView alloc] init];
                [tv showInView:self.view withCompletion:^(BOOL cancelled) {
                    [tv dismiss];
                    if (!cancelled) {

                        NSMutableDictionary* newParams = [NSMutableDictionary dictionaryWithCapacity:4];
                        [newParams setObject:tv.textView.text forKey:@"caption"];

                        void (^onFail)() = ^{ [AlertView showWithTitle:@"Upload failed" andMessage:@"Oh no, something went wrong!"]; };

                        void (^onSuccess)() = ^{
                            [self onSendSuccess];
                            if (self.info[@"forward_message_id"])
                                [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/export", self.info[@"forward_message_id"]]
                                               parameters:@{@"method":@"other"}
                                                 callback:nil];
                        };

                        if ([self.delegate respondsToSelector:@selector(shareControllerWillTwitter:)])
                            [self.delegate shareControllerWillTwitter:self];

                        if (self.videoURL) {
                            // (3)

                            [self watermarkVideoUrl:self.videoURL
                                             preset:AVAssetExportPresetLowQuality
                                     withCompletion:^(NSURL *watermarkedVideoUrl, NSError *error) {

                                         if ([Configuration boolFor:@"tweet_image"] && self.previewImage) {
                                             NSString* tweet = [NSString stringWithFormat:@"%@", tv.textView.text];
                                             [self tweetText:tweet withImage:self.previewImage usingAdapter:adapter andCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                                                 if (!error)
                                                     onSuccess();
                                                 else
                                                     onFail();
                                             }];

                                         } else {
                                             NSString* tweet = [NSString stringWithFormat:@"%@", tv.textView.text];
                                             [self tweetText:tweet withImage:nil usingAdapter:adapter andCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                                                 if (!error)
                                                     onSuccess();
                                                 else
                                                     onFail();
                                             }];
                                         }
                                     }];
                        }
                        else if (self.processedImage) {

                            UIImage* imageToPublish = [self imageByWatermarking:[self processedImage]];

                            NSString* tweet = [NSString stringWithFormat:@"%@", tv.textView.text];
                            [self tweetText:tweet withImage:imageToPublish usingAdapter:adapter andCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                                if (!error)
                                    onSuccess();
                                else
                                    onFail();
                            }];
                        }
                    } else {
                        [Logger log:@"share.twitter.cancel"];
                    }
                }];
            }
        });
    }];
}

- (void)tweetText:(NSString*)text
        withImage:(UIImage*)image
     usingAdapter:(PNTwitterAdapter*)adapter
    andCompletion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {

    if (image) {
        [adapter tweetImage:image
                 withStatus:text
              andCompletion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                  if (error) {
                      [AlertView showWithTitle:@"Tweet Failed" andMessage:@"Oh no, something went wrong!"];
                      [Logger log:@"share.twitter.tweet_image.fail"];
                  } else {
                      [StatusView showTitle:@"Finished" message:nil completion:nil duration:1.5];
                      [Logger log:@"share.twitter.tweet_image.success"];
                  }
                  if (completion) completion (data, response, error);
              }];
    }
    else {
        [adapter tweet:text
            completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                if (error) {
                    [AlertView showWithTitle:@"Tweet Failed" andMessage:@"Oh no, something went wrong!"];
                    [Logger log:@"share.twitter.tweet_text.fail"];
                } else {
                    [StatusView showTitle:@"Finished" message:nil completion:nil duration:3.0];
                    [Logger log:@"share.twitter.tweet_text.success"];
                }
                if (completion) completion (data, response, error);
            }];
    }
}

@end

@implementation PublishTwitterView

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
        self.textView.font = FONT(18);
        self.textView.backgroundColor = COLOR(lightGrayColor);
        self.textView.delegate = self;
        [self addChild:self.textView];

        self.textView.text = @"";

        self.publishButton = [[PNButton alloc] initWithFrame:CGRectMake(0,110,180,40)];
        self.publishButton.buttonColor = COLOR(greenColor);
        [self.publishButton setTitle:@"Tweet" forState:UIControlStateNormal];
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
        
        [Logger log:@"share.twitter.show"];
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