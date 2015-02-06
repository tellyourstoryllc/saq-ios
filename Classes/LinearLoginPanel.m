//
//  LinearLoginPanel.m
//  NoMe
//
//  Created by Jim Young on 11/22/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearLoginPanel.h"
#import "Api.h"
#import "App.h"
#import "User.h"
#import "AppViewController.h"
#import "StatusView.h"
#import "SecretViewController.h"
#import "PNFacebookAdapter.h"
#import "AlertView.h"
#import "PNUserPreferences.h"
#import "SSKeychain.h"
#import "PushPermissionManager.h"
#import "DefaultWelcomePanel.h"

#import "BackgroundCamera.h"
#import "UILabel+FadeEffect.h"

@interface LinearLoginPanel() <UITextFieldDelegate, RTLabelDelegate>

@property (nonatomic,strong) PNView* formContainer;
@property (nonatomic,strong) PNLabel* titleLabel;

@property (strong, nonatomic) PNTextField *emailTextField;
@property (strong, nonatomic) PNTextField *passwordTextField;
@property (strong, nonatomic) PNButton *loginButton;

@property (strong, nonatomic) PNButton* forgotPassButton;

@property (strong, nonatomic) BackgroundCamera *cam;

@end

@implementation LinearLoginPanel

- (void)didAppear {
    [super didAppear];
    self.emailTextField.text = [App username];

    if (![self.passwordTextField isFirstResponder])
        [self.emailTextField becomeFirstResponder];

    [self.cam startPreview];
}

- (void)didDisappear {
    [super didDisappear];
    [self endEditing:YES];
}

-(BOOL)isNeeded {
    return ![App isLoggedIn];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.multipleTouchEnabled = YES; // Required for accessing the secret admin menu
        self.backgroundView.multipleTouchEnabled = YES;

        self.cam = [[BackgroundCamera alloc] initWithFrame:CGRectZero];
        self.cam.alpha = 0.2;
        [self addSubview:self.cam];

        self.titleLabel = [PNLabel labelWithText:@"login" andFont:self.headerFont];
        [self addSubview:self.titleLabel];

        self.formContainer = [[PNView alloc] init];
        self.formContainer.clipsToBounds = YES;
        [self addSubview:self.formContainer];

        self.loginButton = [[PNButton alloc] init];
        [self.loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        self.loginButton.titleLabel.font = FONT_B(24);
        [self.loginButton addTarget:self action:@selector(onLogin) forControlEvents:UIControlEventTouchUpInside];
        self.loginButton.buttonColor = COLOR(turquoiseColor);
        self.loginButton.enabled = YES; // fixme
        [self addSubview:self.loginButton];

        self.emailTextField = [[PNTextField alloc] initWithFrame:CGRectZero];
        self.emailTextField.font = FONT(21);
        self.emailTextField.backgroundColor = COLOR(whiteColor);
        self.emailTextField.textColor = COLOR(darkGrayColor);
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address"
                                                                                    attributes:@{NSForegroundColorAttributeName:[COLOR(darkGrayColor) colorWithAlphaComponent:0.5]}];
        self.emailTextField.horizontalInset = 5;
        self.emailTextField.textAlignment = NSTextAlignmentCenter;
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyNext;

        //        self.emailTextField.font = [[Theme current] boldFontWithSize:18];
        self.emailTextField.verticalInset = 5;
        self.emailTextField.delegate = self;
        [self.formContainer addChild:self.emailTextField];

        self.passwordTextField = [[PNTextField alloc] initWithFrame:CGRectZero];
        self.passwordTextField.font = FONT(21);
        self.passwordTextField.backgroundColor = COLOR(whiteColor);
        self.passwordTextField.textColor = COLOR(darkGrayColor);
        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                                       attributes:@{NSForegroundColorAttributeName:[COLOR(darkGrayColor) colorWithAlphaComponent:0.5]}];
        self.passwordTextField.horizontalInset = 5;
        self.passwordTextField.secureTextEntry = YES;
        self.passwordTextField.textAlignment = NSTextAlignmentCenter;
        self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordTextField.returnKeyType = UIReturnKeyGo;
        //        self.passwordTextField.font = [[Theme current] boldFontWithSize:18];
        self.passwordTextField.verticalInset = 5;
        self.passwordTextField.delegate = self;
        [self.formContainer addChild:self.passwordTextField];

        self.forgotPassButton = [PNButton new];
        [self.forgotPassButton setTitle:@"Forgot Password" forState:UIControlStateNormal];
        [self.forgotPassButton setTitleColor:COLOR(blueColor) forState:UIControlStateNormal];
        [self.forgotPassButton addTarget:self action:@selector(onForgotPass) forControlEvents:UIControlEventTouchUpInside];
        self.forgotPassButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.forgotPassButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.forgotPassButton.titleLabel.font = FONT_B(12);
        [self addSubview:self.forgotPassButton];

        [self.rightButton setTitle:@"Register" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:COLOR(blueColor) forState:UIControlStateNormal];
        self.rightButton.titleLabel.font = FONT(23);
        self.rightButton.buttonColor = [UIColor clearColor];
        self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
        self.rightButton.titleLabel.font = FONT_B(12);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

    }
    return self;
}

- (void)didBecomeActive {
    [self setNeedsLayout];
    self.loginButton.enabled = YES;
}

- (void)keyboardDidBecomeVisible:(BOOL)visible viewFrame:(CGRect)viewFrame keyboardFrame:(CGRect)keyboardFrame {
    [super keyboardDidBecomeVisible:visible viewFrame:viewFrame keyboardFrame:keyboardFrame];
    CGFloat bottom = keyboardFrame.origin.y;
    self.loginButton.frame = CGRectMakeCorners(0, bottom-50, keyboardFrame.size.width, bottom);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat formWidth = b.size.width;
    CGFloat fieldHeight = 44;

    self.cam.frame = b;

    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 10, self.titleLabel.frame);

    self.emailTextField.frame = CGRectMake(0, 0, formWidth, fieldHeight);
    self.passwordTextField.frame = CGRectOffset(self.emailTextField.frame, 0, CGRectGetHeight(self.emailTextField.frame)+10);

    CGFloat bottom = self.visibleRect.size.height;

    self.loginButton.frame = CGRectMakeCorners(0, bottom-60, b.size.width, bottom);

    self.forgotPassButton.frame = CGRectMake(0, 0, b.size.width/2, 24);
    self.forgotPassButton.frame = CGRectSetBottomLeft(0, CGRectGetMinY(self.loginButton.frame), self.forgotPassButton.frame);

    self.rightButton.frame = CGRectSetBottomRight(b.size.width, CGRectGetMaxY(self.forgotPassButton.frame), self.forgotPassButton.frame);

    [self.formContainer sizeToFit];
    self.formContainer.center = CGPointMake(b.size.width/2, (CGRectGetMaxY(self.titleLabel.frame)+CGRectGetMinY(self.forgotPassButton.frame))/2);

    [self adjustBackgroundSize];
}

- (void) onForgotPass {
    NSLog(@"FORGOT MY PASSWORD!");
}

- (void) onLogin {

    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    if (email.length == 0 || password.length == 0)
        return;

    void (^finishedWithSuccess)(BOOL) = ^(BOOL success) {
        on_main(^{
            if (success) {
                self.passwordTextField.text = nil;

                [[AppViewController sharedAppViewController] checkinUsingFastApi:YES callback:^(NSError *error) {
                    on_default(^{
                        [StatusView dismiss];
                    });
                }];

                [[PushPermissionManager manager] requestWithCompletion:^(NSData *token) {
                    PNLOG(@"login_existing_user");
                    if ([self.controller valueForKey:@"forceNewUserFunnel"]) {
                        [[PNUserPreferences shared] setPreference:@"welcome_completed" boolValue:NO];
                        [self gotoNextPanel];
                    }
                    else {
                        [[PNUserPreferences shared] setPreference:@"welcome_completed" boolValue:YES];
                        [self exitRegistration];
                    }
                }];

            } else {
                [StatusView showTitle:@"Unable to Log In" message:nil completion:nil duration:2];
            }

            _loginButton.enabled = YES;
        });
    };

    [StatusView showTitle:@"Logging in..." message:nil completion:nil];
    _loginButton.enabled = NO;

    [[Api fastApi] postPath:@"/login"
                 parameters:@{
                              @"login":email,
                              @"password":password
                              }
                   callback:[[Api fastApi]
                             authCallbackWithCompletion:^(BOOL success, NSError *error) {
                                 if (success) {
                                     finishedWithSuccess(YES);
                                 } else {
                                     NSLog(@"Error logging in: %@", error);
                                     finishedWithSuccess(NO);
                                 }
                             }]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self onLogin];
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count >= 2) {
        CGRect b = self.bounds;
        CGRect t1 = CGRectMake(0,0,120,320);
        CGRect t2 = CGRectSetTopRight(b.size.width, 0, t1);

        BOOL t1hit = NO;
        BOOL t2hit = NO;

        for (UITouch* touch in touches) {
            if (CGRectContainsPoint(t1, [touch locationInView:self])) t1hit = YES;
            if (CGRectContainsPoint(t2, [touch locationInView:self])) t2hit = YES;
        }
        if (t1hit && t2hit)
            [self enableAdminMenu];
    }

    [super touchesEnded:touches withEvent:event];
}

- (void)doForgotPassword {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Reset Password"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Submit",nil];
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.placeholder = @"Your email";
    [alert show];
}

- (void)enableAdminMenu {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"HELLO FRIEND" message:@"What's the secret phrase?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"API Server", @"Login+", nil];
    alert.tag = 0;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == alertView.cancelButtonIndex)
        return;

    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            NSString *text;
            if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
                UITextField *textField = [alertView textFieldAtIndex:0];
                text = textField.text;

                if ([text isEqualToString:kAdminPhrase]) {
                    SecretViewController* secret = [[SecretViewController alloc] init];
                    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:secret];
                    [self.controller presentViewController:nav animated:YES completion:nil];
                }
            }
        }
        else if (buttonIndex == 2) {
            [self.controller setValue:@(YES) forKey:@"forceNewUserFunnel"]; // <-- shitty hack
            [self onLogin];
        }
    }
    else if (alertView.tag == 1) {
        NSString *regex = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString* text = textField.text;
        if (text.length == 0) {
            //
        }
        else if (![text isMatchedByRegex:regex]) {
            [StatusView showTitle:@"Error"
                          message:[NSString stringWithFormat:@"%@ is not a valid email address", text]
                       completion:nil
                         duration:3
             ];
        }
        else {
            [[Api sharedApi] postPath:@"/password/reset_email"
                           parameters:@{@"login":text}
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 if (error) {
                                     [AlertView showWithTitle:@"Error"
                                                   andMessage:[NSString stringWithFormat:@"We were unable to locate the account for %@", text]
                                      ];
                                 }
                                 else {
                                     [AlertView showWithTitle:nil
                                                   andMessage:@"Instructions for resetting your password will be sent to your email."
                                      ];
                                 }
                             }];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
