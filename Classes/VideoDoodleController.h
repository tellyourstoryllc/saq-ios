//
//  VideoDoodleController.h
//  FFM
//
//  Created by Jim Young on 4/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryShareViewController.h"
#import "GraffitiView.h"

@class VideoDoodleController;

@protocol VideoDoodleControllerDelegate <NSObject>

@optional

- (void) videoPreview:(VideoDoodleController*)preview
           didPublish:(NSURL*)videoURL
              overlay:(UIImage*)overlay
                 info:(NSDictionary*)info;
- (void) videoPreviewDidCancel:(VideoDoodleController*)preview;

@end

@interface VideoDoodleController : UIViewController<StoryShareViewControllerDelegate, GraffitiDelegate>

@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, strong) NSDictionary* info;

@property (nonatomic, assign) id<VideoDoodleControllerDelegate> delegate;
@property (nonatomic, strong) GraffitiView* graffitiView;

@property (nonatomic, strong) PNButton* cancelButton;

@end