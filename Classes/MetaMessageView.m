//
//  MetaMessageView.m
//  FFM
//
//  Created by Jim Young on 4/26/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MetaMessageView.h"
#import "App.h"
#import "UIImageView+AFNetworking.h"

@interface MetaMessageView()

@property (nonatomic, assign) BOOL hasAvatar;
@property (nonatomic, assign) BOOL hasImage;

@property (nonatomic, strong) NSString* actorName;
@property (nonatomic, strong) NSString* possessive; // "your" or "<username>'s"
@property (nonatomic, strong) NSString* mediaType; // "photo", "video", or "message"

@end

@implementation MetaMessageView

+ (CGSize) sizeForMessage:(SkyMessage*)message maxWidth:(CGFloat)maxWidth {
    return CGSizeMake(maxWidth, 60);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.avatar = [[UserAvatarView alloc] init];

        self.label = [[PNLabel alloc] init];
        self.label.font = FONT_I(14);
        self.label.textColor = COLOR(defaultForegroundColor);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = [COLOR(whiteColor) colorWithAlphaComponent:0.33];
        self.label.layer.cornerRadius = 5;
        self.label.layer.masksToBounds = YES;

        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.cornerRadius = 5;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;

        [self addSubview:self.avatar];
        [self addSubview:self.label];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setMessage:(SkyMessage *)message {
    _message = message;

    void (^setTextBlock)() = ^() {

        if ([message.attachment_content_type isEqualToString:@"meta/like"]) {
            self.label.text = [NSString stringWithFormat:@"%@ liked %@ %@", self.actorName, self.possessive, self.mediaType];
        }

        else if ([message.attachment_content_type isEqualToString:@"meta/forward"]) {
            self.label.text = [NSString stringWithFormat:@"%@ resnapped %@ %@", self.actorName, self.possessive, self.mediaType];
        }

        else if ([message.attachment_content_type isEqualToString:@"meta/export"]) {

            self.label.text = [NSString stringWithFormat:@"%@ saved %@ %@", self.actorName, self.possessive, self.mediaType];

            NSString* method = @"";

            if ([method isEqualToString:@"screenshot"])
                 self.label.text = @"";

            if ([method isEqualToString:@"library"])
                 self.label.text = @"";

            if ([method isEqualToString:@"other"])
                 self.label.text = @"";
        }
    };

    if (message.attachment_message_id) {
        SkyMessage* referencedMessage = [[SkyMessage findByIds:@[message.attachment_message_id] inContext:[App moc]] lastObject];
        if (referencedMessage.attachment_preview_url) {
            [self.imageView setImageWithURL:[NSURL URLWithString:referencedMessage.attachment_preview_url]];
        }

        if (referencedMessage.user.isMe)
            self.possessive = @"your";
        else
            self.possessive = @"this";

        if (referencedMessage.hasVideo)
            self.mediaType = @"video";
        else if (referencedMessage.hasImage)
            self.mediaType = @"photo";
        else
            self.mediaType = @"message";
    }

    [self setNeedsLayout];

    if (message.actor_id) {
        [User fetchUserId:message.actor_id
               completion:^(User *user) {
                   if (user) {
                       self.actorName = user.displayName ?: @"Someone";
                       self.avatar.user = user;
                   } else
                       self.actorName = @"Someone";

                   setTextBlock();
                   [self setNeedsLayout];
               }];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    CGFloat margin = 20;

    self.avatar.frame = self.avatar.image ? CGRectMake(margin, 0, 40, 40) : CGRectZero;

    self.imageView.frame = self.imageView.image ? CGRectMake(0, 0, 40, 40) : CGRectZero;
    self.imageView.frame = CGRectSetTopRight(b.size.width-margin, 0, self.imageView.frame);

    self.label.frame = CGRectMakeCorners(CGRectGetMaxX(self.avatar.frame), 0, CGRectGetMinX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame));
    self.label.frame = CGRectInset(self.label.frame, 4, 4);
}

@end