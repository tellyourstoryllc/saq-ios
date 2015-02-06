//
//  StoryTableCell.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryTableCell.h"

#define kStoryTableCellMargin 4.0;

@interface StoryTableCell()
@end

@implementation StoryTableCell

+ (CGFloat) heightForStory:(Story*)story {
    return [self sizeForStory:story].height + kStoryTableCellMargin;
}

+ (CGSize) sizeForStory:(Story*)story {
    if (story.attachment_preview_width && story.attachment_preview_height) {
        CGFloat winWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
        CGFloat winHeight = [[UIApplication sharedApplication] keyWindow].frame.size.height;
        return CGSizeMake(winWidth,winHeight);
    }
    else
        return CGSizeZero;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.userInteractionEnabled = YES;
        self.backgroundColor = COLOR(blueColor);
        self.snapCard = [SnapCardView new];
        self.snapCard.showUsername = YES;
        [self.contentView addSubview:self.snapCard];
    }
    return self;
}

- (void)prepareForReuse {
    [self.story cancelMediaFetch];
    [self.snapCard hideControls];
    if (self.snapCard.isFeatured) [self.snapCard willResignFeatured];
    if (self.snapCard.isAppearing) [self.snapCard didDisappear];
    self.snapCard.message = nil;
    self.snapCard.delegate = nil;
    [super prepareForReuse];
}

- (void)layoutSubviews {
    CGFloat height = self.bounds.size.height - kStoryTableCellMargin;
    CGRect b = CGRectMake(0, 0, self.bounds.size.width, height);
    self.contentView.frame = b;
    self.snapCard.frame = b;
}

- (void)setStory:(Story *)story {
    _story = story;
    self.snapCard.message = story;
    [self.snapCard loadContent];
}

- (void)dealloc {
    self.snapCard.delegate = nil;
}

@end
