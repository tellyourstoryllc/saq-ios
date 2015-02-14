//
//  SignupController.m
//  TellYourStory
//
//  Created by Jim Young on 2/9/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "SignupController.h"
#import "Api.h"
#import "DAKeyboardControl.h"

@interface SignupController()<UITextFieldDelegate>

@property (nonatomic,strong) PNLabel* titleLabel;
@property (nonatomic,strong) PNLabel* subtitle;

@property (nonatomic,strong) PNTextField* usernameField;
@property (nonatomic,strong) PNTextField* emailField;
@property (nonatomic,strong) PNTextField* passwordField;

@property (nonatomic,strong) PNButton* doneButton;

@property (nonatomic, assign) BOOL isValidName;
@property (nonatomic, strong) PNLabel* feedbackLabel;

@property (strong) AFHTTPRequestOperation* checkUsernameAvailabilityOperation;
@property (nonatomic, strong) NSTimer* checkUsernameAvailabilityTimer;

@end

@implementation SignupController

- (void)viewDidLoad
{
    UIFont* placeholderFont = FONT_I(18);

    self.titleLabel = [PNLabel labelWithText:@"Signing up allows you to login and manage your stories." andFont:FONT(16)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = COLOR(grayColor);
    [self.titleLabel sizeToFitTextWidth:self.view.bounds.size.width-8];
    [self.view addSubview:self.titleLabel];

    self.feedbackLabel = [PNLabel new];
    self.feedbackLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackLabel.textColor = COLOR(redColor);
    self.feedbackLabel.font = FONT_B(16);
    [self.view addSubview:self.feedbackLabel];

    self.subtitle = [PNLabel labelWithText:@"Your email address is 100% private." andFont:FONT(13)];
    self.subtitle.textAlignment = NSTextAlignmentCenter;
    self.subtitle.textColor = COLOR(grayColor);
    [self.view addSubview:self.subtitle];

    self.usernameField = [[PNTextField alloc] init];
    self.usernameField.font = FONT_B(18);
    self.usernameField.textColor = COLOR(blackColor);
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Choose a Username"
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

    self.emailField = [[PNTextField alloc] init];
    self.emailField.font = FONT_B(18);
    self.emailField.textColor = COLOR(blackColor);
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address (optional)"
                                                                            attributes:@{NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                                                                         NSFontAttributeName : placeholderFont}];
    self.emailField.horizontalInset = 25;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.returnKeyType = UIReturnKeyNext;
    self.emailField.textAlignment = NSTextAlignmentCenter;
    self.emailField.delegate = self;
    [self.view addSubview:self.emailField];

    self.passwordField = [[PNTextField alloc] init];
    self.passwordField.font = FONT_B(18);
    self.passwordField.textColor = COLOR(blackColor);
    self.passwordField.secureTextEntry = YES;
    self.passwordField.placeholder = @"New Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New Password"
                                                                               attributes:@{NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                                                                            NSFontAttributeName : placeholderFont}];
    self.passwordField.horizontalInset = 25;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.delegate = self;
    [self.view addSubview:self.passwordField];

    self.doneButton = [[PNButton alloc] init];
    [self.doneButton setTitle:@"Register" forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = FONT_B(21);
    self.doneButton.buttonColor = COLOR(turquoiseColor);
    [self.doneButton addTarget:self action:@selector(onSubmit) forControlEvents:UIControlEventTouchUpInside];

    self.doneButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);

    [self.view addSubview:self.doneButton];

    __weak SignupController* weakSelf = self;

    [self.view addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        [weakSelf updateDoneButtonWithAnimation:NO];
        [weakSelf.view setNeedsLayout];
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateDoneButtonWithAnimation:animated];

    if ([self isViewVisible]) {
       [self.usernameField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect b = self.view.bounds;

    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 70, self.titleLabel.frame);
    self.feedbackLabel.frame = CGRectMakeCorners(4, CGRectGetMinY(self.titleLabel.frame),
                                                 b.size.width-4, CGRectGetMaxY(self.titleLabel.frame));

    [self.subtitle sizeToFitTextWidth:b.size.width];

    self.subtitle.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.doneButton.frame)-4, self.subtitle.frame);

    CGRect bb = CGRectMakeCorners(0, CGRectGetMaxY(self.titleLabel.frame), b.size.width, CGRectGetMinY(self.subtitle.frame));

    CGFloat goldenY = bb.origin.y + bb.size.height*(1.f - 1.f/GOLDEN_MEAN);

    CGFloat buttonWidth = b.size.width;
    CGFloat buttonHeight = 44;

    self.usernameField.frame = CGRectSetBottomCenter(b.size.width/2, goldenY, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.passwordField.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.usernameField.frame), CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.emailField.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.passwordField.frame), CGRectMake(0, 0, buttonWidth, buttonHeight));

}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    if (textField == self.usernameField) {
        if (newString.length > 0) [self checkUsername:newString];
    }
    else if (textField == self.passwordField) {
        [self checkPasswordString:newString];
    }
    else if (textField == self.emailField) {
        [self checkEmailString:newString];
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
        [self.emailField becomeFirstResponder];
    }
    else if (textField == self.emailField) {
        if ([self checkEmailString:self.emailField.text] || self.emailField.text.length == 0) {
            [self onSubmit];
        }
        else {
        }
    }
    return NO;
}

- (BOOL)checkEmailString:(NSString *)string {
    NSString *regex = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    if ([string isMatchedByRegex:regex]) {
        self.emailField.textColor = COLOR(blackColor);
        return YES;
    } else {
        self.emailField.textColor = COLOR(darkGrayColor);
        return NO;
    }
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

    [self.checkUsernameAvailabilityTimer invalidate];
    self.isValidName = NO;
    self.feedbackLabel.text = @"";
    [self.view setNeedsLayout];

    NSString *regex = @"^[a-zA-Z0-9\\-]{2,16}$";
    NSString *atLeastOneLetterRegex = @"[a-zA-Z]";
    if ([name isMatchedByRegex:regex] && [name isMatchedByRegex:atLeastOneLetterRegex]) {

        self.feedbackLabel.text = @"";
        self.checkUsernameAvailabilityOperation = [[Api sharedApi] operationWithHTTPMethod:@"POST"
                                                                                      path:@"/users"
                                                                                parameters:@{@"usernames":name}
                                                                               andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {

                                                                                   on_main(^{
                                                                                       if (!error && entities.count == 0) {
                                                                                           self.isValidName = YES;
                                                                                           self.titleLabel.hidden = NO;
                                                                                           [self.view setNeedsLayout];
                                                                                       }
                                                                                       else if (data) {
                                                                                           self.isValidName = NO;
                                                                                           self.feedbackLabel.text = [NSString stringWithFormat:@"Sorry, %@ is not available.", name];
                                                                                           self.titleLabel.hidden = YES;
                                                                                           [self.view setNeedsLayout];
                                                                                       }
                                                                                   });

                                                                               }];
        self.checkUsernameAvailabilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(checkAvailability) userInfo:nil repeats:NO];

    } else if (name.length > 16 ){
        self.isValidName = NO;
        self.titleLabel.hidden = YES;
        self.feedbackLabel.text = @"Too many characters!";

    } else if (name.length > 1) {
        self.isValidName = NO;
        self.titleLabel.hidden = YES;
        if (![name isMatchedByRegex:atLeastOneLetterRegex])
            self.feedbackLabel.text = @"Usernames must contain at least one letter.";
        else
            self.feedbackLabel.text = @"Only letters, numbers, and _ are allowed in usernames.";
        [self.view setNeedsLayout];

    } else {
        self.isValidName = NO;
        self.titleLabel.hidden = NO;
        self.feedbackLabel.text = @"";
        [self.view setNeedsLayout];
    }
}

- (void)checkAvailability {
    if (self.checkUsernameAvailabilityOperation) {
        [[Api sharedApi] enqueueOperation:self.checkUsernameAvailabilityOperation];
        self.checkUsernameAvailabilityOperation = nil;
    }
}

- (BOOL)validInputs {
    return (self.isValidName && [self checkPasswordString:self.passwordField.text] && ([self checkEmailString:self.emailField.text] || self.emailField.text.length == 0));
}

- (void)updateDoneButtonWithAnimation:(BOOL)animate {
    CGFloat bottom = [self.view.window frameMinusKeyboard].size.height;

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
        NSMutableDictionary* params = [@{@"username":self.usernameField.text,
                                         @"password":self.passwordField.text} mutableCopy];
        if (self.emailField.text.length)
            params[@"email"] = self.emailField.text;

        [[Api sharedApi] postPath:@"/users/create"
                       parameters:params
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             NSLog(@"create user: %@", responseObject);
                             self.usernameField.text = nil;
                             self.passwordField.text = nil;
                             [self.meController openStory];
                         }];
    }
}

@end
