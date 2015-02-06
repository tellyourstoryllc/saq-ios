//
//  LinearAgePanel.m
//  NoMe
//
//  Created by Jim Young on 11/19/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearAgeGenderPanel.h"
#import "ArrowButton.h"
#import "LocationManager.h"

@interface LinearAgeGenderPanel()

@property (nonatomic, strong) PNLabel* dateLabel;
@property (nonatomic, strong) UIDatePicker* datePicker;

@property (nonatomic, strong) PNLabel* genderLabel;
@property (nonatomic, strong) PNButton* femaleButton;
@property (nonatomic, strong) PNButton* maleButton;

@property (nonatomic, strong) ArrowButton* nextButton;

@property (nonatomic, strong) PNRichLabel* tosLabel;

@end

@implementation LinearAgeGenderPanel

- (BOOL)isNeeded {
    return [self.controller valueForKey:@"videoFileURL"] ? YES : NO;
}

- (void)didAppear {
    [super didAppear];

    static BOOL displayedAlert;
    if (!displayedAlert)
        [AlertView showWithTitle:nil
                      andMessage:@"Your age and gender is needed to find people to connect you with."
                  withCompletion:^(NSInteger buttonIndex) {
                      [self nextSection];
                      displayedAlert = YES;
                  }];
    else
        [self nextSection];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.dateLabel = [PNLabel labelWithText:@"what is your birthday?" andFont:self.headerFont];
    [self addSubview:self.dateLabel];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(onDateChange) forControlEvents:UIControlEventValueChanged];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d LLL yyyy"];
    self.datePicker.date = [dateFormat dateFromString:@"1 Jan 2011"]; // Set default date to 1/1/11
    [self addSubview:self.datePicker];

    self.genderLabel = [PNLabel labelWithText:@"your gender" andFont:self.headerFont];
    [self addSubview:self.genderLabel];

    self.maleButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.maleButton.selectedColor = COLOR(blueColor);
    [self.maleButton setTitleColor:COLOR(grayColor) forState:UIControlStateNormal];
    [self.maleButton setTitleColor:COLOR(whiteColor) forState:UIControlStateSelected];
    [self.maleButton setBorderWithColor:COLOR(grayColor) width:1];
    [self.maleButton addTarget:self action:@selector(onMale) forControlEvents:UIControlEventTouchUpInside];
    [self.maleButton setTitle:@"MALE" forState:UIControlStateNormal];
    self.maleButton.titleLabel.font = HEADFONT(42);
    [self addSubview:self.maleButton];

    self.femaleButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.femaleButton.selectedColor = COLOR(orangeColor);
    [self.femaleButton setTitleColor:COLOR(grayColor) forState:UIControlStateNormal];
    [self.femaleButton setTitleColor:COLOR(whiteColor) forState:UIControlStateSelected];
    [self.femaleButton setBorderWithColor:COLOR(grayColor) width:1];
    [self.femaleButton addTarget:self action:@selector(onFemale) forControlEvents:UIControlEventTouchUpInside];
    [self.femaleButton setTitle:@"FEMALE" forState:UIControlStateNormal];
    self.femaleButton.titleLabel.font = HEADFONT(42);
    [self addSubview:self.femaleButton];

    self.tosLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
    self.tosLabel.textColor = COLOR(darkGrayColor);
    self.tosLabel.textAlignment = RTTextAlignmentCenter;
    self.tosLabel.font = FONT(11);
    self.tosLabel.text = [NSString stringWithFormat:@"By pressing OK, you acknowledge and accept the<br><a href='%@'><font color='#c399c7'>Terms of Service & Privacy Policy</font></a>", kTermsOfServiceURL];
    [self addSubview:self.tosLabel];

    self.nextButton = [[ArrowButton alloc] initWithFrame:CGRectZero];
    self.nextButton.titleLabel.font = FONT_B(21);
    [self.nextButton setTitle:@"OK" forState:UIControlStateNormal];
    self.nextButton.arrowColor = COLOR(turquoiseColor);
    self.nextButton.leftArrowWidth = -20;
    self.nextButton.rightArrowWidth = 20;
    [self.nextButton addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.nextButton];

    [self setGenderHidden:YES];
    [self setBirthdayHidden:YES];
    [self setNextHidden:YES];
    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
//    CGFloat mid = b.size.height * (1.f-1.f/GOLDEN_MEAN);

    CGFloat spacing = 40;

    CGFloat buttonHeight = 56;
    CGFloat bottom = self.visibleRect.size.height;
    self.nextButton.frame = CGRectMakeCorners(10, bottom-buttonHeight-10, b.size.width-10, bottom-10);
    self.tosLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.nextButton.frame)-4, CGRectMake(0, 0, b.size.width, 30));

    self.datePicker.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.tosLabel.frame)-8, self.datePicker.frame);
    self.dateLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.datePicker.frame)+10, self.dateLabel.frame);

    self.genderLabel.frame = CGRectSetTopCenter(b.size.width/2, 10, self.genderLabel.frame);

    CGFloat remainder = CGRectGetMinY(self.dateLabel.frame) - CGRectGetMaxY(self.genderLabel.frame) - spacing;

    CGRect half = CGRectMake(0, 0, b.size.width/2, remainder);
    CGRect left = CGRectSetOrigin(0, CGRectGetMaxY(self.genderLabel.frame), half);
    CGRect right = CGRectSetTopRight(b.size.width, CGRectGetMaxY(self.genderLabel.frame), half);

    self.femaleButton.frame = CGRectInset(left, 8, 4);
    self.maleButton.frame = CGRectInset(right, 8, 4);

}

- (void)nextSection {
    if (![self.controller valueForKey:@"gender"]) {
        [self setGenderHidden:NO];
        [self setBirthdayHidden:YES];
        [self setNextHidden:YES];
    }
    else if (![self.controller valueForKey:@"birthdate"]) {
        [self setGenderHidden:NO];
        [self setBirthdayHidden:NO];
        [self setNextHidden:YES];
    }
    else {
        [self setGenderHidden:NO];
        [self setBirthdayHidden:NO];
        [self setNextHidden:NO];
    }
}

- (void)setGenderHidden:(BOOL)hidden {
    self.genderLabel.hidden = hidden;
    self.maleButton.hidden = hidden;
    self.femaleButton.hidden = hidden;
}

- (void)setBirthdayHidden:(BOOL)hidden {
    self.dateLabel.hidden = hidden;
    self.datePicker.hidden = hidden;
}

- (void)setNextHidden:(BOOL)hidden {
    self.nextButton.hidden = hidden;
    self.tosLabel.hidden = hidden;
    self.nextButton.enabled = !hidden;
}

- (void)onMale {
    self.maleButton.selected = YES;
    self.femaleButton.selected = NO;
    [self.controller setValue:@"male" forKey:@"gender"];
    [self nextSection];
}

- (void)onFemale {
    self.femaleButton.selected = YES;
    self.maleButton.selected = NO;
    [self.controller setValue:@"female" forKey:@"gender"];
    [self nextSection];
}

- (void)onDateChange {
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }

    if ([self.datePicker.date yearsOld] > 16) {
        [self.controller setValue:[dateFormatter stringFromDate:self.datePicker.date] forKey:@"birthdate"];
    }
    else {
        [self.controller setValue:nil forKey:@"birthdate"];
    }
    [self nextSection];
}

- (void)onNext {
    [[LocationManager manager] requestUsingPrescreen:YES withCompletion:^(CLLocation *location, NSError *error) {
        location = location ?: [CLLocation nowhere];
        [self.controller setValue:location forKey:@"location"];
        [self gotoNextPanel];
    }];
}

@end
