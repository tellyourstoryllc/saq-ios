//
//  SnapCollectionCell.m
//  SnapCracklePop
//
//  Created by Jim Young on 9/23/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCollectionCell.h"
#import "GraphicsSettingsCell.h"

@interface SnapCollectionCell()

@end

@implementation SnapCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.card = [[SnapCardView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.card];
    }

    return self;
}

- (void)prepareForReuse {
    self.card.message = nil;
    self.card.delegate = nil;
    [self.card hideControls];
}

- (BOOL)isFeatured {
    return self.card.isFeatured;
}

- (BOOL)isPresentingOptions {
    return self.card.isPresentingOptions;
}

- (void)didBecomeFeatured {
    [self.card didBecomeFeatured];
    [self willResignOptions];
}

- (void)willResignFeatured {
    [self.card willResignFeatured];
}

- (void)didPresentOptions {
    [self.card didPresentOptions];
}

- (void)willResignOptions {
    [self.card willResignOptions];
}

- (void)dealloc {
    [self prepareForReuse];
}

@end
