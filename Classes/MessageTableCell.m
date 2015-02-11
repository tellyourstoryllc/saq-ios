//
//  ConverstaionTableViewCell.m
//  peanut
//
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.

#import <MediaPlayer/MediaPlayer.h>

#import "MessageTableCell.h"
#import "SkyMessage.h"
#import "User.h"
#import "App.h"
#import "UIImageView+WebCache.h"
#import "Theme.h"
#import "Emoticon.h"
#import "GroupChatBubble.h"
#import "PNUserPreferences.h"
#import "GraphicsSettingsCell.h"
#import "StatusView.h"

#define kConversationMessageTableCellMessageWidth UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 400.0 : 250.0
#define kConversationMessageTableCellImageSize CGSizeMake(kConversationMessageTableCellMessageWidth, kConversationMessageTableCellMessageWidth)

const struct MarginSizes MarginSizes = {
    .small = 2.0,
    .regular = 5.0,
    .large = 7.0
};

static NSDateFormatter *friendlyFormatter = nil;

@interface MessageTableCell()
@property (nonatomic, strong) SnapCardView* card;
//@property (nonatomic, strong) TutorialBubble* replyTutorial;
@end

@implementation MessageTableCell

+ (CGFloat) heightForMessage:(SkyMessage*) message
                withMaxWidth:(CGFloat) width
         andTimestampEnabled:(BOOL)enableTimestamp {

    CGSize bubbleSize = message.isMeta ? [MetaMessageView sizeForMessage:message maxWidth:width] : [GroupChatBubble sizeForMessage:message maxWidth:width];
    CGFloat height = bubbleSize.height;

    if (enableTimestamp)
        height += kMessageTimeLabelHeight;

    if (!message.user.isMe && !message.group.isOneToOneValue)
        height += kMessageNameLabelHeight;

    if (message.hasAttachment && !message.user.isMe && message.attachmentInfo) {
        NSString* creatorName = message.attachmentInfo[@"author"];
        if (creatorName && ![creatorName isEqualToString:message.user.name]) {
            height += kMessageAttachmentLabelHeight;
        }
    }

    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            friendlyFormatter = [[NSDateFormatter alloc] init];
            [friendlyFormatter setDoesRelativeDateFormatting:YES];
            [friendlyFormatter setTimeStyle:NSDateFormatterShortStyle];
            [friendlyFormatter setDateStyle:NSDateFormatterMediumStyle];
            [friendlyFormatter setLocale:[NSLocale currentLocale]];
        });

        self.backgroundColor = [UIColor clearColor];

        self.chatBubble = [[GroupChatBubble alloc] init];
        [self.chatBubble.textLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelTapped:)]];

        self.nameLabel = [[PNLabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = FONT_B(13);
        self.nameLabel.textColor = COLOR(whiteColor);

        self.attachmentLabel = [[PNLabel alloc] init];
        self.attachmentLabel.backgroundColor = [UIColor clearColor];
        self.attachmentLabel.font = FONT(12);
        self.attachmentLabel.textColor = COLOR(darkGrayColor);

        self.timeLabel = [[PillLabel alloc] init];
        self.timeLabel.numberOfLines = 1;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.pillColor = COLOR(grayColor);
        self.timeLabel.leftCap = YES;
        self.timeLabel.rightCap = YES;

        self.chatBubbleLabel = [[PNLabel alloc] init];
        self.chatBubbleLabel.font = FONT(13);
        self.chatBubbleLabel.textColor = COLOR(whiteColor);

        self.metaView = [[MetaMessageView alloc] init];

        [self.contentView addSubview:self.chatBubble];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.attachmentLabel];
        [self.contentView addSubview:self.chatBubbleLabel];
        [self.contentView addSubview:self.metaView];

        // Gesture for viewing attachment
        UISwipeGestureRecognizer* swipey = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentSwiped:)];
        swipey.direction = UISwipeGestureRecognizerDirectionLeft;
        swipey.delegate = self;
        [self addGestureRecognizer:swipey];

        UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] init];
        [gest addTarget:self action:@selector(attachmentTapped:)];
        [self addGestureRecognizer:gest];

        UILongPressGestureRecognizer* press = [[UILongPressGestureRecognizer alloc] init];
        [press setMinimumPressDuration:0.5];
        [press addTarget:self action:@selector(bubblePressed:)];
        [self.chatBubble addGestureRecognizer:press];

    }
    return self;
}

- (void)layoutSubviews {

    CGFloat avatarWidth = self.showAvatar ? 45 : 0;

    [super layoutSubviews];
    CGRect b = self.contentView.bounds;
    CGFloat curY = 0;

    if (self.showTimestamp && self.timeLabel.text.length) {
        [self.timeLabel sizeToFit];
        self.timeLabel.frame = CGRectInset(self.timeLabel.frame, -5, -2);
        self.timeLabel.frame = CGRectSetTopCenter(b.size.width/2, 0, self.timeLabel.frame);
        curY = CGRectGetMaxY(self.timeLabel.frame);
    }
    else
        self.timeLabel.frame = CGRectZero;

    if (!self.message.user.isMe && self.nameLabel.text.length) {
        [self.nameLabel sizeToFit];
        self.nameLabel.frame = CGRectSetOrigin(avatarWidth + 16, curY, self.nameLabel.frame);
        curY = CGRectGetMaxY(self.nameLabel.frame);
    }
    else
        self.nameLabel.frame = CGRectZero;

    CGFloat bubbleX = 4;
    CGSize bubbleSize = [GroupChatBubble sizeForMessage:self.message maxWidth:b.size.width-avatarWidth];
    self.chatBubble.frame = CGRectMake(bubbleX, curY, bubbleSize.width, bubbleSize.height);

    if (self.message.user.isMe) {
        self.chatBubble.frame = CGRectSetTopRight(b.size.width-4, curY, self.chatBubble.frame);
        self.chatBubbleLabel.frame = CGRectZero;
    }
    else {
        self.chatBubbleLabel.transform = CGAffineTransformIdentity;
        [self.chatBubbleLabel sizeToFitTextWidth:bubbleSize.height]; // <--chat bubble label is rotated 90 degrees
        self.chatBubbleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.chatBubbleLabel.frame = CGRectSetOrigin(CGRectGetMaxX(self.chatBubble.frame), CGRectGetMinY(self.chatBubble.frame)+10, self.chatBubbleLabel.frame);
    }

    if (self.attachmentLabel.text.length) {
        [self.attachmentLabel sizeToFit];
        self.attachmentLabel.frame = CGRectSetOrigin(bubbleX+8, CGRectGetMaxY(self.chatBubble.frame), self.attachmentLabel.frame);
    }
    
    self.metaView.frame = CGRectMakeCorners(0, curY, b.size.width, b.size.height);
}

- (void)prepareForReuse {
    self.message = nil;
    self.card = nil;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    //  self.bubbleView.highlighted = highlighted;
}

#pragma mark - Setters / Getters

- (void)setMessage:(SkyMessage *)message {
    _message = message;

    if (self.message.transmission_failedValue) {
        self.contentView.alpha = 0.5;

    } else if (!self.message.user.isMe && (self.message.rankValue > self.message.group.last_seen_rankValue || !self.message.group.last_seen_rank)) {
        self.contentView.alpha = 1;

    } else {
        self.contentView.backgroundColor = nil;
        self.contentView.alpha = self.message.is_placeholderValue ? 0.888 : 1;
        [self.chatBubble.layer removeAllAnimations];
    }

    NSString *time = [friendlyFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.created_at.timeIntervalSince1970]];
    self.timeLabel.attributedText = [[NSAttributedString alloc]
                                     initWithString:time
                                     attributes:@{
                                                  NSFontAttributeName : FONT(12),
                                                  NSForegroundColorAttributeName : COLOR(whiteColor)
                                                  }];

    self.chatBubble.message = message;
    self.chatBubble.hidden = !message.hasAttachment && !message.hasText;

    if (!self.message.group.isOneToOneValue)
        self.nameLabel.text = message.user.displayName;

    self.chatBubbleLabel.text = nil;

    self.attachmentLabel.text = nil;
    if (self.message.hasAttachment && !self.message.user.isMe && self.message.attachmentInfo) {
        NSString* creatorName = self.message.attachmentInfo[@"author"];
        NSString* source = self.message.attachmentInfo[@"source"];
        if (creatorName && ![creatorName isEqualToString:self.message.user.name]) {
            if ([source isEqualToString:@"camera"])
                self.attachmentLabel.text = [NSString stringWithFormat:@"Snapped by %@", creatorName];
            else if ([source isEqualToString:@"library"])
                self.attachmentLabel.text = [NSString stringWithFormat:@"Uploaded from library by %@", creatorName];
        }
    }

    [message fetchVideoWithCompletion:nil];

    self.metaView.message = message;
    self.metaView.hidden = !message.isMeta;

    [self setNeedsLayout];
}

- (void)textLabelTapped:(UIGestureRecognizer*)tapped {
    if(!self.message.link_url || tapped.state != UIGestureRecognizerStateEnded)
        return;

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.message.link_url]];
}

#pragma mark Viewing media

- (void)attachmentSwiped:(UIGestureRecognizer*)gesture
{
    if (!self.editingAccessoryView) {
        CGFloat dim = 60;
        PNButton* deleteButton = [[PNButton alloc] initWithFrame:CGRectMake(0, 0, dim, dim)];
        [deleteButton setImage:[UIImage tintedImageNamed:@"trash" color:COLOR(whiteColor)] forState:UIControlStateNormal];
        deleteButton.buttonColor = COLOR(redColor);
        [deleteButton setTappedBlock:^{
            NSLog(@"DELETE ME!");
        }];
        [self setEditingAccessoryView:deleteButton];
    }

    [self setEditing:YES animated:YES];
}

- (void)attachmentTapped:(UIGestureRecognizer*)gesture
{
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
    }
    else {
//        if (gesture.state == UIGestureRecognizerStateEnded) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAttachmentForCell:)]) {
                [self.delegate didSelectAttachmentForCell:self];
            }
//        }
    }
}

- (void)bubblePressed:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan && self.message.text.length) {
        [[UIPasteboard generalPasteboard] setString:self.message.text];
        [StatusView showTitle:nil message:@"Copied text to clipboard" completion:nil duration:1.0];
    }

    if (self.message.hasImage || self.message.hasVideo) {

        if (!self.card) {
            self.card = [[SnapCardView alloc] initWithFrame:self.window.bounds];
            self.card.message = self.message;
            [self.card loadContent];
        }

        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self.window addSubview:self.card];
            [self.card didBecomeFeatured];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded) {
            [self.card willResignFeatured];
            [self.card removeFromSuperview];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
