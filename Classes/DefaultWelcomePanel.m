//
//  DefaultWelcomePanel.m
//  SnapCracklePop
//
//  Created by Jim Young on 5/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "DefaultWelcomePanel.h"
#import "App.h"
#import "PNUserPreferences.h"
#import "ArrowButton.h"
#import "UILabel+FadeEffect.h"
#import "VideoURLView.h"

@interface DefaultWelcomePanel() {
    BOOL _cancelTransitions;
}

@property (nonatomic, strong) VideoURLView* videoView;

@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic, strong) PNLabel* label1;
@property (nonatomic, strong) PNLabel* label2;
@property (nonatomic, strong) PNLabel* label3;
@property (nonatomic, strong) PNLabel* label4;

@property (nonatomic, strong) UIColor* label1Color;
@property (nonatomic, strong) UIColor* label2Color;
@property (nonatomic, strong) UIColor* label3Color;
@property (nonatomic, strong) UIColor* label4Color;

@property (nonatomic, strong) ArrowButton* button;

@property (assign, nonatomic) CGFloat yOffset;

@end

@implementation DefaultWelcomePanel


- (BOOL)isNeeded {
    return YES;
}

- (void)didAppear {

    [self updateText];
    [self.label1 makeInvisible];

    [self.label1 fadeInOverDuration:2.0
                               toColor:self.label1Color
                            completion:^{
                                self.button.alpha = 1.0;
                                [self updateText];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self performTextTransitions];
                                });
                            }
                            afterDelay:0.5];

    self.videoView.videoUrl = [NSURL URLWithString:@"http://test-media.know.me.s3.amazonaws.com/1376425910a437792fabcb2406_720p.mp4"];
    [self.videoView play];

}

- (void)didDisappear {
    _cancelTransitions = YES;
    [self.videoView pause];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.videoView = [[VideoURLView alloc] initWithFrame:self.bounds];
        self.videoView.muted = YES;
        self.videoView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.videoView];

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topStrip];

        self.label1 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label2 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label3 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label4 = [[PNLabel alloc] initWithFrame:CGRectZero];

        self.label1.text = @"create a PERSONAL JOURNAL that helps people get to REALLY KNOW you";
        self.label1.font = [[Theme current] headlineFontWithSize:42];

        self.label2.text = @"TELL STORIES with videos, photos, text, and drawings";
        self.label2.font = [[Theme current] headlineFontWithSize:44];

        self.label3.text = @"CONNECT and CHAT with REAL PEOPLE near you";
        self.label3.font = [[Theme current] headlineFontWithSize:46];

        self.label4.text = @"make any story PRIVATE or visible only to FRIENDS";
        self.label4.font = [[Theme current] headlineFontWithSize:44];

        self.label1Color = COLOR(whiteColor);
        self.label2Color = COLOR(greenColor);
        self.label3Color = COLOR(orangeColor);
        self.label4Color = COLOR(purpleColor);

        for (PNLabel* label in @[self.label1, self.label2, self.label3, self.label4]) {
            label.textColor = COLOR(whiteColor);

            // Set line spacing
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:label.text];
            NSInteger strLength = [attrString length];
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            [style setLineSpacing:20];
            [attrString addAttribute:NSParagraphStyleAttributeName
                               value:style
                               range:NSMakeRange(0, strLength)];
            label.attributedText = attrString;

            [label makeInvisible];
            [self addSubview:label];
        }

        self.button = [[ArrowButton alloc] initWithFrame:CGRectZero];
        self.button.titleLabel.font = FONT_B(21);
        [self.button setTitle:@"Get Started" forState:UIControlStateNormal];
        self.button.arrowColor = COLOR(turquoiseColor);
        self.button.leftArrowWidth = -20;
        self.button.rightArrowWidth = 20;
        [self.button addTarget:self action:@selector(onOkay) forControlEvents:UIControlEventTouchUpInside];
        self.button.alpha = 0.0;
        [self addSubview:self.button];

        [self.leftButton setTitle:@"Login" forState:UIControlStateNormal];
    }

    return self;
}

- (NSNumberFormatter*) numberFormatter {
    static NSNumberFormatter* formatter;
    if (!formatter) {
        formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
        [formatter setRoundingIncrement:@(1)];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        [formatter setAlwaysShowsDecimalSeparator:NO];
        [formatter setUsesGroupingSeparator:YES];
    }
    return formatter;
}

- (void)updateText {

}

- (void)performTextTransitions {

    BOOL (^checkForCancel)() = ^() {
        if (_cancelTransitions) {
            [self.label1 makeInvisible];
            [self.label2 makeInvisible];
            [self.label3 makeInvisible];
            [self.label4 makeInvisible];
            _cancelTransitions = NO;
            return YES;
        }
        return NO;
    };

    void (^transition4to1)() = ^() {
        if (checkForCancel()) return;
        [self.label4 fadeOutOverDuration:1.0
                               fromColor:nil
                              completion:^{
                                  if (checkForCancel()) return;
                                  [self.label1 fadeInOverDuration:1.5
                                                          toColor:self.label1Color
                                                       completion:^{
                                                           [self updateText];
                                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                               [self performTextTransitions];
                                                           });
                                                       }
                                                       afterDelay:0.0];
                              }];
    };

    void (^transition3to4)() = ^() {
        if (checkForCancel()) return;
        [self.label3 fadeOutOverDuration:1.0
                               fromColor:nil
                              completion:^{
                                  if (checkForCancel()) return;
                                  [self.label4 fadeInOverDuration:1.5
                                                          toColor:self.label4Color
                                                       completion:^{
                                                           transition4to1();
                                                       }
                                                       afterDelay:4.0];
                              }];
    };

    void (^transition2to3)() = ^() {
        if (checkForCancel()) return;
        [self.label2 fadeOutOverDuration:1.0
                               fromColor:nil
                              completion:^{
                                  if (checkForCancel()) return;
                                  [self.label3 fadeInOverDuration:1.5
                                                          toColor:self.label3Color
                                                       completion:^{
                                                           transition3to4();
                                                       }
                                                       afterDelay:4.0];
                              }];
    };

    void (^transition1to2)() = ^() {
        if (checkForCancel()) return;
        [self.label1 fadeOutOverDuration:1.0
                               fromColor:nil
                              completion:^{
                                  if (checkForCancel()) return;
                                  [self.label2 fadeInOverDuration:1.5
                                                          toColor:self.label2Color
                                                       completion:^{
                                                           transition2to3();
                                                       }
                                                       afterDelay:4.0];
                              }];
    };

    transition1to2();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    CGFloat m = 4; // <-- margin

    CGFloat buttonHeight = 56;

    self.videoView.frame = b;

    self.topStrip.frame = CGRectMake(0,self.yOffset, b.size.width, 65);

    CGRect lbf = CGRectMake(0,0, CGRectGetHeight(self.topStrip.frame)-2*m, CGRectGetHeight(self.topStrip.frame)-2*m);
    self.leftButton.frame = CGRectSetOrigin(m, m, lbf);

    CGFloat bottom = self.visibleRect.size.height;
    self.button.frame = CGRectMakeCorners(10, bottom-buttonHeight-10, b.size.width-10, bottom-10);

    self.label1.frame = CGRectMakeCorners(0, (1-1.f/GOLDEN_MEAN)*b.size.height, b.size.width, CGRectGetMinY(self.button.frame));
    self.label1.frame = CGRectInset(self.label1.frame, 10, 20);

    self.label2.frame = self.label1.frame;
    self.label3.frame = self.label1.frame;
    self.label4.frame = self.label1.frame;
}

- (void)onOkay {
    self.button.enabled = NO;
    [[PNUserPreferences shared] setPreference:@"welcome_completed" boolValue:YES];

    on_main_async(^{
        [self gotoNextPanel];
        self.button.enabled = YES;
    });
}

- (void) dealloc {
}

//- (void)rightButtonTapped {
//    [[PNUserPreferences shared] setPreference:@"welcome_completed" boolValue:YES];
//    [super rightButtonTapped];
//}

@end
