//
//  TinderVideoView.h
//  SnapCracklePop
//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCardView.h"

@interface VideoCardView : ContentCard

@property (nonatomic, strong) NSURL* videoUrl;
@property (nonatomic, assign) BOOL showActivityIndicator;

@property (nonatomic, readonly) BOOL isPlaying;

- (void)play;
- (void)stop;

@end
