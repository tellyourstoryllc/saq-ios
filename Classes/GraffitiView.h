//
//  GraffitiViewController.h
//
//
//  Created by Jim Young on 3/7/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Keyboard.h"
#import "GraffitiColorBar.h"

@class GraffitiView;

@protocol GraffitiDelegate <NSObject>

@optional

- (void) graffitiDidStartEditing:(GraffitiView*)graffitiController;
- (void) graffitiDidEndEditing:(GraffitiView*)graffitiController;

@end

@interface GraffitiView : UIView

@property (nonatomic, assign) CGPoint buttonOffset;

@property (nonatomic, assign) id<GraffitiDelegate> graffitiDelegate;

@property (nonatomic, strong) PNButton* textButton;
@property (nonatomic, strong) GraffitiColorBar* fontColorButton;

@property (nonatomic, strong) GraffitiColorBar* drawButton;
@property (nonatomic, strong) PNButton* undoButton;

// Current color for both drawing and text
@property (nonatomic, strong) UIColor* drawingColor;
@property (nonatomic, strong) UIColor* textingColor;

@property (nonatomic, strong) UIColor* inactiveButtonColor;
@property (nonatomic, strong) UIControl* invisibleButton;

// This part of the view remains "open" to view underneath.
@property (nonatomic, strong) NSMutableSet* cutouts;

// The (preexisting) overlay
@property (nonatomic, strong) UIImage* overlay;

// Are we currently drawing?
@property (nonatomic, assign) BOOL isDrawing;
@property (nonatomic, assign) BOOL isTexting;
@property (nonatomic, assign) BOOL isEditing;

// False if user has not drawn or typed anything
@property (nonatomic, readonly) BOOL hasEdits;

- (void)clear;
- (UIImage*)artwork;
- (NSString*)textString;
- (NSString*)configDescription;

- (void)addCutout:(CGRect)rect;

@end