//
//  ResetPasswordPhonePanel.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ResetPasswordPhonePanel.h"
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

#import "UILabel+FadeEffect.h"

@interface ResetPasswordPhonePanel() <UITextFieldDelegate>

@property (nonatomic,strong) PNView* formContainer;

@property (strong, nonatomic) PNTextField *emailTextField;
@property (strong, nonatomic) PNTextField *passwordTextField;
@property (strong, nonatomic) PNButton *loginButton;

@property (strong, nonatomic) PNLabel *noticeLabel;
@property (strong, nonatomic) PNRichLabel* tosLabel;
@property (strong, nonatomic) PNRichLabel* blurbLabel;

@property (strong, nonatomic) UIView *topStrip;
@property (nonatomic, strong) UIImageView* logoView;

@property (assign, nonatomic) CGFloat yOffset;

@end

@implementation ResetPasswordPhonePanel

- (void)didAppear {
    [super didAppear];
    self.emailTextField.text = [App username];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (![self.passwordTextField isFirstResponder])
            [self.emailTextField becomeFirstResponder];
    });
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

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(defaultNavigationColor);
        [self addSubview:self.topStrip];

        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-biglogo"]];
        [self.logoView sizeToFit];
        [self addSubview:self.logoView];

        [self bringSubviewToFront:self.leftButton];

        self.formContainer = [[PNView alloc] init];
        self.formContainer.clipsToBounds = YES;
        [self addSubview:self.formContainer];

        self.loginButton = [[PNButton alloc] init];
        [self.loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        self.loginButton.titleLabel.font = FONT_B(24);
        [self.loginButton addTarget:self action:@selector(doSnapchatLogin) forControlEvents:UIControlEventTouchUpInside];
        self.loginButton.buttonColor = COLOR(greenColor);
        [self addSubview:self.loginButton];

        self.emailTextField = [[PNTextField alloc] initWithFrame:CGRectZero];
        self.emailTextField.font = FONT(30);
        self.emailTextField.textColor = COLOR(darkGrayColor);
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Snapchat Username"
                                                                                    attributes:@{NSForegroundColorAttributeName:[COLOR(darkGrayColor) colorWithAlphaComponent:0.5]}];
        self.emailTextField.horizontalInset = 5;
        self.emailTextField.textAlignment = NSTextAlignmentCenter;
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeDefault;
        self.emailTextField.returnKeyType = UIReturnKeyNext;

        //        self.emailTextField.font = [[Theme current] boldFontWithSize:18];
        self.emailTextField.verticalInset = 5;
        self.emailTextField.delegate = self;
        [self.formContainer addChild:self.emailTextField];

        self.passwordTextField = [[PNTextField alloc] initWithFrame:CGRectZero];
        self.passwordTextField.font = FONT(30);
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

        self.tosLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.tosLabel.textColor = COLOR(darkGrayColor);
        self.tosLabel.textAlignment = RTTextAlignmentCenter;
        self.tosLabel.font = FONT(11);
        self.tosLabel.text = [NSString stringWithFormat:@"By using this service you acknowledge and accept the<br><a href='%@'><font color='#c399c7'>Terms of Service & Privacy Policy</font></a>", kTermsOfServiceURL];
        [self addSubview:self.tosLabel];

        self.blurbLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.blurbLabel.textColor = COLOR(darkGrayColor);
        self.blurbLabel.textAlignment = RTTextAlignmentCenter;
        self.blurbLabel.font = FONT(11);
        self.blurbLabel.text = [NSString stringWithFormat:@"By signing up you acknowledge and accept the<br><a href='%@'><font color='#c399c7'>Terms of Service & Privacy Policy</font></a>", kTermsOfServiceURL];
        self.blurbLabel.hidden = YES;
        [self addSubview:self.blurbLabel];

        self.noticeLabel = [PNLabel labelWithText:@"Your password is stored only on your device and used to login to Snapchat." andFont:FONT(13)];
        self.noticeLabel.textColor = COLOR(grayColor);
        self.noticeLabel.textAlignment = NSTextAlignmentCenter;
        [self.noticeLabel sizeToFitTextWidth:300];
        [self addSubview:self.noticeLabel];

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
    self.noticeLabel.hidden = CGRectIntersectsRect(keyboardFrame, self.frame);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat m = 10;
    CGFloat formWidth = b.size.width-20;
    CGFloat fieldHeight = 54;

    self.topStrip.frame = CGRectMake(0,self.yOffset, b.size.width, 60);

    self.logoView.center = self.topStrip.center;

    CGRect lbf = CGRectMake(0,0, CGRectGetHeight(self.topStrip.frame)-2*m, CGRectGetHeight(self.topStrip.frame)-2*m);
    self.leftButton.frame = CGRectSetOrigin(m, m, lbf);

    self.emailTextField.frame = CGRectMake(0, 0, formWidth, fieldHeight);
    self.passwordTextField.frame = CGRectOffset(self.emailTextField.frame, 0, CGRectGetHeight(self.emailTextField.frame));

    CGFloat bottom = self.visibleRect.size.height;

    self.loginButton.frame = CGRectMakeCorners(0, bottom-60, b.size.width, bottom);

    self.tosLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.loginButton.frame)-4, CGRectMake(0, 0, b.size.width, 30));
    self.noticeLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.loginButton.frame)-4, self.noticeLabel.frame);

    self.tosLabel.hidden = !self.noticeLabel.hidden;

    self.blurbLabel.frame = CGRectMakeCorners(0, CGRectGetMaxY(self.topStrip.frame), CGRectGetMinY(self.tosLabel.frame), b.size.width);

    [self.formContainer sizeToFit];
    self.formContainer.center = CGPointMake(b.size.width/2, (CGRectGetMaxY(self.topStrip.frame)+CGRectGetMinY(self.noticeLabel.frame))/2);

    [self adjustBackgroundSize];
}

- (void) doLogin {

    NSString *name = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    if (name.length == 0 || password.length == 0)
        return;

    // ============== Step 4: Done ==============
    void (^finishedWithSuccess)(BOOL) = ^(BOOL success) {
        on_main(^{
            if (success) {
                self.passwordTextField.text = nil;

                [[AppViewController sharedAppViewController] checkinUsingFastApi:YES callback:^(NSError *error) {
                    [StatusView dismiss];
                    [self exitRegistration];
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
                              @"login":name,
                              @"password":password
                              }
                   callback:[[Api fastApi]
                             authCallbackWithCompletion:^(BOOL success, NSError *error) {
                                 if(success) {
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
        [self doLogin];
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
            [self doLogin];
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
