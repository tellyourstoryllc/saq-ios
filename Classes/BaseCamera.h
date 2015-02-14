//
//  Camcorder.h
//  groups
//
//  Created by Jim Young on 11/15/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNCamera.h"
#import "iCarousel.h"

@class CameraController;

@interface BaseCamera : PNCamera

@property (nonatomic, strong) UIImageView* snapshotView;
@property (nonatomic, strong) UIImage* rawScreenshot;

@property (nonatomic, assign) id<UIImagePickerControllerDelegate,UINavigationControllerDelegate> pickerDelegate;

- (void) configureButtons;
- (void) startVineRecording;
- (UIImage*) scaleImageToFillView:(UIImage*)image;

@end
