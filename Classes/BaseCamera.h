//
//  Camcorder.h
//  groups
//
//  Created by Jim Young on 11/15/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNCamera.h"
#import "GraffitiView.h"
#import "iCarousel.h"

@class CameraController;

@interface BaseCamera : PNCamera

@property (nonatomic, strong) GraffitiView* graffitiView;
@property (nonatomic, strong) UIImageView* snapshotView;
@property (nonatomic, strong) PNButton* importButton;
@property (nonatomic, strong) PNButton* flashlightButton;

@property (nonatomic, readonly) UIImage* overlay;
@property (nonatomic, readonly) NSString* caption;

@property (nonatomic, assign) id<UIImagePickerControllerDelegate,UINavigationControllerDelegate> pickerDelegate;

- (void) configureButtons;
- (void) startVineRecording;
- (UIImage*) scaleImageToFillView:(UIImage*)image;

@end
