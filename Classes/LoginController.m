//
//  LoginController.m
//  TellYourStory
//
//  Created by Jim Young on 2/9/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "LoginController.h"
#import "Api.h"
#import "DAKeyboardControl.h"

@interface LoginController()<UITextFieldDelegate>

@property (nonatomic,strong) PNTextField* usernameField;
@property (nonatomic,strong) PNTextField* passwordField;

@property (nonatomic,strong) PNButton* doneButton;

@property (nonatomic, assign) BOOL isValidName;
@property (nonatomic, strong) PNLabel* feedbackLabel;

@end

@implementation LoginController

- (void)viewDidLoad
{
    UIFont* placeholderFont = FONT_I(18);

    self.feedbackLabel = [PNLabel new];
    self.feedbackLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackLabel.textColor = COLOR(redColor);
    self.feedbackLabel.font = FONT_B(16);
    [self.view addSubview:self.feedbackLabel];

    self.usernameField = [[PNTextField alloc] init];
    self.usernameField.font = FONT_B(18);
    self.usernameField.textColor = COLOR(blackColor);
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username"
                                                                               attributes:@{NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                                                                            NSFontAttributeName : placeholderFont}];
    self.usernameField.horizontalInset = 25;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.keyboardType = UIKeyboardTypeAlphabet;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.delegate = self;
    [self.view addSubview:self.usernameField];

    self.passwordField = [[PNTextField alloc] init];
    self.passwordField.font = FONT_B(18);
    self.passwordField.textColor = COLOR(blackColor);
    self.passwordField.secureTextEntry = YES;
    self.passwordField.placeholder = @"New Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                               attributes:@{NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                                                                            NSFontAttributeName : placeholderFont}];
    self.passwordField.horizontalInset = 25;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.delegate = self;
    [self.view addSubview:self.passwordField];

    self.doneButton = [[PNButton alloc] init];
    [self.doneButton setTitle:@"Sign In" forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = FONT_B(21);
    self.doneButton.buttonColor = COLOR(turquoiseColor);
    [self.doneButton addTarget:self action:@selector(onSubmit) forControlEvents:UIControlEventTouchUpInside];

    self.doneButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    [self updateDoneButtonWithAnimation:NO];

    [self.view addSubview:self.doneButton];

    __weak UIViewController* weakSelf = self;
    [self.view addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        [weakSelf.view setNeedsLayout];
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateDoneButtonWithAnimation:animated];

    if ([self isViewVisible])
        [self.usernameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect b = self.view.bounds;
    CGRect viz = [self.view frameMinusKeyboard];

    self.feedbackLabel.frame = CGRectMakeCorners(4, 70,
                                                 b.size.width-4, 100);

    CGRect bb = CGRectMakeCorners(0, CGRectGetMaxY(self.feedbackLabel.frame), b.size.width, CGRectGetMaxY(viz));

    CGFloat goldenY = bb.origin.y + bb.size.height*(1.f - 1.f/GOLDEN_MEAN);

    CGFloat buttonWidth = b.size.width;
    CGFloat buttonHeight = 44;

    self.usernameField.frame = CGRectSetBottomCenter(b.size.width/2, goldenY, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.passwordField.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.usernameField.frame), CGRectMake(0, 0, buttonWidth, buttonHeight));

}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    if (textField == self.usernameField) {
        self.feedbackLabel.text = @"";
        if (newString.length > 0) [self checkUsername:newString];
    }
    else if (textField == self.passwordField) {
        self.feedbackLabel.text = @"";
        [self checkPasswordString:newString];
    }

    NSString *regex = @"\\s";

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateDoneButtonWithAnimation:YES];
    });

    return ![newString isMatchedByRegex:regex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        if (self.isValidName)
            [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self onSubmit];
    }
    return NO;
}

- (BOOL)checkPasswordString:(NSString *)string {
    if (string.length >= 6) {
        self.passwordField.textColor = COLOR(blackColor);
        return YES;
    } else {
        self.passwordField.textColor = COLOR(darkGrayColor);
        return NO;
    }
}

- (void)checkUsername:(NSString*)name {
    [self checkUsername:name afterDelay:0.5];
}

- (void)checkUsername:(NSString*)name afterDelay:(NSTimeInterval)delay {

    self.isValidName = NO;

    NSString *regex = @"^[a-zA-Z0-9\\-]{2,16}$";
    NSString *atLeastOneLetterRegex = @"[a-zA-Z]";
    if ([name isMatchedByRegex:regex] && [name isMatchedByRegex:atLeastOneLetterRegex]) {
        self.isValidName = YES;

    } else {
        self.isValidName = NO;
    }
}

- (BOOL)validInputs {
    return (self.isValidName && [self checkPasswordString:self.passwordField.text]);
}

- (void)updateDoneButtonWithAnimation:(BOOL)animate {
    CGFloat bottom = [self.view frameMinusKeyboard].size.height;

    void (^block)() = ^() {
        self.doneButton.hidden = ![self validInputs];
        self.doneButton.frame = [self validInputs] ? CGRectSetBottomLeft(0, bottom, self.doneButton.frame) : CGRectSetOrigin(0,bottom, self.doneButton.frame);
        [self.view setNeedsLayout];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.6 animations:block];
    }
    else
        block();
}

- (void)onSubmit {
    if ([self validInputs]) {

        [[Api sharedApi] postPath:@"/login"
                       parameters:@{@"login":self.usernameField.text,
                                    @"password":self.passwordField.text}
                         callback:[[Api sharedApi] authCallbackWithCompletion:^(NSSet *entities, id responseObject, NSError *error, BOOL authorized) {
            NSLog(@"login: %@", responseObject);
            on_main(^{
                if (!error) {
                    self.usernameField.text = nil;
                    self.passwordField.text = nil;
                    self.feedbackLabel.text = nil;
                    [self.meController openStory];
                }
                else {
                    self.feedbackLabel.text = @"Incorrect username and/or password";
                }
            });

        }]];
    }
}

@end

