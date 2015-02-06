//
//  MessageCollectionCell.m
//  NoMe
//
//  Created by Jim Young on 1/12/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "MessageCollectionCell.h"
#import "GroupManager.h"

#import "GraphicsSettingsCell.h"
#import "UIImage+PixellatedTransition.h"

@interface MessageCollectionCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) PNButton* clearButton;
@property (nonatomic, strong) PNLabel* usernameLabel;
@property (nonatomic, assign) BOOL cardWasFeatured;

@end

@implementation MessageCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.card.contentMode = UIViewContentModeScaleAspectFill;
        self.card.clipsToBounds = YES;
        
        self.usernameLabel = [[PNLabel alloc] initWithFrame:self.contentView.bounds];
        self.usernameLabel.textAlignment = NSTextAlignmentCenter;
        self.usernameLabel.transform = CGAffineTransformMakeRotation(-M_PI/3.f);
        self.usernameLabel.font = USERFONT(18);
        [self.contentView addSubview:self.usernameLabel];

        CGFloat buttonDim = self.bounds.size.height;
        self.clearButton = [[PNButton alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, buttonDim, buttonDim)];
        self.clearButton.hidden = YES;
        self.clearButton.buttonColor = COLOR(redColor);
        [self.clearButton setImage:[UIImage tintedImageNamed:@"trash" color:COLOR(whiteColor)] forState:UIControlStateNormal];
        UITapGestureRecognizer* clear = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClear:)];
        [self.clearButton addGestureRecognizer:clear];
        [self.contentView addSubview:self.clearButton];

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];

        UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
        swipe.delegate = self;
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipe];

        [[GroupManager manager] addObserver:self forKeyPath:@"unreadCount"
                                    options:NSKeyValueObservingOptionNew
                                    context:nil];
    }

    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setGroup:(Group *)group {
    if (_group == group) return;

    [_group removeObserver:self forKeyPath:@"last_nonmeta_message"];
    _group = group;
    [_group addObserver:self forKeyPath:@"last_nonmeta_message" options:NSKeyValueObservingOptionNew context:nil];

    _snap = group.lastNonMetaMessage;
    self.card.message = self.snap;
    self.card.userInteractionEnabled = NO;
    [self.card hideControls];

    [self.card loadContentWithCompletion:nil];

    self.usernameLabel.text = group.other_user.displayName;
    self.usernameLabel.textColor = _snap.isNew ? COLOR(redColor) : COLOR(whiteColor);
}

- (void)didTap:(UIGestureRecognizer*)gesture
{
    if (!self.clearButton.hidden)
        [self setClearButtonHidden:YES];
    else
        [self.delegate messageCell:self didOpen:self.group];
}

- (void)didSwipe:(UIGestureRecognizer*)gesture
{
    [self setClearButtonHidden:NO];
}

- (void)didClear:(UIGestureRecognizer*)gesture
{
    [self.delegate messageCell:self didClear:self.group];
}

- (void)setClearButtonHidden:(BOOL)hidden
{
    self.clearButton.hidden = NO;

    [UIView animateWithDuration:0.3
                     animations:^{
                         if (hidden) {
                             self.clearButton.frame = CGRectSetOrigin(self.bounds.size.width, 0, self.clearButton.frame);
                         }
                         else {
                             self.clearButton.frame = CGRectSetTopRight(self.bounds.size.width, 0, self.clearButton.frame);
                         }
                     }
                     completion:^(BOOL finished) {
                         self.clearButton.hidden = hidden;
                     }];
}

- (BOOL)endEditing:(BOOL)force {
    [self setClearButtonHidden:YES];
    return [super endEditing:force];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.group = nil;
    [self.card hideControls];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.usernameLabel.textColor = _snap.isNew ? COLOR(redColor) : COLOR(whiteColor);
    if ([keyPath isEqualToString:@"last_nonmeta_message"]) {
        _snap = _group.lastNonMetaMessage;
        self.card.message = self.snap;
        [self.card loadContent];
    }
}

- (void)dealloc {
    [self prepareForReuse];
    [[GroupManager manager] removeObserver:self forKeyPath:@"unreadCount"];
}

@end
