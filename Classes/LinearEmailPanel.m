//
//  LinearInitialPanel.m
//  groups
//
//  Created by Jim Young on 2/11/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
#import "LinearEmailPanel.h"
#import "Api.h"
#import "App.h"
#import "AppViewController.h"
#import "StatusView.h"
#import "AlertView.h"
#import "Configuration.h"
#import "UIView+PNAnimations.h"
#import "VideoURLView.h"

@interface LinearEmailPanel()<UITextFieldDelegate>

@property (nonatomic,strong) PNLabel* titleLabel;
@property (nonatomic,strong) PNLabel* subtitle;

@property (nonatomic,strong) PNTextField* emailField;
@property (nonatomic,strong) PNTextField* passwordField;

@property (nonatomic,strong) PNButton* doneButton;

@property (nonatomic, strong) VideoURLView* videoView;
@property (nonatomic, strong) UIImageView* overlayView;
@property (nonatomic, strong) UIView* maskView;

@end

@implementation LinearEmailPanel

- (BOOL)isNeeded {
    return [self.controller valueForKey:@"videoFileURL"] ? YES : NO;
}

- (void)didAppear {
    [super didAppear];
    [self.emailField becomeFirstResponder];

    NSURL* videoUrl = [self.controller valueForKey:@"videoFileURL"];
    if (videoUrl) {
        self.videoView.videoUrl = videoUrl;
        [self.videoView play];
    }

    self.overlayView.image = [self.controller valueForKey:@"videoOverlay"];
    self.maskView.backgroundColor = [COLOR(whiteColor)colorWithAlphaComponent:0.95];

}

- (void)didDisappear {
    [super didDisappear];
    [self updateInputs];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.videoView = [[VideoURLView alloc] initWithFrame:self.bounds];
        self.videoView.muted = YES;
        self.videoView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.videoView];

        self.overlayView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.overlayView];

        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.maskView];

        self.titleLabel = [PNLabel labelWithText:@"please register" andFont:self.headerFont];
        [self addSubview:self.titleLabel];

        self.subtitle = [PNLabel labelWithText:@"Your email address is 100% private.\nIt is never shared with others." andFont:FONT(13)];
        self.subtitle.textAlignment = NSTextAlignmentCenter;
        self.subtitle.textColor = COLOR(grayColor);
        [self addSubview:self.subtitle];

        self.emailField = [[PNTextField alloc] init];
        self.emailField.font = FONT_B(18);
        self.emailField.textColor = COLOR(darkGrayColor);
        self.emailField.backgroundColor = COLOR(orangeColor);
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address"
                                                                                attributes:@{NSForegroundColorAttributeName:COLOR(lightGrayColor)}];
        self.emailField.horizontalInset = 25;
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.returnKeyType = UIReturnKeyNext;
        self.emailField.textAlignment = NSTextAlignmentCenter;
        self.emailField.delegate = self;
        [self addSubview:self.emailField];

        self.passwordField = [[PNTextField alloc] init];
        self.passwordField.font = FONT_B(18);
        self.passwordField.backgroundColor = COLOR(orangeColor);
        self.passwordField.textColor = COLOR(whiteColor);
        self.passwordField.secureTextEntry = YES;
        self.passwordField.placeholder = @"New Password";
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New Password"
                                                                                attributes:@{NSForegroundColorAttributeName:COLOR(lightGrayColor)}];
        self.passwordField.horizontalInset = 25;
        self.passwordField.returnKeyType = UIReturnKeyNext;
        self.passwordField.textAlignment = NSTextAlignmentCenter;
        self.passwordField.delegate = self;
        [self addSubview:self.passwordField];

        self.doneButton = [[PNButton alloc] init];
        [self.doneButton setTitle:@"Next" forState:UIControlStateNormal];
        self.doneButton.titleLabel.font = FONT_B(21);
        self.doneButton.buttonColor = COLOR(turquoiseColor);
        [self.doneButton addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.doneButton];

    }

    return self;
}

- (void) keyboardDidBecomeVisible:(BOOL)visible viewFrame:(CGRect)viewFrame keyboardFrame:(CGRect)keyboardFrame {
    [super keyboardDidBecomeVisible:visible viewFrame:viewFrame keyboardFrame:keyboardFrame];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    CGRect viz = [self visibleRect];

    self.videoView.frame = viz;
    self.overlayView.frame = viz;
    self.maskView.frame = viz;

    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 10, self.titleLabel.frame);

    [self.subtitle sizeToFitTextWidth:b.size.width];
    self.subtitle.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMaxY(viz)-12, self.subtitle.frame);

    CGRect bb = CGRectMakeCorners(0, CGRectGetMaxY(self.titleLabel.frame), b.size.width, CGRectGetMinY(self.subtitle.frame));

    CGFloat goldenY = bb.origin.y + bb.size.height*(1.f - 1.f/GOLDEN_MEAN);

    CGFloat buttonWidth = b.size.width;
    CGFloat buttonHeight = 44;

    self.emailField.frame = CGRectSetCenter(b.size.width/2, goldenY, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.passwordField.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.emailField.frame)+10, CGRectMake(0, 0, buttonWidth, buttonHeight));

    [self adjustBackgroundSize];

    self.doneButton.frame = CGRectMake(0, 60, b.size.width, 60);
    [self updateDoneButtonWithAnimation:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Actions

- (void)onEmailDone {

    NSArray* errors = [self formErrors];
    if (errors.count) {
        [AlertView showWithTitle:@"Please correct before continuing:" andMessage:[errors componentsJoinedByString:@" "]];
        return;
    }
    else {
        [self.controller setValue:[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"email"];
        [self.passwordField becomeFirstResponder];
    }
}

- (BOOL)checkEmailString:(NSString *)string {
    NSString *regex = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    if ([string isMatchedByRegex:regex]) {
        self.emailField.textColor = COLOR(whiteColor);
        self.emailField.backgroundColor = COLOR(turquoiseColor);
        return YES;
    } else {
        self.emailField.textColor = COLOR(whiteColor);
        self.emailField.backgroundColor = COLOR(orangeColor);
        return NO;
    }
}

- (BOOL)checkPasswordString:(NSString *)string {
    if (string.length >= 6) {
        self.passwordField.textColor = COLOR(whiteColor);
        self.passwordField.backgroundColor = COLOR(turquoiseColor);
        return YES;
    } else {
        self.passwordField.textColor = COLOR(whiteColor);
        self.passwordField.backgroundColor = COLOR(orangeColor);
        return NO;
    }
}

- (void)onNext {
    if ([self updateInputs])
        [self gotoNextPanel];
}

- (NSArray*)formErrors {
    NSMutableArray* errors = [NSMutableArray arrayWithCapacity:2];
    if (self.emailField.text.length == 0)
        [errors addObject:@"Enter your email address."];
    else if (![self checkEmailString:self.emailField.text])
        [errors addObject:@"Invalid email address."];
    return errors;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    if (textField == self.emailField) {
        [self checkEmailString:newString];
    }
    else if (textField == self.passwordField) {
        [self checkPasswordString:newString];
    }

    NSString *regex = @"\\s";

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateDoneButtonWithAnimation:YES];
    });

    return ![newString isMatchedByRegex:regex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        if ([self checkEmailString:self.emailField.text]) {
            [self onEmailDone];
        }
        else {
            [StatusView showTitle:@"Invalid email address" message:nil completion:nil duration:2];
        }
    }
    else if (textField == self.passwordField) {
        [self onNext];
    }
    return NO;
}

- (BOOL)updateInputs {
    if ([self checkEmailString:self.emailField.text] && [self checkPasswordString:self.passwordField.text]) {
        [self.controller setValue:self.emailField.text forKey:@"email"];
        [self.controller setValue:self.passwordField.text forKey:@"password"];
        return YES;
    }
    else
        return NO;
}

- (void)updateDoneButtonWithAnimation:(BOOL)animate {
    CGFloat bottom = self.visibleRect.size.height;

    void (^block)() = ^() {
        self.doneButton.frame = [self updateInputs] ? CGRectSetBottomLeft(0, bottom, self.doneButton.frame) : CGRectSetBottomRight(0,bottom, self.doneButton.frame);
    };

    if (animate) {
        [UIView animateWithDuration:0.6 animations:block];
    }
    else
        block();
}

- (void)dealloc {
    [self removeKeyboardControl];
}

@end
