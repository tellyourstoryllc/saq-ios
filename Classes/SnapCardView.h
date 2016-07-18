//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkyMessage.h"
#import "Story.h"
#import "PillLabel.h"
#import "CalloutBubble.h"
#import "User.h"

@class SnapCardView;
@class VideoCardView;

@protocol CardViewDelegate <NSObject>
@optional
- (void)card:(SnapCardView*)card didLoadContent:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didFinishPresenting:(SkyMessage*)snap;

- (void)card:(SnapCardView*)card didSelectEdit:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didSelectReply:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didSelectExport:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didSelectDismiss:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didSelectLike:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didSelectFlag:(SkyMessage*)snap;

- (void)card:(SnapCardView*)card didRequestCardBefore:(SkyMessage*)snap;
- (void)card:(SnapCardView*)card didRequestCardAfter:(SkyMessage*)snap;

@end

@interface ContentCard : UIView
@property (nonatomic, weak) id<CardViewDelegate> delegate;
@property (nonatomic, strong) SkyMessage* message;
@property (nonatomic, readonly) SnapCardView* snapCard;
@property (nonatomic, assign) UIViewContentMode contentMode;

- (void)hideControls;
- (void)unhideControls;
- (void)loadContentWithCompletion:(void (^)())completion;

- (void)didAppear;
- (void)didDisappear;
- (void)messageWasUpdated;

- (void)didBecomeFeatured;
- (void)willResignFeatured;

- (void)onEdit;
- (void)onExport;
- (void)onLike;
- (void)onDismiss;

@end

@interface SnapCardView : UIView

@property (nonatomic, strong) SkyMessage* message;

@property (nonatomic, strong) PNButton* dismissButton;
@property (nonatomic, strong) PNButton* exportButton;
@property (nonatomic, strong) PNButton* editButton;
@property (nonatomic, strong) UIView* replyButton;
@property (nonatomic, strong) PNButton* likeButton;

@property (nonatomic, strong) PillLabel* usernameLabel;

@property (nonatomic, assign) ContentCard* card;
@property (nonatomic, weak) id<CardViewDelegate> delegate;
@property (nonatomic, assign) UIViewContentMode contentMode;

@property (nonatomic, strong) UIView* optionView;
@property (nonatomic, strong) PNButton* thanksButton;
@property (nonatomic, strong) PNButton* flagButton;

@property (nonatomic, assign) AVPlayer* videoPlayer;
@property (nonatomic, readonly) VideoCardView* video;

@property (nonatomic, assign) BOOL videoEnabled;
@property (nonatomic, assign) BOOL audioEnabled;

@property (nonatomic, assign) BOOL isAppearing;
@property (nonatomic, assign) BOOL isFeatured;
@property (nonatomic, assign) BOOL isPresentingOptions;

@property (nonatomic, assign) BOOL showDismissButton;
@property (nonatomic, assign) BOOL showEditButton;
@property (nonatomic, assign) BOOL showExportButton;
@property (nonatomic, assign) BOOL showLikeButton;
@property (nonatomic, assign) BOOL showReplyButton;
@property (nonatomic, assign) BOOL showUsername;
@property (nonatomic, assign) BOOL showActivityIndicator;

@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic, readonly) BOOL hasVideo;

@property (nonatomic, assign) CMTime shouldStartPlayingAtTime;

- (void)hideControls;
- (void)unhideControls;

- (void)loadContentWithCompletion:(void (^)())completion;
- (void)loadContent;

- (void)didAppear;
- (void)didDisappear;
- (void)messageWasUpdated;

- (void)didBecomeFeatured;
- (void)willResignFeatured;

- (void)didPresentOptions;
- (void)willResignOptions;

@end
