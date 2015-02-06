//
//  GraffitiViewController.m
//
//
//  Created by Jim Young on 3/7/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "GraffitiView.h"
#import "PNKit.h"
#import "ACEDrawingView.h"
#import "ACEDrawingTools.h"
#import "GraffitiColorBar.h"
#import "GraffitiTextView.h"

@interface GraffitiView ()<ACEDrawingViewDelegate, UITextFieldDelegate, GraffitiTextViewDelegate> {
    BOOL _clearedOverlay;
}

@property (nonatomic, strong) ACEDrawingView* drawView;
@property (nonatomic, strong) GraffitiTextView* textingView;
@property (nonatomic, strong) UIImageView* overlayView;

@end

@implementation GraffitiView

- (id)init {
    self = [super init];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        self.drawingColor = COLOR(yellowColor);
        self.textingColor = COLOR(whiteColor);
        self.inactiveButtonColor = [COLOR(blackColor) colorWithAlphaComponent:0.66];

        self.buttonOffset = CGPointZero;

        self.overlayView = [[UIImageView alloc] init];
        [self addSubview:self.overlayView];
        
        self.drawView = [[ACEDrawingView alloc] init];
        self.drawView.delegate = self;
        self.drawView.drawTool = ACEDrawingToolTypePen;
        self.drawView.lineColor = [UIColor clearColor];
        self.drawView.lineAlpha = 1.0;
        [self addSubview:self.drawView];

        self.textingView = [[GraffitiTextView alloc] init];
        self.textingView.delegate = self;
        self.textingView.userInteractionEnabled = NO;
        [self.textingView setColor:self.textingColor];
        [self addSubview:self.textingView];

        // Toolbar contents

        self.invisibleButton = [[UIControl alloc] init];
        [self.invisibleButton addTarget:self action:@selector(onActivate) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.invisibleButton];

        self.textButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.textButton.buttonColor = self.textingColor;
        self.textButton.alpha = 0.88;
        [self.textButton setImage:[UIImage imageNamed:@"type"] forState:UIControlStateNormal];
        [self.textButton addTarget:self action:@selector(onText) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.textButton];

        self.drawButton = [[GraffitiColorBar alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.drawButton.color = self.drawingColor;
        self.drawButton.picker.alpha = 0.8;
        self.drawButton.alpha = 0.88;
        [self.drawButton setImage:[UIImage imageNamed:@"brush"]];
        [self.drawButton addTarget:self action:@selector(onColorChange:) forControlEvents:UIControlEventValueChanged];
        [self.drawButton addTarget:self action:@selector(onDraw) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.drawButton];

        self.undoButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        [self.undoButton setBorderWithColor:COLOR(blackColor) width:1];
        self.undoButton.hidden = YES;
        self.undoButton.buttonColor = COLOR(whiteColor);
        [self.undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
        [self.undoButton addTarget:self action:@selector(onUndo) forControlEvents:UIControlEventTouchDown];
        self.undoButton.alpha = 0.88;
        [self addSubview:self.undoButton];

        self.fontColorButton = [[GraffitiColorBar alloc] initWithFrame:CGRectMake(0,0,50,40)];
        self.fontColorButton.color = self.textingColor;
        self.fontColorButton.picker.alpha = 0.8;
        self.fontColorButton.hidden = YES;
        [self.fontColorButton addTarget:self action:@selector(onColorChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.fontColorButton];
        self.textingView.fontButton = self.fontColorButton;

        self.isDrawing = NO;
        self.isTexting = NO;

    }
    return self;
}

- (void) onActivate {
    if (!self.isDrawing && !self.isTexting)
        [self setIsTexting:YES];
}

- (void)addCutout:(CGRect)rect {
    if (!self.cutouts)
        self.cutouts = [NSMutableSet new];

    [self.cutouts addObject:[NSValue valueWithCGRect:rect]];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    if (![super pointInside:point withEvent:event])
        return NO;

    BOOL cutoutContainsPoint = NO;
    for (NSValue* val in self.cutouts) {
        CGRect cutout = [val CGRectValue];
        if (CGRectContainsPoint(cutout, point)) {
            cutoutContainsPoint = YES;
            break;
        }
    }

    if (self.isDrawing && !cutoutContainsPoint)
        return YES;

    if (self.isTexting && !cutoutContainsPoint)
        return YES;

    if (CGRectContainsPoint(self.invisibleButton.frame, point) && !cutoutContainsPoint)
        return YES;

    if (CGRectContainsPoint(self.drawButton.frame, point)) return YES;
    if (CGRectContainsPoint(self.textButton.frame, point)) return YES;

    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat x = self.buttonOffset.x;
    CGFloat y = self.buttonOffset.y;
    CGFloat w = self.bounds.size.width;
    CGFloat m = 15;

    self.drawButton.frame = CGRectSetTopRight(x+w,y,self.drawButton.frame);
    self.textButton.frame = CGRectSetTopRight(x+w,CGRectGetMaxY(self.drawButton.frame)+m, self.textButton.frame);

    self.undoButton.frame = CGRectSetTopRight(CGRectGetMinX(self.drawButton.frame)-m, y, self.undoButton.frame);

    self.fontColorButton.frame = CGRectSetTopRight(x+w, CGRectGetMaxY(self.textButton.frame), self.fontColorButton.frame);


    self.invisibleButton.frame = CGRectMakeCorners(0,
                                                   CGRectGetMaxY(self.textButton.frame),
                                                   CGRectGetMinX(self.drawButton.frame),
                                                   self.bounds.size.height);

    CGFloat pickerDim = MIN(b.size.width, b.size.height)*0.8;
    CGRect pickerFrame = CGRectSetCenter(b.size.width/2, b.size.height/(1+GOLDEN_MEAN), CGRectMake(0,0, pickerDim, pickerDim));
    pickerFrame = CGRectIntegral(pickerFrame); // <-- color picker crashes on non-integer frames.
    pickerFrame = CGRectMake(pickerFrame.origin.x, pickerFrame.origin.y, pickerFrame.size.width, pickerFrame.size.width); // <-- width and height of picker must be EXACTLY the same.
    self.drawButton.pickerFrame = pickerFrame;
    self.fontColorButton.pickerFrame = pickerFrame;

    self.overlayView.frame = b;

}

- (void)setFrame:(CGRect)target {
    [super setFrame:target];
    self.drawView.frame = self.bounds;
    self.textingView.frame = self.bounds;
}

- (BOOL)hasEdits {
    return self.drawView.canUndo || (self.textString.length > 0) || _clearedOverlay;
}

- (UIImage*)artwork {

    UIImage* img = self.overlay;

    if (img && self.drawView.image) {
        img = [self.overlay overlayImage:self.drawView.image
                                 inFrame:CGRectMake(0, 0, self.overlay.size.width, self.overlay.size.height)
                               blendMode:kCGBlendModeNormal
                                   alpha:1.0];
    }

    img = img ?: self.drawView.image;
    UIImage* textImage = self.textingView.textView.text.length ? [UIImage imageWithView:self.textingView] : nil;

    if (img && textImage) {
        return [img overlayImage:textImage
                         inFrame:CGRectMake(0, 0, img.size.width, img.size.height)
                       blendMode:kCGBlendModeNormal
                           alpha:1.0];
    }
    else {
        return img ?: textImage;
    }
}

- (void)setOverlay:(UIImage *)overlay {
    _overlay = overlay;
    [self.overlayView setImage:overlay];
}

- (void)clear {
    if (self.overlay)
        _clearedOverlay = YES;

    [self.drawView clear];
    [self.textingView clear];
    self.overlay = nil;
    self.isDrawing = NO;
    self.isTexting = NO;
    self.undoButton.hidden = YES;
    self.fontColorButton.hidden = YES;
    self.invisibleButton.enabled = YES;
}

#pragma mark ACEDrawingViewDelegate methods

- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool {

    self.drawButton.hidden = YES;
    self.textButton.hidden = YES;
    self.undoButton.hidden = YES;

    self.isEditing = YES;

    if ([self.graffitiDelegate respondsToSelector:@selector(graffitiDidStartEditing:)])
        [self.graffitiDelegate graffitiDidStartEditing:self];
}

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool {

    self.undoButton.hidden = ![view canUndo];
    self.drawButton.hidden = NO;
    self.textButton.hidden = NO;

    self.isEditing = NO;

    if ([self.graffitiDelegate respondsToSelector:@selector(graffitiDidEndEditing:)])
        [self.graffitiDelegate graffitiDidEndEditing:self];
}

- (void)graffitiTextViewWillBeginMovingText {
    self.drawButton.hidden = YES;
    self.textButton.hidden = YES;
    self.fontColorButton.hidden = YES;

    self.isEditing = YES;

    if ([self.graffitiDelegate respondsToSelector:@selector(graffitiDidStartEditing:)])
        [self.graffitiDelegate graffitiDidStartEditing:self];
}

- (void)graffitiTextViewDidEndMovingText {
    self.drawButton.hidden = NO;
    self.textButton.hidden = NO;
    self.fontColorButton.hidden = NO;

    self.isEditing = NO;

    if ([self.graffitiDelegate respondsToSelector:@selector(graffitiDidEndEditing:)])
        [self.graffitiDelegate graffitiDidEndEditing:self];
}

#pragma mark actions

- (void)setDrawingColor:(UIColor *)currentColor {
    _drawingColor = currentColor;
    self.drawView.lineColor = currentColor;
    if (self.isDrawing)
        self.drawButton.color = currentColor;
}

- (void)setTextingColor:(UIColor *)currentColor {
    _textingColor = currentColor;
    self.textingView.color = currentColor;
    if (self.isTexting) {
        self.fontColorButton.color = currentColor;
        self.fontColorButton.layer.shadowColor = [[currentColor complement] CGColor];
    }
}

- (void)setIsDrawing:(BOOL)isDrawing {
    _isDrawing = isDrawing;

    self.drawButton.color = isDrawing ? self.drawingColor : self.inactiveButtonColor;
    self.drawView.userInteractionEnabled = isDrawing;
    self.textingView.userInteractionEnabled = !isDrawing;

    if (isDrawing ) {
        self.drawView.lineWidth = 8;
        self.drawView.drawTool = ACEDrawingToolTypePen;
        self.drawView.lineColor = self.drawingColor;
        self.undoButton.hidden = ![self.drawView canUndo];
        self.invisibleButton.enabled = NO;
        [self.textButton setImage:[UIImage imageNamed:@"type"] forState:UIControlStateNormal];
    }
}

- (void)setIsTexting:(BOOL)isTexting {
    _isTexting = isTexting;
    self.textButton.buttonColor = isTexting ? COLOR(blueColor) : self.inactiveButtonColor;
    self.drawView.userInteractionEnabled = !isTexting;
    self.textingView.userInteractionEnabled = isTexting;

    if (isTexting) {
        self.undoButton.hidden = YES;
        self.invisibleButton.enabled = NO;
        [self.textButton setImage:[UIImage imageNamed:@"font"] forState:UIControlStateNormal];

        self.fontColorButton.color = _textingColor;
    }

    [self.textingView setActive:_isTexting];
}

- (void)onDraw {
    self.isTexting = NO;

    if (!self.isDrawing || self.drawView.drawTool == ACEDrawingToolTypeEraser) {
        self.isDrawing = YES;
        self.drawView.lineWidth = 6.0;
    }
}

- (void)onText {
    self.isDrawing = NO;

    if (!self.isTexting) {
        self.isTexting = YES;
    }
    else {
        [self.textingView cycleFont];
    }
}

- (void)onUndo {
    [self.drawView undoLatestStep];
    self.undoButton.hidden = ![self.drawView canUndo];
}

- (void)onColorChange:(id)sender {
    if (sender == self.drawButton) {
        self.drawingColor = [sender color];
    }
    else if (sender == self.fontColorButton) {
        self.textingColor = [sender color];
    }
}

- (NSString*)textString {
    return self.textingView.textView.text;
}

- (NSString*)configDescription {
    NSString* text = self.textingView.textView.text.length > 0 ? @"text" : @"notext";
    NSString* drawing = self.drawView.canUndo ? @"draw" : @"nodraw";
    return [NSString stringWithFormat:@"%@.%@", text, drawing];
}

@end
