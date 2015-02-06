//
//  ChatBubble.h
//
//
//  Created by Jim Young on 3/5/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapCardView.h"

@interface ChatBubble : UIView

@property (nonatomic, strong) SkyMessage* message;

// View elements. Make them public in case we want to attach gesture recognizers etc to them
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) SnapCardView *snapCard;
@property (nonatomic, strong) UIImageView *attachmentImage;
@property (nonatomic, strong) UIImageView *attachmentOverlay;

@property (nonatomic, strong) UIImageView *bubbleImageView;

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;


+ (CGSize) sizeForMessage:(SkyMessage*)message maxWidth:(CGFloat)maxWidth;

+ (CGSize) sizeForMessage:(SkyMessage*)message
                 maxWidth:(CGFloat)maxWidth
                maxHeight:(CGFloat)maxHeight;

+ (CGSize) sizeForAttachmentPreview:(SkyMessage*)message
                            maxSize:(CGSize)size;

- (CGSize) preferredSize;

@end