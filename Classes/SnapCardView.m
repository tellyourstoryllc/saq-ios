//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCardView.h"
#import "Story.h"

#import "PhotoCardView.h"
#import "VideoCardView.h"
#import "TextCardView.h"

#import "GroupManager.h"
#import "StoryManager.h"

@interface SnapCardView() {
    int _cachedHasImage;
    int _cachedHasVideo;
}

@property(nonatomic, retain) PhotoCardView* photoCard;
@property(nonatomic, retain) VideoCardView* videoCard;
@property(nonatomic, retain) TextCardView* textCard;
@end

@implementation SnapCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = COLOR(blackColor);
        self.videoEnabled = YES;
        self.audioEnabled = YES;
        self.delegate = nil;

        self.videoCard = [[VideoCardView alloc] initWithFrame:self.bounds];
        [self addSubview:self.videoCard];

        self.photoCard = [[PhotoCardView alloc] initWithFrame:self.bounds];
        [self addSubview:self.photoCard];

        self.textCard = [[TextCardView alloc] initWithFrame:self.bounds];
        [self addSubview:self.textCard];

        self.usernameLabel = [[PillLabel alloc] initWithFrame:CGRectZero];
        self.usernameLabel.leftCap = YES;
        self.usernameLabel.rightCap = NO;
        [self addSubview:self.usernameLabel];

        self.dismissButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        [self.dismissButton addTarget:self action:@selector(onDismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.dismissButton maskWithImage:[UIImage imageNamed:@"x"] inverted:YES];
        self.dismissButton.hidden = YES;
        self.dismissButton.buttonColor = [COLOR(whiteColor) colorWithAlphaComponent:0.4];
        [self addSubview:self.dismissButton];

        self.editButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.editButton.cornerRadius = 25;
        [self.editButton addTarget:self action:@selector(onEdit) forControlEvents:UIControlEventTouchUpInside];
        [self.editButton setImage:[UIImage tintedImageNamed:@"edit" color:COLOR(whiteColor)] forState:UIControlStateNormal];
        self.editButton.hidden = YES;
        self.editButton.buttonColor = [COLOR(blackColor) colorWithAlphaComponent:0.33];
        [self addSubview:self.editButton];

        CalloutBubble* reply = [[CalloutBubble alloc] initWithFrame:CGRectMake(0,0,50,50)];
        reply.bubbleColor = COLOR(purpleColor);
        [reply maskWithImage:[UIImage imageNamed:@"reply"] inverted:YES];
        reply.textLabel.textColor = COLOR(redColor);
        reply.textLabel.textAlignment = NSTextAlignmentCenter;
        reply.calloutPosition = CalloutBubblePositionBottom;
        reply.calloutOffset = 25;
        reply.alpha = 0.888f;
        reply.hidden = YES;
        self.replyButton = reply;
        [self addSubview:self.replyButton];
        UITapGestureRecognizer* tapReply = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReply)];
        [self.replyButton addGestureRecognizer:tapReply];

        self.exportButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
        [self.exportButton addTarget:self action:@selector(onExport) forControlEvents:UIControlEventTouchUpInside];
        [self.exportButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        self.exportButton.hidden = YES;
        [self addSubview:self.exportButton];

        CGRect b = self.bounds;
        self.screenView = [[UIView alloc] initWithFrame:b];
        self.screenView.backgroundColor = [COLOR(whiteColor) colorWithAlphaComponent:0.7];
        [self addSubview:self.screenView];

        self.optionView = [[UIView alloc] initWithFrame:CGRectSetOrigin(0, b.size.height, b)];
        self.optionView.userInteractionEnabled = YES;
        [self addSubview:self.optionView];

        self.thanksButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
        self.thanksButton.userInteractionEnabled = YES;
        self.thanksButton.titleLabel.font = FONT_B(14);
        self.thanksButton.cornerRadius = 10;
        self.thanksButton.selectedColor = [COLOR(greenColor) colorWithAlphaComponent:0.8];
        self.thanksButton.buttonColor = [COLOR(grayColor) colorWithAlphaComponent:0.8];
        [self.thanksButton setTitle:@"Say thanks" forState:UIControlStateNormal];
        [self.thanksButton setTitle:@"Thanked" forState:UIControlStateSelected];
        [self.thanksButton setTitleColor:COLOR(blackColor) forState:UIControlStateSelected];

        self.thanksButton.frame = CGRectSetBottomCenter(b.size.width/2, b.size.height-2, self.thanksButton.frame);
        [self.optionView addSubview:self.thanksButton];

        [self hideControls];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.usernameLabel];
    CGRect b = self.bounds;

    self.videoCard.frame = b;
    self.textCard.frame = b;
    self.photoCard.frame = b;

    NSString* name = [self.message.user displayName];
    if (self.showUsername && !self.message.user.isMe && name.length) {
        self.usernameLabel.text = name;

        self.usernameLabel.font = USERFONT(24);
        self.usernameLabel.insets = UIEdgeInsetsMake(4, 8, 4, 4);

        self.usernameLabel.pillColor = COLOR(blueColor);
        self.usernameLabel.textColor = COLOR(whiteColor);

        [self.usernameLabel sizeToFit];
        self.usernameLabel.frame = CGRectSetTopRight(self.frame.size.width, 4, self.usernameLabel.frame);
    }

    self.dismissButton.frame = CGRectSetOrigin(2,2, self.dismissButton.frame);
    self.editButton.frame = CGRectSetTopRight(b.size.width-2, 2, self.editButton.frame);
    self.replyButton.frame = CGRectSetBottomCenter(b.size.width/2, b.size.height-2, self.replyButton.frame);
    self.exportButton.frame = CGRectSetBottomLeft(2, b.size.height-2, self.exportButton.frame);
}

- (void)setMessage:(SkyMessage *)message {

    if (_message == message)
        return;

    [self.KVOController unobserve:_message];
    _message = message;
    [self.KVOController observe:message keyPaths:@[@"liked"]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              on_main(^{
                                  self.thanksButton.selected = self.message.likedValue;
                              });
                          }];

    self.card = nil;
    self.photoCard.message = nil;
    self.videoCard.message = nil;
    self.textCard.message = nil;

    on_main(^{
        self.photoCard.hidden = YES;
        self.videoCard.hidden = YES;
        self.textCard.hidden = YES;
        [self hideControls];
    });

    _cachedHasImage = 0;
    _cachedHasVideo = 0;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    [self.photoCard setContentMode:contentMode];
    [self.videoCard setContentMode:contentMode];
    [self.textCard setContentMode:contentMode];
}

- (void)updateContentWithFetch:(BOOL)fetchIfUnknown
                    completion:(void (^)())completion{

    ContentCard* oldCard = self.card;

    if (self.message.hasVideo) {
        self.photoCard.hidden = YES;
        self.videoCard.hidden = NO;
        self.textCard.hidden = YES;
        self.card = self.videoCard;
        _cachedHasVideo = 1;
    }
    else if (self.message.hasImage) {
        self.photoCard.hidden = NO;
        self.videoCard.hidden = YES;
        self.textCard.hidden = YES;
        self.card = self.photoCard;
        _cachedHasImage = 1;
    }
    else if (self.message.hasText) {
        self.photoCard.hidden = YES;
        self.videoCard.hidden = YES;
        self.textCard.hidden = NO;
        self.card = self.textCard;

    }
    else if (fetchIfUnknown) {
        __weak SnapCardView* weakSelf = self;
        SkyMessage* fetchedMessage = self.message;
        [fetchedMessage fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
            if (weakSelf.message == fetchedMessage) {
                on_main(^{
                    [weakSelf updateContentWithFetch:NO completion:completion];
                });
            }
        }];
        return;
    }
    else {
        NSLog(@"ERROR: message %@(%@) has no content", self.message.id, self.message.user.username);
        if (completion) completion();
        return;
    }

    self.card.message = self.message;
    self.card.delegate = self.delegate;
    self.thanksButton.selected = self.message.likedValue;

    [self.card loadContentWithCompletion:completion];

    if (self.card != oldCard) {
        if (self.isAppearing)
            [self.card didAppear];

        if (self.isFeatured)
            [self.card didBecomeFeatured];
    }
}

- (void)loadContentWithCompletion:(void (^)())completion {
    [self updateContentWithFetch:YES completion:completion];
}

- (void)loadContent {
    [self loadContentWithCompletion:nil];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.card setFrame:self.bounds];
}

- (void)hideControls {
    self.usernameLabel.hidden = YES;
    self.dismissButton.hidden = YES;
    self.editButton.hidden = YES;
    self.replyButton.hidden = YES;
    self.exportButton.hidden = YES;
    self.likeButton.hidden = YES;

    [self.videoCard hideControls];
    [self.photoCard hideControls];
    [self.textCard hideControls];
}

- (void)unhideControls {
    self.usernameLabel.hidden = !self.showUsername;
    self.dismissButton.hidden = !self.showDismissButton;
    self.editButton.hidden = !self.showEditButton;
    self.replyButton.hidden = !self.showReplyButton;
    self.exportButton.hidden = !self.showExportButton;
    self.likeButton.hidden = !self.showLikeButton;

    [self.videoCard unhideControls];
    [self.photoCard unhideControls];
    [self.textCard unhideControls];
}

- (void)didAppear {
    self.isAppearing = self.window ? YES : NO;
    [self loadContent];
    [self.card didAppear];
}

- (void)didDisappear {
    self.isAppearing = NO;
    [self.card didDisappear];
}

- (void)didBecomeFeatured {
    self.isFeatured = YES;
    CGRect b = self.bounds;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.screenView.frame = CGRectSetBottomLeft(0, 0, b);
                     } completion:^(BOOL finished) {
                     }];
    [self.card didBecomeFeatured];
}

- (void)willResignFeatured {
    [self.card willResignFeatured];
    self.isFeatured = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.screenView.frame = self.bounds;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)messageWasUpdated {
    [self.card messageWasUpdated];
}

- (void)setDelegate:(id<CardViewDelegate>)delegate {
    _delegate = delegate;
    self.textCard.delegate = delegate;
    self.videoCard.delegate = delegate;
    self.photoCard.delegate = delegate;
}

- (void)onExport {
    if ([self.delegate respondsToSelector:@selector(card:didSelectExport:)])
        [self.delegate card:self didSelectExport:self.message];
}

- (void)onEdit {
    if ([self.delegate respondsToSelector:@selector(card:didSelectEdit:)])
        [self.delegate card:self didSelectEdit:self.message];
}

- (void)onLike {
    if ([self.delegate respondsToSelector:@selector(card:didSelectLike:)])
        [self.delegate card:self didSelectLike:self.message];
}

- (void)onDismiss {
    if ([self.delegate respondsToSelector:@selector(card:didSelectDismiss:)])
        [self.delegate card:self didSelectDismiss:self.message];
}

- (void)onReply {
    if ([self.delegate respondsToSelector:@selector(card:didSelectReply:)])
        [self.delegate card:self didSelectReply:self.message];
}

- (BOOL)hasImage {
    if (!_cachedHasImage)
        _cachedHasImage = [self.message hasImage] ? 1 : -1;
    return _cachedHasImage > 0;
}

- (BOOL)hasVideo {
    if (!_cachedHasVideo)
        _cachedHasVideo = [self.message hasVideo] ? 1 : -1;
    return _cachedHasVideo > 0;
}

- (void)didPresentOptions {
    _isPresentingOptions = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.optionView.frame = self.bounds;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)willResignOptions {
    _isPresentingOptions = NO;
    CGRect b = self.bounds;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.optionView.frame = CGRectSetOrigin(0, b.size.height, b);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)dealloc {
    self.delegate = nil;
}

@end

@implementation ContentCard
- (void)loadContentWithCompletion:(void (^)())completion {
    if ([self.snapCard.delegate respondsToSelector:@selector(card:didLoadContent:)]) {
        [self.snapCard.delegate card:self.snapCard didLoadContent:self.message];
    }
    if (completion) completion();
}

- (void)hideControls {}
- (void)unhideControls {}
- (void)didAppear {}
- (void)didDisappear {}
- (void)messageWasUpdated {}
- (void)didBecomeFeatured {}
- (void)willResignFeatured {}

- (SnapCardView*) snapCard {
    return ([[self superview] isKindOfClass:[SnapCardView class]]) ? (SnapCardView*)[self superview] : nil;
};

- (void)onExport {
    [self.snapCard onExport];
}

- (void)onEdit {
    [self.snapCard onEdit];
}

- (void)onLike {
    [self.snapCard onLike];
}

- (void)onDismiss {
    [self.snapCard onDismiss];
}

- (void)dealloc {
    self.delegate = nil;
}

@end
