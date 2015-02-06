//
//  StoryImageDoodleController.m
//  NoMe
//
//  Created by Jim Young on 12/3/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "NewMediaEditController.h"
#import "Story.h"
#import "StoryPublishView.h"
#import "PNFaceDetector.h"
#import "PNVideoCompressor.h"
#import "UIView+PostStoryAnimation.h"

@interface NewMediaEditController ()

@property (nonatomic, strong) StoryPublishView* publishView;

@end

@implementation NewMediaEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    self.publishView = [StoryPublishView new];
    [self.publishView sizeToFit];
    [self.view addSubview:self.publishView];

    [self.publishView.privateButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostPrivate)]];
    [self.publishView.friendsButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostFriends)]];
    [self.publishView.publicButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPostPublic)]];

    self.cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(10,10,50,50)];
    self.cancelButton.buttonColor = COLOR(darkGrayColor);
    [self.cancelButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    [self.cancelButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel)]];
    [self.view addSubview:self.cancelButton];

    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect publishViewFrame = [self.view frameMinusKeyboard];
    self.publishView.frame = CGRectSetBottomCenter(self.view.bounds.size.width/2, publishViewFrame.size.height-10, self.publishView.frame);
}

- (void) didBeginEditing {
    self.publishView.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void) didEndEditing {
    self.publishView.hidden = NO;
    self.cancelButton.hidden = NO;
}

- (void) onPostPrivate {
    __weak NewMediaEditController* weakSelf = self;
    [TutorialConfirmation presentLesson:@"post_private"
                                  title:@"Save Private Story?"
                                message:@"Nobody but you will be able to see it unless you later change the permissions."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [weakSelf onPostWithPermission:@"private"];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }];
}

- (void) onPostFriends {
    __weak NewMediaEditController* weakSelf = self;
    [TutorialConfirmation presentLesson:@"post_friends"
                                  title:@"Save Friends Only Story?"
                                message:@"Only people you have added as a friend will be able to view this story."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [weakSelf onPostWithPermission:@"friends"];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }];
}

- (void) onPostPublic {
    __weak NewMediaEditController* weakSelf = self;
    [TutorialConfirmation presentLesson:@"post_public"
                                  title:@"Save Public Story?"
                                message:@"This story will be visible to anyone on KnowMe."
                      cancelButtonTitle:@"Cancel"
                                   onOk:^(TutorialConfirmation *tut) {
                                       [weakSelf onPostWithPermission:@"public"];
                                   }
                               onCancel:^(TutorialConfirmation *tut) {
                                   [tut markCompleted];
                               }];
}

- (void) onPostWithPermission:(NSString*)permission {

    __block NSMutableDictionary* params = [@{@"permission":permission, @"source":self.info[@"source"]} mutableCopy];

    NSMutableDictionary* metadata = [self.info mutableCopy];
    [metadata removeObjectsForKeys:@[@"source"]];
    params[@"attachment_metadata"] = metadata;

    if (self.caption)
        [params setValue:self.caption forKey:@"attachment_overlay_text"];

    [Story publishVideo:self.videoUrl
                orImage:self.photo
            withOverlay:self.compositeOverlay
                 params:params
             completion:nil];

    [self.view.window animateStoryPostWithImage:self.photo
                                        overlay:self.compositeOverlay
                                     initiation:^{
                                         [self.videoView stop];
                                         [self dismissViewControllerAnimated:NO completion:nil];
                                     }
                                     completion:nil];

    return;

    NSMutableDictionary* newInfo = [self.info mutableCopy] ?: [NSMutableDictionary new];
    NSString* graffitiText = self.graffitiView.textString ?: @"";
    [newInfo setObject:graffitiText forKey:@"text"];

    // ??
}

- (void) onCancel {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
