//
//  TutorialBubble.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/18/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CalloutBubble.h"

// For debugging:
#define kTutorialBubbleForceShow    NO

@interface TutorialBubble : CalloutBubble

@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) BOOL tapToDismiss;
@property (nonatomic, assign) BOOL completeUponDismissal;

@property (nonatomic, copy) void(^onDismissBlock)(void);
@property (nonatomic, copy) void(^onCompletedBlock)(void);

+ (void)dismissTutorialNamed:(NSString*)name;

- (BOOL)showInView:(UIView*)view completion:(void (^)(BOOL didShow))completion;
- (BOOL)showInView:(UIView*)view;
- (BOOL)dismissWithCompletion:(void (^)(BOOL didDismiss))completion;
- (BOOL)dismiss;
- (void)markCompleted;

@end