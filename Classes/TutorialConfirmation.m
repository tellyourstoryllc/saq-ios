//
//  TutorialAlertView.m
//  NoMe
//
//  Created by Jim Young on 12/5/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TutorialConfirmation.h"
#import "PNUserPreferences.h"

@implementation TutorialConfirmation

- (BOOL) isCompleted {
#ifdef DEBUG
    // Always display in debug mode.
    return NO;
#endif
    return [[PNUserPreferences shared] boolPreference:[self _userPrefKey] orDefault:NO];
}

+ (void)presentLesson:(NSString *)lesson
                title:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
                 onOk:(void (^)(TutorialConfirmation*))okBlock
             onCancel:(void (^)(TutorialConfirmation*))cancelBlock {
    
    NSParameterAssert(lesson);

    TutorialConfirmation* tut = [[self alloc] initWithTitle:title message:message andButtonArray:@[@"OK", cancelButtonTitle]];
    cancelButtonTitle = cancelButtonTitle ?: @"Cancel";

    tut.lesson = lesson;
    tut.okBlock = okBlock;
    tut.cancelBlock = cancelBlock;
    [tut present];
}

- (void) present {
    if ([self isCompleted])
        self.okBlock(self);
    else
        [self showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self markCompleted];
                self.okBlock(self);
            }
            else
                self.cancelBlock(self);
        }];
}

- (void) markCompleted {
    [[PNUserPreferences shared] setPreference:[self _userPrefKey] boolValue:YES];
}

- (void) markIncomplete {
    [[PNUserPreferences shared] setPreference:[self _userPrefKey] boolValue:NO];
}

- (NSString*) _userPrefKey {
    return [NSString stringWithFormat:@"completed_tutorial_lesson_%@", self.lesson];
}

@end
