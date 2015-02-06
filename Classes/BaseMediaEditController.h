//
//  PhotoPreviewController.h
//  groups
//
//  Created by Jim Young on 11/23/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryShareViewController.h"
#import "GraffitiView.h"
#import "VideoURLView.h"

@class BaseMediaEditController;

@interface BaseMediaEditController : UIViewController<GraffitiDelegate>

@property (nonatomic, strong) UIImage* photo;
@property (nonatomic, strong) NSURL* videoUrl;
@property (nonatomic, strong) UIImage* overlay;
@property (nonatomic, readonly) UIImage* artwork;

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) VideoURLView* videoView;
@property (nonatomic, assign) BOOL isLandscape;

// The artwork composited with the overlay.
@property (nonatomic, readonly) UIImage* compositeOverlay;
@property (nonatomic, readonly) NSString* caption;

@property (nonatomic, strong) NSDictionary* info;
@property (nonatomic, strong) GraffitiView* graffitiView;

- (void)didBeginEditing;
- (void)didEndEditing;

- (void)didBeginDrawing;
- (void)didEndDrawing;

- (void)didBeginTexting;
- (void)didEndTexting;

@end