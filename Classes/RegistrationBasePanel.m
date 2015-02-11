//
//  RegistrationPanel.m
//  groups
//
//  Created by Jim Young on 11/28/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "RegistrationBasePanel.h"
#import "Api.h"
#import "App.h"
#import "PNUserPreferences.h"
#import "AlertView.h"
#import "AppViewController.h"
#import "PNMessageComposeViewController.h"
#import "User.h"
#import "PNProgress.h"

#import "Directory.h"

#import "UIView+HideAnimation.h"
#import "UILabel+FadeEffect.h"

@interface RegistrationBasePanel()
@end

@implementation RegistrationBasePanel

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundView = [[UIView alloc] init];
    [self addSubview:self.backgroundView];
    return self;
}

- (PNButton*)leftButton {
    if (!_leftButton) {
        _leftButton = [[PNButton alloc] init];
        [self addSubview:_leftButton];
        _leftButton.buttonColor = [UIColor clearColor];

        [_leftButton setDisabledColor:COLOR_ALPHA(lightGrayColor, 0.5)];
        [_leftButton addTarget:self action:@selector(leftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (PNButton*)rightButton {
    if (!_rightButton) {
        _rightButton = [[PNButton alloc] init];
        [self addSubview:_rightButton];
        _rightButton.buttonColor = COLOR(greenColor);
        [_rightButton setDisabledColor:COLOR_ALPHA(lightGrayColor, 0.5)];
        [_rightButton addTarget:self action:@selector(rightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (void) leftButtonTapped {
    [self gotoPreviousPanel];
}

- (void) rightButtonTapped {
    [self gotoNextPanel];
}

- (BOOL)gotoNextPanel {
    BOOL success = [super gotoNextPanel];
    if (!success)
        [self exitRegistration];
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect b = self.bounds;
    CGFloat margin = 10;
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = 40;

    if (_leftButton) {
        _leftButton.frame = CGRectSetBottomLeft(margin, b.size.height-margin, CGRectMake(0,0,buttonWidth,buttonHeight));
    }

    if (_rightButton) {
        _rightButton.frame = CGRectSetBottomRight(b.size.width-margin, b.size.height-margin, CGRectMake(0,0,buttonWidth,buttonHeight));
    }

}

- (void) didAppear {
    [super didAppear];
    if ([[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference]) {
        // Appearance for dev server
        [self.backgroundView setBackgroundColor:COLOR(pinkColor)];
    }
    else {
        // Appearance for prod server
        [self.backgroundView setBackgroundColor:COLOR(defaultBackgroundColor)];
    }
}

- (void) adjustBackgroundSize {
    // Figure out how big of a background image to draw.
    CGRect b = self.bounds;
    CGFloat minY = b.size.height;
    for (UIView* view in self.subviews) {
        if (view == self.backgroundView) continue;
        if (CGRectIsEmpty(view.frame)) continue;
        CGFloat curY = CGRectGetMinY(view.frame);
        if (curY < minY) minY = curY;
    }
    self.backgroundView.frame = CGRectMake(0, minY-5, b.size.width, b.size.height-minY+5);
}

- (CGRect)buttonValley {
    CGRect b = self.bounds;
    CGFloat minX, maxX, minY, maxY;
    minX = _leftButton ? CGRectGetMaxX(_leftButton.frame) : 0;
    maxX = _rightButton ? CGRectGetMinX(_rightButton.frame) : b.size.width;
    minY = CGRectGetMinY(_leftButton.frame) ?: CGRectGetMinY(_rightButton.frame);
    maxY = b.size.height;
    return CGRectMake(minX, minY, maxX-minX, maxY-minY);
}

- (void) phoneVerificationWithCompletion:(void (^)(BOOL sent, BOOL denied))completion {

    NSString* destination = [Configuration stringFor:@"phone_verification_destination"];
    NSString* token = [[[User me] json] objectForKey:@"phone_verification_token"];
    if ([PNSupport deviceCanSMS] && destination && token) {

        PNMessageComposeViewController* messageController = [[PNMessageComposeViewController alloc] init];
        [messageController setRecipients:@[destination]];

        NSString* bodyFormat = [Configuration stringFor:@"phone_verification_body"] ?: @"Verification code: %@";
        NSString* body = [NSString stringWithFormat:bodyFormat, token];
        [messageController setBody:body];
        [messageController setCompletion:^(MessageComposeResult result) {
            if (result == MessageComposeResultSent) {
                PNLOG(@"noob.sms_verification.sent");
                if (completion) completion(YES, NO);
            }
            else {
                PNLOG(@"noob.sms_verification.unsent");
                if (completion) completion(NO, YES);
            }
        }];

        AlertView* alert = [[AlertView alloc] initWithTitle:@"Verification"
                                                    message:@"Tap SEND on the next screen to verify your registration."
                                             andButtonArray:@[@"OK"]
                            ];

        [alert showWithCompletion:^(NSInteger buttonIndex) {
            [[AppViewController sharedAppViewController] presentViewController:messageController
                                                                      animated:YES
                                                                    completion:nil];
        }];

    }
    else {
        PNLOG(@"noob.sms_verification.not_applicable");
        if (completion) completion(NO, NO);
    }
}

- (void)createUserWithCompletion:(void (^)(BOOL success, NSError *error))completion {

    on_main(^{
        [self endEditing:YES];
    });

    NSMutableDictionary* params = [NSMutableDictionary new];

    [params setValue:[self.controller valueForKey:@"email"] forKey:@"email"];
    [params setValue:[self.controller valueForKey:@"password"] forKey:@"password"];
    [params setValue:[self.controller valueForKey:@"birthdate"] forKey:@"birthday"];
    [params setValue:[self.controller valueForKey:@"gender"] forKey:@"gender"];

    CLLocation* loc = [self.controller valueForKey:@"location"];
    if (loc) {
        [params setValue:@(loc.coordinate.latitude) forKey:@"latitude"];
        [params setValue:@(loc.coordinate.longitude) forKey:@"longitude"];
        [params setValue:[self.controller valueForKey:@"locationName"] forKey:@"location_name"];
    }

    [params setValue:[self.controller valueForKey:@"username"] forKey:@"username"];
    [params setValue:[self.controller valueForKey:@"phoneNumber"] forKey:@"phoneNumber"];
    [params setValue:[self.controller valueForKey:@"phoneVerification"] forKey:@"phoneVerification"];

    [[Api fastApi] postPath:@"/users/create"
                   parameters:params
                     callback:[[Api fastApi] authCallbackWithCompletion:^(NSSet *entities, id responseObject, NSError *error, BOOL success) {
        if (success) {
            PCLOG(@"noob.create_account.success");
            if (completion) completion(YES, nil);
        }
        else {
            PCLOG(@"noob.create_account.fail");
            if (completion) completion(NO, error);
        }
        //
    }]];
}

- (void) exitRegistration {
    [[AppViewController sharedAppViewController] resetUI];
}

- (UIFont *) headerFont {
    return [UIFont fontWithName:@"OstrichSansRounded-Medium" size:36];
}

@end
