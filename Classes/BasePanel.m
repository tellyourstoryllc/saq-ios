//
//  NoobBasePanel.m
//  groups
//
//  Created by Jim Young on 11/27/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "BasePanel.h"
#import "PanelViewController.h"

@interface BasePanel()
@property (nonatomic, assign) BOOL appeared;
@end

@implementation BasePanel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    @try {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        [self addSubview:self.bundledView];
    }
    @catch (NSException *exception) {
        // okay if bundle is not found. carry on.
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self positionBundleViewWithAnimation:NO];
}

- (BOOL) isNeeded { return YES; }

- (BOOL) canGotoNextPanel { return YES; }
- (BOOL) canGotoPreviousPanel { return YES; }
- (BOOL) gotoNextPanel { return [self canGotoNextPanel] ? [self.delegate requestNextPanel:self] : NO; }
- (BOOL) gotoPreviousPanel { return [self canGotoPreviousPanel] ? [self.delegate requestPreviousPanel:self] : NO; }

- (void) didDisappear {
    [self unregisterKeyboardNotifications];
}

- (void) didAppear {
    [self registerKeyboardNotifications];
    [self setNeedsLayout];
    if (!_appeared) {
        _appeared = YES;
        [self didFirstAppear];
    }
}

- (void) didFirstAppear {}

- (NSString*) title { return nil; }

- (void) registerKeyboardNotifications {
    __weak BasePanel* weakSelf = self;

    [self addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        CGRect vizFrame = CGRectIntersection(keyboardFrameInView, weakSelf.bounds);
        CGRect slice;
        CGRect remainder;
        CGRectDivide(weakSelf.bounds, &slice, &remainder, vizFrame.size.height, CGRectMaxYEdge);

        [weakSelf keyboardDidBecomeVisible:opening viewFrame:remainder keyboardFrame:keyboardFrameInView];
    }];
}

- (void) unregisterKeyboardNotifications {
    [self removeKeyboardControl];
}

- (void) keyboardDidBecomeVisible:(BOOL)visible viewFrame:(CGRect)viewFrame keyboardFrame:(CGRect)keyboardFrame {
    [self positionBundleViewWithAnimation:YES];
    [self setNeedsLayout];
}

- (void) positionBundleViewWithAnimation:(BOOL)animate {
    if (self.bundledView) {

        // Position bundled view in center of visible viewport.
        // To do so, we must subtract out the area covered by the keyboard.
        CGRect viz = [self visibleRect];
        CGPoint newCenter = CGPointMake(CGRectGetMidX(viz), CGRectGetMidY(viz));
        if (!CGPointEqualToPoint(newCenter, self.bundledView.center)) {
            if (animate) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.bundledView.center = newCenter;
                }];
            } else {
                self.bundledView.center = newCenter;
            }
        }
    }
}

- (void) reset {}

- (void) dealloc {
    [self unregisterKeyboardNotifications];
}

@end
