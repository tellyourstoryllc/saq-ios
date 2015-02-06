//
//  LinearGenderPanel.m
//  NoMe
//
//  Created by Jim Young on 11/19/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearGenderPanel.h"
#import "ArrowButton.h"

@interface LinearGenderPanel()

@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) ArrowButton* nextButton;

@property (nonatomic, strong) PNButton* femaleButton;
@property (nonatomic, strong) PNButton* maleButton;

@end

@implementation LinearGenderPanel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.titleLabel = [PNLabel labelWithText:@"What is your gender?" andFont:HEADFONT(36)];
    [self addSubview:self.titleLabel];

    self.maleButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.maleButton.selectedColor = COLOR(greenColor);
    [self.maleButton setBorderWithColor:COLOR(grayColor) width:1];
    [self.maleButton addTarget:self action:@selector(onMale) forControlEvents:UIControlEventTouchUpInside];
    [self.maleButton setTitle:@"Male" forState:UIControlStateNormal];
    self.maleButton.titleLabel.font = HEADFONT(40);
    [self addSubview:self.maleButton];

    self.femaleButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.femaleButton.selectedColor = COLOR(greenColor);
    [self.femaleButton setBorderWithColor:COLOR(grayColor) width:1];
    [self.femaleButton addTarget:self action:@selector(onFemale) forControlEvents:UIControlEventTouchUpInside];
    [self.femaleButton setTitle:@"Female" forState:UIControlStateNormal];
    self.femaleButton.titleLabel.font = HEADFONT(40);
    [self addSubview:self.femaleButton];


    self.nextButton = [[ArrowButton alloc] initWithFrame:CGRectZero];
    self.nextButton.titleLabel.font = FONT_B(21);
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    self.nextButton.arrowColor = COLOR(greenColor);
    self.nextButton.leftArrowWidth = -20;
    self.nextButton.rightArrowWidth = 20;
    [self.nextButton addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.alpha = 0.0;
    self.nextButton.enabled = NO;
    [self addSubview:self.nextButton];

    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 24, self.titleLabel.frame);

    CGFloat buttonHeight = 56;
    CGFloat bottom = self.visibleRect.size.height;
    self.nextButton.frame = CGRectMakeCorners(10, bottom-buttonHeight-10, b.size.width-10, bottom-10);

    CGRect half = CGRectMake(0, 0, b.size.width/2, b.size.width/2);
    CGFloat mid = b.size.height * (1.f-1.f/GOLDEN_MEAN);
    CGRect left = CGRectSetMiddleLeft(0, mid, half);
    CGRect right = CGRectSetMiddleRight(b.size.width, mid, half);

    self.femaleButton.frame = CGRectInset(left, 4, 4);
    self.maleButton.frame = CGRectInset(right, 4, 4);
}

- (void)didAppear {
    [super didAppear];
}

- (void)didDisappear {
    [super didDisappear];
}

- (void)onMale {
    self.maleButton.selected = YES;
    self.femaleButton.selected = NO;
    self.nextButton.enabled = YES;
    self.nextButton.alpha = 1.0;
    [self.controller setValue:@"male" forKey:@"gender"];
}

- (void)onFemale {
    self.femaleButton.selected = YES;
    self.maleButton.selected = NO;
    self.nextButton.enabled = YES;
    self.nextButton.alpha = 1.0;
    [self.controller setValue:@"female" forKey:@"gender"];
}

- (void)onNext {
    [self gotoNextPanel];
}

@end
