//
//  ChatBubble.m
//
//
//  Created by Jim Young on 3/5/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ChatBubble.h"
#import "UIImageView+WebCache.h"
#import "PNUserPreferences.h"
#import "GraphicsSettingsCell.h"
#import "UIImage+Mask.h"

#define kConversationAudioPlaceholderWidth 140
#define kConversationAudioPlaceholderHeight 44

#define kChatBubbleMaxImageWidth 300
#define kChatBubbleMaxImageHeight 400
#define kChatBubbleMinHeight 36

#define kChatBubbleTextHorizontalPadding 6
#define kChatBubbleTextVerticalPadding 4

@interface ChatBubble()
@property (nonatomic, strong) NSString* currentAnimation;
@end

@implementation ChatBubble

+(UIImage*)leftBubbleImageWithColor:(UIColor*)color {
    UIImage* mask = [UIImage imageNamed:@"left-bubble-mask"];
    CGRect rect = CGRectMake(0, 0, mask.size.width, mask.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, mask.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIRectFill(rect);
    [mask drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [result resizableImageWithCapInsets:UIEdgeInsetsMake(28, 8, 4, 4)];
}

+(UIImage*)rightBubbleImageWithColor:(UIColor*)color {
    UIImage* mask = [UIImage imageNamed:@"right-bubble-mask"];
    CGRect rect = CGRectMake(0, 0, mask.size.width, mask.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, mask.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIRectFill(rect);
    [mask drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [result resizableImageWithCapInsets:UIEdgeInsetsMake(28, 4, 4, 8)];
}

+(UIImage*)leftBubbleImage {
    static UIImage *image;
    if(!image)
        image = [self leftBubbleImageWithColor:COLOR(blueColor)];
    return image;
}

+(UIImage*)rightBubbleImage {
    static UIImage *image;
    if(!image)
        image = [self rightBubbleImageWithColor:COLOR(orangeColor)];
    return image;
}

+ (CGSize) sizeForAttachmentPreview:(SkyMessage*)message
                            maxSize:(CGSize)size {
    if(!message.hasAttachment)
        return CGSizeZero;

    if (message.hasAudio)
        return CGSizeMake(kConversationAudioPlaceholderWidth, kConversationAudioPlaceholderHeight);

    int w = message.attachment_preview_widthValue;
    int h = message.attachment_preview_heightValue;
    if(w == 0 || h == 0)
        return CGSizeZero;

    int width = size.width;

    double aspect = w / (double) h;
    int height = MIN(width/aspect, size.height);

    return CGSizeMake(round(height * aspect), height);
}

+ (CGSize) sizeForMessage:(SkyMessage*)message
                 maxWidth:(CGFloat)maxWidth {
    return [self sizeForMessage:message maxWidth:maxWidth maxHeight:MAXFLOAT];
}

+ (CGSize) sizeForMessage:(SkyMessage*)message
                 maxWidth:(CGFloat)maxWidth
                maxHeight:(CGFloat)maxHeight {

    static UIImage *image;
    if (!image) image = [self leftBubbleImage];
    UIEdgeInsets caps = image.capInsets;

    CGFloat contentWidth = maxWidth - caps.left - caps.right - 2*kChatBubbleTextHorizontalPadding;
    CGFloat contentHeight = maxHeight - 2*caps.bottom - 2*kChatBubbleTextVerticalPadding;
    CGSize maxTextSize = CGSizeMake(contentWidth, contentHeight);
    CGRect textBoundingRect = [message.attributedText boundingRectWithSize:maxTextSize
                                                             options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGRect textSize = CGRectInset(textBoundingRect, -1*kChatBubbleTextHorizontalPadding, -1*kChatBubbleTextVerticalPadding-0.23*textBoundingRect.size.height); // the extra 0.23 is fudge factor.

    CGFloat maxImageWidth = MIN(maxWidth, kChatBubbleMaxImageWidth);
    CGFloat maxImageHeight = MIN(maxHeight, kChatBubbleMaxImageHeight);
    CGSize attachmentSize = [self.class sizeForAttachmentPreview:message
                                                         maxSize:CGSizeMake(maxImageWidth,maxImageHeight)];

    CGFloat bubbleWidth = MAX(textSize.size.width, attachmentSize.width);
    CGFloat bubbleHeight = textSize.size.height + attachmentSize.height;
    if (message.hasText && message.hasAttachment) bubbleHeight += 4;
    bubbleHeight = MAX(bubbleHeight, kChatBubbleMinHeight);
    bubbleHeight = MIN(bubbleHeight, maxHeight);

    CGRect bubbleFrame = CGRectInset(CGRectMake(0, 0, bubbleWidth, bubbleHeight),
                                             -0.5*(caps.left+caps.right),
                                             -1*caps.bottom);
    return bubbleFrame.size;
}

- (CGSize) preferredSize {
    CGSize pref = [self.class sizeForMessage:self.message maxWidth:self.maxWidth maxHeight:self.maxHeight];
    return pref;
}

- (CGSize) sizeThatFits:(CGSize)size {
    CGRect r1 = CGRectMake(0,0,size.width,size.height);
    CGSize pref = [self preferredSize];
    CGRect r2 = CGRectMake(0,0,pref.width,pref.height);
    return CGRectIntersection(r1, r2).size;
}

- (void)setMessage:(SkyMessage *)message {

    _message = message;
    self.bubbleImageView.image = message.user.isMe ? [self.class rightBubbleImage] : [self.class leftBubbleImage];
    self.textLabel.attributedText = message.attributedText;
    self.attachmentOverlay.hidden = !self.message.hasVideo;

    if (message.hasVideo || message.hasImage) {
        self.snapCard.message = message;
        [self.snapCard loadContent];
        [self.snapCard didAppear];
        self.snapCard.hidden = NO;

        BOOL showVideoPreview = [[PNUserPreferences shared] boolPreference:kShowAnimatedVideoPrefKey orDefault:YES];
        if (showVideoPreview)
            [self.snapCard didBecomeFeatured];

    }
    else {
        self.attachmentImage.image = nil;
        self.snapCard.message = nil;
        self.snapCard.hidden = YES;
    }
    [self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.snapCard = [[SnapCardView alloc] init];
        self.snapCard.layer.masksToBounds = YES;
        self.snapCard.userInteractionEnabled = NO;  // <-- need to disable card's gesture recognizers.
        self.snapCard.audioEnabled = NO;

        self.bubbleImageView = [[UIImageView alloc] init];

        self.attachmentOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.attachmentOverlay.contentMode = UIViewContentModeCenter;
        self.attachmentOverlay.image = [UIImage imageNamed:@"play-icon"];
        self.attachmentOverlay.clipsToBounds = YES;
        self.attachmentOverlay.layer.cornerRadius = 25;
        self.attachmentOverlay.backgroundColor = COLOR_ALPHA(darkGrayColor, 0.5);

        self.textLabel = [[UILabel alloc] init];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = COLOR(blackColor);
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.userInteractionEnabled = NO;

        self.maxWidth = 250;
        self.maxHeight = MAXFLOAT;
        
        [self addSubview:self.bubbleImageView];
        [self addSubview:self.snapCard];
        [self addSubview:self.attachmentOverlay];
        [self addSubview:self.textLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;

    CGFloat maxImageWidth = MIN(self.maxWidth, kChatBubbleMaxImageWidth);
    CGFloat maxImageHeight = MIN(self.maxHeight, kChatBubbleMaxImageHeight);
    CGSize attachmentSize = [self.class sizeForAttachmentPreview:self.message
                                                         maxSize:CGSizeMake(maxImageWidth,maxImageHeight)];

    // layout photo/video
    if (!CGSizeEqualToSize(attachmentSize, CGSizeZero)) {

        CGFloat bubbleWidth = attachmentSize.width;
        CGFloat bubbleHeight = attachmentSize.height;
        bubbleHeight = MAX(bubbleHeight, kChatBubbleMinHeight);
        bubbleHeight = MIN(bubbleHeight, self.maxHeight);

        self.bubbleImageView.frame = CGRectMake(0, 0, bubbleWidth, bubbleHeight);
        if (self.message.user.isMe)
            self.bubbleImageView.frame = CGRectSetTopRight(b.size.width, 0, self.bubbleImageView.frame);

        self.snapCard.frame = self.bubbleImageView.frame;
        self.attachmentOverlay.center = self.snapCard.center;
        [self.snapCard maskWithImage:self.bubbleImageView.image inverted:NO toSize:self.snapCard.bounds.size];
    }

    // layout text
    else {
        UIEdgeInsets caps = self.bubbleImageView.image.capInsets;

        CGFloat contentWidth = self.maxWidth - caps.left - caps.right - 2*kChatBubbleTextHorizontalPadding;
        CGFloat contentHeight = self.maxHeight - 2*caps.bottom - 2*kChatBubbleTextVerticalPadding;
        CGSize maxTextSize = CGSizeMake(contentWidth, contentHeight);
        CGRect textBoundingRect = [self.message.attributedText boundingRectWithSize:maxTextSize
                                                                            options:NSStringDrawingUsesLineFragmentOrigin context:nil];

        CGRect textSize = CGRectInset(textBoundingRect, -1*kChatBubbleTextHorizontalPadding, -1*kChatBubbleTextVerticalPadding);
        CGFloat bubbleWidth = textSize.size.width;
        CGFloat bubbleHeight = textSize.size.height;
        bubbleHeight = MAX(bubbleHeight, kChatBubbleMinHeight);
        bubbleHeight = MIN(bubbleHeight, self.maxHeight);

        self.bubbleImageView.frame = CGRectInset(CGRectMake(0, 0, bubbleWidth, bubbleHeight),
                                                 -0.5*(caps.left+caps.right),
                                                 -1*caps.bottom);
        self.bubbleImageView.frame = CGRectSetOrigin(0, 0, self.bubbleImageView.frame);
        if (self.message.user.isMe)
            self.bubbleImageView.frame = CGRectSetTopRight(b.size.width, 0, self.bubbleImageView.frame);

        self.snapCard.frame = self.bubbleImageView.frame;
        self.attachmentOverlay.center = self.snapCard.center;

        self.textLabel.frame = CGRectMake(0, 0, textBoundingRect.size.width, textBoundingRect.size.height);
        self.textLabel.frame = CGRectSetMiddleLeft(CGRectGetMinX(self.bubbleImageView.frame)+caps.left+kChatBubbleTextHorizontalPadding,
                                                   self.bubbleImageView.center.y,
                                                   self.textLabel.frame);
    }
}

@end
