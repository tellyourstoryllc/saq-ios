//
//  OverviewChatBubble.m
//
//
//  Created by Jim Young on 3/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "OverviewChatBubble.h"

@implementation OverviewChatBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.attachmentImage.contentMode = UIViewContentModeScaleAspectFill;
        self.attachmentOverlay.alpha = 0.0;
    }
    return self;
}

+ (CGSize) sizeForAttachmentPreview:(SkyMessage*)message
                            maxSize:(CGSize)size {
    if (message.hasImage || message.hasVideo)
        return CGSizeMake(60,60);

    return [super sizeForAttachmentPreview:message maxSize:size];
}

@end
