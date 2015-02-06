//
//  NoobCamcorder.h
//  NoMe
//
//  Created by Jim Young on 11/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNCamera.h"
#import "GraffitiView.h"

@class CameraController;

@interface NoobCamcorder : PNCamera

@property (nonatomic, strong) GraffitiView* graffitiView;

@property (nonatomic, assign) id<UIImagePickerControllerDelegate,UINavigationControllerDelegate> pickerDelegate;
@property (nonatomic, assign) BOOL isVineRecording;

- (void) configureButtons;

@end
