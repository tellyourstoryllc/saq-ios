//
//  LinearLocationPanel.m
//  NoMe
//
//  Created by Jim Young on 11/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearLocationPanel.h"
#import "ArrowButton.h"
#import "LocationManager.h"
#import "PNGeocoder.h"
#import "UILabel+FadeEffect.h"

@interface LinearLocationPanel()


@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) PNLabel* subtitle;
@property (nonatomic, strong) ArrowButton* nextButton;

@property (nonatomic, strong) PNButton* activateButton;
@property (nonatomic, strong) PNButton* skipButton;
@property (nonatomic, strong) PNLabel* locationLabel;

@end

@implementation LinearLocationPanel

- (BOOL)isNeeded {
    return [self.controller valueForKey:@"videoFileURL"] ? YES : NO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.titleLabel = [PNLabel labelWithText:@"set location" andFont:HEADFONT(36)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];

    self.subtitle = [PNLabel labelWithText:@"Your exact location is never revealed to others. It is used to show people near you." andFont:FONT(16)];
//    self.subtitle.numberOfLines = 0;
    self.subtitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.subtitle];

    self.activateButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.activateButton.selectedColor = COLOR(greenColor);
    [self.activateButton setBorderWithColor:COLOR(blueColor) width:1];
    [self.activateButton addTarget:self action:@selector(onActivate) forControlEvents:UIControlEventTouchUpInside];
    [self.activateButton setTitle:@"allow location" forState:UIControlStateNormal];
    self.activateButton.titleLabel.font = HEADFONT(24);
    [self.activateButton setTitleColor:COLOR(blueColor) forState:UIControlStateNormal];
    [self addSubview:self.activateButton];

    self.skipButton = [[PNButton alloc] initWithFrame:CGRectZero];
    [self.skipButton addTarget:self action:@selector(onSkip) forControlEvents:UIControlEventTouchUpInside];
    [self.skipButton setTitle:@"skip" forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = HEADFONT(18);
    [self.skipButton setTitleColor:COLOR(grayColor) forState:UIControlStateNormal];
    [self addSubview:self.skipButton];

    self.nextButton = [[ArrowButton alloc] initWithFrame:CGRectZero];
    self.nextButton.titleLabel.font = FONT_B(21);
    [self.nextButton setTitle:@"next" forState:UIControlStateNormal];
    self.nextButton.arrowColor = COLOR(greenColor);
    self.nextButton.leftArrowWidth = -20;
    self.nextButton.rightArrowWidth = 20;
    [self.nextButton addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.alpha = 0.0;
    self.nextButton.enabled = NO;
    [self addSubview:self.nextButton];

    self.locationLabel = [PNLabel new];
    self.locationLabel.font = FONT_B(40);
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.locationLabel];

    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 24, self.titleLabel.frame);
    [self.subtitle sizeToFitTextWidth:b.size.width-12];
    self.subtitle.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.titleLabel.frame), self.subtitle.frame);

    CGFloat buttonHeight = 56;
    CGFloat bottom = self.visibleRect.size.height;
    self.nextButton.frame = CGRectMakeCorners(10, bottom-buttonHeight-10, b.size.width-10, bottom-10);

    CGFloat mid = b.size.height * (1.f-1.f/GOLDEN_MEAN);
    self.activateButton.frame = CGRectMake(0,0,160,40);
    self.activateButton.frame = CGRectSetCenter(b.size.width/2, mid, self.activateButton.frame);

    self.locationLabel.frame = CGRectSetCenter(self.activateButton.center.x, self.activateButton.center.y, CGRectMake(0, 0, b.size.width, 40));

    self.skipButton.frame = self.nextButton.frame;
}

- (void)didAppear {
    [super didAppear];
}

- (void)didDisappear {
    [super didDisappear];
}

- (void)onNext {
    [self gotoNextPanel];
}

- (void)onActivate {

    self.skipButton.hidden = YES;

    [[LocationManager manager] requestUsingPrescreen:NO
                                      withCompletion:^(CLLocation *location, NSError *error) {
        if (location) {
            PNGeocoder* geocoder = [PNGeocoder sharedGeocoder];
            [geocoder reverseGeocodeCoordinates:location.coordinate
                                     completion:^(NSArray *placemarks, NSError *error) {
                                         for (CLPlacemark* place in placemarks) {
                                             NSString* name = [PNGeocoder displayNameForPlace:place];
                                             if (name) {
                                                 [self.controller setValue:location forKey:@"location"];
                                                 [self.controller setValue:name forKey:@"locationName"];
                                                 self.locationLabel.text = name;
                                                 [self.locationLabel makeInvisible];
                                                 self.activateButton.hidden = YES;
                                                 [self.locationLabel fadeInOverDuration:2.0 toColor:COLOR(blueColor) completion:^{
                                                     self.nextButton.alpha = 1.0;
                                                     self.nextButton.enabled = YES;
                                                 }];

                                                 break;
                                             }
                                         }
                                     }];
        }
        else {
            [self.controller setValue:nil forKey:@"location"];
            [self.controller setValue:nil forKey:@"locationName"];
        }
    }];
}

- (void)onSkip {
    [self gotoNextPanel];
}

@end
