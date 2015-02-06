//
//  TutorialBubble.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/18/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TutorialBubble.h"
#import "PNUserPreferences.h"
#define kTutorialBubbleDismissNotification @"kTutorialBubbleDismissNotification"

@interface TutorialBubble()
@property (nonatomic, assign) BOOL didComplete;
@end

@implementation TutorialBubble

+ (void)dismissTutorialNamed:(NSString*)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTutorialBubbleDismissNotification object:name];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel.font = FONT_B(18);
        self.textLabel.textColor = COLOR(whiteColor);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.bubbleColor = COLOR(redColor);
        self.completeUponDismissal = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDismissNotification:) name:kTutorialBubbleDismissNotification object:nil];
    }
    return self;
}

- (BOOL)showInView:(UIView*)view completion:(void (^)(BOOL didShow))completion {

    if (![self wasCompleted] && view) {

        if (view == self.superview) {
            if (completion) completion(YES);
            return YES;
        }

        if (!self.superview) self.alpha = 0.0;

        [view addSubview:self];
        [UIView animateWithDuration:0.8f
                         animations:^{
                             self.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             if (completion) completion(YES);
                         }];
        return YES;
    }
    else {
        if (completion) completion(NO);
        return NO;
    }
}

- (BOOL)showInView:(UIView*)view {
    return [self showInView:view completion:nil];
}

- (BOOL)dismissWithCompletion:(void (^)(BOOL didDismiss))completion {
    if (self.superview) {
        [self.layer removeAllAnimations];
        [UIView animateWithDuration:0.8f
                         animations:^{
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];

                             if (self.onDismissBlock) {
                                 self.onDismissBlock();
                                 self.onDismissBlock = nil;
                             }

                             if (self.completeUponDismissal)
                                 [self markCompleted];

                             if (completion) completion(YES);
                         }];
        return YES;
    }
    else {
        if (self.onDismissBlock) {
            self.onDismissBlock();
            self.onDismissBlock = nil;
        }

        if (self.completeUponDismissal)
            [self markCompleted];

        if (completion) completion(NO);
        return NO;
    }
}

- (BOOL)dismiss {
    return [self dismissWithCompletion:nil];
}

- (void)markCompleted {
    self.didComplete = YES;
    if (self.name) {
        [[PNUserPreferences shared] setPreference:self.prefName boolValue:YES];
    }

    if (self.onCompletedBlock) {
        self.onCompletedBlock();
        self.onCompletedBlock = nil;
    }
}

- (BOOL)wasCompleted {
    if (self.didComplete)
        return YES;
    else if (kTutorialBubbleForceShow)
        return NO;
    else
        return self.name ? [[PNUserPreferences shared] boolPreference:self.prefName orDefault:NO] : NO;
}

- (NSString*)prefName {
    return self.name ? [NSString stringWithFormat:@"tutorial_%@_completed", self.name] : nil;
}

- (void)setTapToDismiss:(BOOL)tapToDismiss {
    if (tapToDismiss && !_tapToDismiss) {
        _tapToDismiss = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    }
    else {
        for (UIGestureRecognizer* gest in self.gestureRecognizers) {
            if ([gest isKindOfClass:[UITapGestureRecognizer class]])
                [self removeGestureRecognizer:gest];
        }
    }
}

- (void)onDismissNotification:(NSNotification*)notification {
    if ([notification.object isEqualToString:self.name]) {
        on_main(^{
            [self dismiss];
        });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
