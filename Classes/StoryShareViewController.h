//
//  CameraShareViewController.h
//
//
//  Created by Jim Young on 3/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoryShareViewController;

@protocol StoryShareViewControllerDelegate <NSObject>

@optional
- (void) shareControllerWillSend:(StoryShareViewController*)controller;
- (void) shareControllerDidCancel:(StoryShareViewController*)controller;
- (void) shareControllerDidSave:(StoryShareViewController*)controller;

- (void) shareControllerWillFacebook:(StoryShareViewController*)controller;
- (void) shareControllerWillTwitter:(StoryShareViewController*)controller;
- (void) shareControllerWillInstagram:(StoryShareViewController*)controller;

@end

@interface StoryShareViewController : PNSimpleTableViewController

@property (nonatomic, weak) id<StoryShareViewControllerDelegate> delegate;

// Stuff to be shared: either a videoURL or an image
@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSDictionary* info;   // metadata

// Properties of device/camera at time of capture
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

// Optional
@property (nonatomic, strong) UIImage* previewImage;

@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) PNTextField* textField;
@property (nonatomic, strong) PNButton* addNewUserButton;

@property (strong, nonatomic) PNButton *backButton;
@property (strong, nonatomic) PNButton *sendButton;

@property (nonatomic, strong) UIImageView* thumbView;

// An array of DirectoryItems.
@property (nonatomic, strong) NSMutableArray* selectedPeopleArray;
@property (nonatomic, strong) NSArray* excludedPeopleArray;

@property (nonatomic, strong) NSArray* highlightedGroups;

@property (nonatomic, assign) BOOL storySelected; // post to story?
@property (nonatomic, assign) BOOL albumSelected; // save to album?

- (void)onSendSuccess;

@end
