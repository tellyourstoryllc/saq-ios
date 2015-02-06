//
//  GraffitiColorBar.m
//
//
//  Created by Jim Young on 3/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "GraffitiColorBar.h"
#import "UIView+Mask.h"
#import "UIColor+RGB.h"

@interface GraffitiColorBar()<RSColorPickerViewDelegate>

@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UIColor* startDragColor;
@property (nonatomic, assign) CGPoint startDragPoint;
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, assign) CGRect activeFrame;

@property (nonatomic, strong) UIColor* currentColor;

@end

@implementation GraffitiColorBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.color = COLOR(yellowColor);

        self.picker = [[RSColorPickerView alloc] initWithFrame:CGRectZero];
        self.picker.hidden = YES;
        self.picker.layer.masksToBounds = YES;
        [self addSubview:self.picker];

        self.controlView = [[UIView alloc] initWithFrame:CGRectZero];
        self.controlView.userInteractionEnabled = NO;
        [self addSubview:self.controlView];

        self.iconView = [[UIImageView alloc] init];
        self.iconView.userInteractionEnabled = NO;
        [self.controlView addSubview:self.iconView];

    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectEqualToRect(self.controlView.frame, CGRectZero)) {
        self.controlView.frame = self.bounds;
    }
    self.picker.frame = [self convertRect:self.pickerFrame fromView:self.superview];
}

- (void)setImage:(UIImage *)image {
    self.iconView.image = image;
    [self setNeedsLayout];
}

- (void)setPickerFrame:(CGRect)pickerFrame {
    _pickerFrame = pickerFrame;
    CGFloat diameter = CGRectGetWidth(self.pickerFrame);
    self.picker.layer.cornerRadius = diameter/2;
    self.picker.frame = [self convertRect:_pickerFrame fromView:self.superview];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.picker.frame = self.pickerFrame;

    [self.iconView sizeToFit];
    self.iconView.frame = CGRectSetCenter(self.frame.size.width/2, self.frame.size.height/2, self.iconView.frame);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

    [super beginTrackingWithTouch:touch withEvent:event];
    self.startDragPoint = [touch locationInView:self.superview];
    self.startDragColor = self.color;

    if (CGRectEqualToRect(self.inactiveFrame, CGRectZero))
        self.inactiveFrame = self.frame;

    self.activeFrame = CGRectUnion(self.inactiveFrame, self.pickerFrame);

    CGPoint p = [self convertPoint:self.inactiveFrame.origin fromView:self.superview];
    self.controlView.frame = CGRectSetOrigin(p.x, p.y, self.inactiveFrame);
    self.startFrame = [self convertRect:self.inactiveFrame fromView:self.superview];

    self.picker.hidden = NO;

    self.picker.frame = [self convertRect:self.pickerFrame fromView:self.superview];

    self.picker.layer.borderColor = [COLOR(whiteColor) CGColor];
    self.picker.layer.borderWidth = 4;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat fingerOffset = 34; // Adjust for fat finger.

    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint p = [touch locationInView:self.superview];

    CGPoint pp = [touch locationInView:self.picker];
    CGPoint pickerPoint = CGPointMake(pp.x, pp.y-fingerOffset);
    if ([self.picker pointInside:pickerPoint withEvent:event]) {
        UIColor* pickerColor = [self.picker colorAtPoint:pickerPoint];
        [self updateColor:pickerColor];
        self.picker.selectionColor = pickerColor;
        self.controlView.hidden = YES;
    }
    else {
        [self updateColor:self.startDragColor];
        self.controlView.hidden = NO;
    }

    CGFloat realDeltaX = (p.x - self.startDragPoint.x);
    CGFloat realDeltaY = (p.y - self.startDragPoint.y);
    self.controlView.frame = CGRectOffset(self.startFrame, realDeltaX, realDeltaY - fingerOffset);
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    self.picker.hidden = YES;
    self.controlView.hidden = NO;

    [UIView animateWithDuration:0.3 animations:^{
        self.frame = self.inactiveFrame;
        self.controlView.frame = CGRectSetOrigin(0, 0, self.inactiveFrame);
    }];

}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    self.picker.hidden = YES;
    [self updateColor:self.startDragColor];
    self.controlView.hidden = NO;

    [UIView animateWithDuration:0.3 animations:^{
        self.frame = self.inactiveFrame;
        self.controlView.frame = CGRectSetOrigin(0, 0, self.inactiveFrame);
    }];
}

- (void)updateColor:(UIColor*)color {
    if (color == _currentColor || [color isEqual:_currentColor])
        return;
    [self setColor:color];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setColor:(UIColor *)color {
    if (color == _currentColor || [color isEqual:_currentColor])
        return;

    _currentColor = color;
    self.controlView.backgroundColor = color;
}

- (UIColor*)color {
    return _currentColor;
}

@end
