//
//  GraffitiTextView.h
//
//
//  Created by Jim Young on 3/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTextView.h"

@protocol GraffitiTextViewDelegate <NSObject>
- (void)graffitiTextViewWillBeginMovingText;
- (void)graffitiTextViewDidEndMovingText;
@end

@interface GraffitiTextView : UIView

@property (nonatomic, assign) id<GraffitiTextViewDelegate> delegate;

@property (nonatomic, strong) UIFont* currentFont;
@property (nonatomic, assign) NSUInteger currentFontIndex;
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, assign) CGFloat verticalOffset;

@property (nonatomic, weak) UIControl* fontButton; // <-- passed in by superview

- (void)setActive:(BOOL)active;
- (void)setColor:(UIColor*)color;
- (void)setFontSize:(CGFloat)fontSize;

- (void)cycleFont;
- (void)clear;

@end
