//
//  CameraViewController.h
//
//
//  Created by Jim Young on 2/25/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCarouselController.h"
#import "MainCamera.h"
#import "StoryShareViewController.h"
#import "NewMediaEditController.h"

@class GroupViewController;

@interface CenterViewController : PNSimpleContainerController <PNCameraDelegate, StoryShareViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) Group* group;
@property (nonatomic, weak) MainCarouselController* mainController;

- (void)openCamera;
- (void)openCameraForGroup:(Group*)group;
- (void)openGroup:(Group*)group;

- (void)openCameraWithCompletion:(void (^)(BaseCamera* camcorder))completion;
- (void)openCameraForGroup:(Group*)group withCompletion:(void (^)(BaseCamera* camcorder))completion;

- (void)stopCamera;

@end
