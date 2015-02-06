//
//  TutorialAlertView.h
//  NoMe
//
//  Created by Jim Young on 12/5/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "AlertView.h"

@interface TutorialConfirmation : AlertView

@property (nonatomic, strong) NSString* lesson;

@property (nonatomic, copy) void(^okBlock)(TutorialConfirmation*);
@property (nonatomic, copy) void(^cancelBlock)(TutorialConfirmation*);

+ (void)presentLesson:(NSString *)lesson
              title:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
               onOk:(void (^)(TutorialConfirmation* tut))okBlock
           onCancel:(void (^)(TutorialConfirmation* tut))cancelBlock;

- (void) markCompleted;
- (void) markIncomplete;

@end
