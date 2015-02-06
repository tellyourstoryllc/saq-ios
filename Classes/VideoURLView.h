//
//  VideoURLView.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoURLView : UIView

@property (nonatomic, strong) NSURL* videoUrl;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, strong) UIImage* screenshot;
@property (nonatomic, strong) UIImage* overlay;

- (void)play;
- (void)pause;
- (void)stop;

@end