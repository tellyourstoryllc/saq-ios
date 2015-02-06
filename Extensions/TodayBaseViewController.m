//
//  TodayViewController.m
//  Recent Stories
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TodayBaseViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "ExtensionConduit.h"
#import "NSArray+Map.h"
#import "VideoURLView.h"

@implementation TodayBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardLeft.backgroundColor = [UIColor clearColor];
    self.cardMiddle.backgroundColor = [UIColor clearColor];
    self.cardRight.backgroundColor = [UIColor clearColor];

    self.labelLeft = [[UILabel alloc] initWithFrame:self.cardLeft.frame];
    [self.view addSubview:self.labelLeft];
    self.labelMiddle = [[UILabel alloc] initWithFrame:self.cardMiddle.frame];
    [self.view addSubview:self.labelMiddle];
    self.labelRight = [[UILabel alloc] initWithFrame:self.cardRight.frame];
    [self.view addSubview:self.labelRight];

    NSArray* labels = @[self.labelLeft, self.labelMiddle, self.labelRight];
    for (UILabel* label in labels) {
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        label.numberOfLines = 2;
        label.transform = CGAffineTransformMakeRotation(-M_PI/3.f);;
    }

    self.buttonLeft = [[UIButton alloc] initWithFrame:self.cardLeft.frame];
    [self.view addSubview:self.buttonLeft];
    [self.buttonLeft addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];

    self.buttonMiddle = [[UIButton alloc] initWithFrame:self.cardMiddle.frame];
    [self.view addSubview:self.buttonMiddle];
    [self.buttonMiddle addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];

    self.buttonRight = [[UIButton alloc] initWithFrame:self.cardRight.frame];
    [self.view addSubview:self.buttonRight];
    [self.buttonRight addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {

    // Constrain labels to match cards
    NSArray* labelsToCards = @[
                               @[self.labelLeft, self.cardLeft],
                               @[self.labelMiddle, self.cardMiddle],
                               @[self.labelRight, self.cardRight],
                               ];

    for (NSArray* pair in labelsToCards) {
        UIView* label = pair[0];
        UIView* card = pair[1];
        label.frame = card.frame;
    }

}

- (void)removeAllSubviews:(UIView*)view {
    for (UIView* subview in view.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)expandAllSubviews:(UIView*)parent {
    for (UIView* child in parent.subviews) {
        child.frame = parent.bounds;
    }
}

- (void)clearCards {
    NSArray* cards = @[self.cardLeft, self.cardMiddle, self.cardRight];
    for (UIView* view in cards) {
        [self removeAllSubviews:view];
    }
}

- (void)onTouch:(id)sender {}

@end
