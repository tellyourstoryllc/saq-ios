//
//  LinearUsernamePanel.m
//
//
//  Created by Jim Young on 2/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "GenericUsernamePanel.h"
#import "Api.h"
#import "App.h"
#import "AppViewController.h"
#import "Configuration.h"
#import "UIView+PNAnimations.h"
#import "StatusView.h"
#import "AlertView.h"

@interface GenericUsernamePanel()<UITextFieldDelegate>

@property (nonatomic, strong) PNRichLabel* sloganLabel;
@property (nonatomic, strong) PNRichLabel* feedbackLabel;

@property (nonatomic,strong) PNTextField* nameField;

@property (nonatomic,strong) PNButton* doneButton;
@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic,strong) PNRichLabel* tosLabel;

@property (assign, nonatomic) CGFloat yOffset;

@property (assign, nonatomic) BOOL isValidName;

@property (strong) AFHTTPRequestOperation* checkUsernameAvailabilityOperation;
@property (nonatomic, strong) NSTimer* checkUsernameAvailabilityTimer;

@end

@implementation GenericUsernamePanel

- (void)didAppear {
    [super didAppear];
    if (self.nameField.text.length) {
        [self checkUsername:self.nameField.text];
    }
    else {
        NSString* prepopulate = [self.controller valueForKey:@"username"];
        if (prepopulate) {
            self.nameField.text = prepopulate;
            [self checkUsername:self.nameField.text afterDelay:0.0];
        }
        else {
            [self.nameField becomeFirstResponder];
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(blueColor);
        [self addSubview:self.topStrip];

        [self bringSubviewToFront:self.leftButton];

        self.sloganLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.sloganLabel.font = [UIFont fontWithName:@"Gauge-Heavy" size:24];
        self.sloganLabel.textAlignment = RTTextAlignmentCenter;
        self.sloganLabel.textColor = COLOR(whiteColor);
        [self addSubview:self.sloganLabel];

        self.feedbackLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.feedbackLabel.font = FONT_B(15);
        self.feedbackLabel.textAlignment = RTTextAlignmentCenter;
        self.feedbackLabel.textColor = COLOR(whiteColor);
        [self addSubview:self.feedbackLabel];

        self.nameField = [[PNTextField alloc] init];
        self.nameField.font = FONT_B(30);
        self.nameField.textColor = COLOR(darkGrayColor);
        self.nameField.backgroundColor = COLOR(whiteColor);
        self.nameField.layer.borderColor = [COLOR(grayColor) CGColor];
        self.nameField.layer.borderWidth = 1.0;
        self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"screenname"
                                                                               attributes:@{NSForegroundColorAttributeName:COLOR(grayColor)}];
        self.nameField.horizontalInset = 5;
        self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.nameField.returnKeyType = UIReturnKeyDone;
        self.nameField.textAlignment = NSTextAlignmentCenter;
        self.nameField.delegate = self;
        [self addSubview:self.nameField];

        self.doneButton = [[PNButton alloc] init];
        [self.doneButton setImage:[UIImage imageNamed:@"right-arrow"] forState:UIControlStateNormal];
        self.doneButton.titleLabel.font = FONT_B(18);
        self.doneButton.buttonColor = COLOR(greenColor);
        self.doneButton.cornerRadius = 20;
        self.doneButton.alpha = 0.0;
        [self.doneButton addTarget:self action:@selector(performRegistration) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];

        self.tosLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.tosLabel.textColor = COLOR(darkGrayColor);
        self.tosLabel.textAlignment = RTTextAlignmentCenter;
        self.tosLabel.font = FONT(11);
        self.tosLabel.text = [NSString stringWithFormat:@"By signing up you acknowledge and accept the<br><a href='%@'><font color='#c399c7'>Terms of Service & Privacy Policy</font></a>", kTermsOfServiceURL];
        self.tosLabel.hidden = YES;
        [self addSubview:self.tosLabel];

        self.sloganLabel.text = [Configuration stringFor:@"username_slogan"] ?: @"Pick a Screenname";

    }
    return self;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    CGRect b = self.bounds;
    CGFloat m = 4; // <-- margin

    CGFloat buttonWidth = b.size.width-60;
    CGFloat buttonHeight = 56;

    self.topStrip.frame = CGRectMake(0,self.yOffset, b.size.width, 65);

    CGRect lbf = CGRectMake(0,0, CGRectGetHeight(self.topStrip.frame)-2*m, CGRectGetHeight(self.topStrip.frame)-2*m);
    self.leftButton.frame = CGRectSetOrigin(m, m, lbf);

    [self.sloganLabel sizeToFitTextWidth:b.size.width-2*m];
    self.sloganLabel.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.topStrip.frame)+20, self.sloganLabel.frame);

    CGFloat y = MAX(CGRectGetMaxY(self.sloganLabel.frame)+20, b.size.height*0.2+self.yOffset);

    self.nameField.frame = CGRectSetTopCenter(b.size.width/2, y, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.doneButton.frame = CGRectSetMiddleRight(b.size.width-10, CGRectGetMidY(self.nameField.frame), CGRectMake(0,0,buttonHeight,buttonHeight));
    self.doneButton.cornerRadius = buttonHeight/2;

    [self.feedbackLabel sizeToFitTextWidth:b.size.width-4*m];
    self.feedbackLabel.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.nameField.frame)+10, self.feedbackLabel.frame);

    // From bottom
    self.tosLabel.frame = CGRectSetBottomCenter(b.size.width/2, self.frameMinusKeyboard.size.height, CGRectMake(0, 0, b.size.width, 40));

    self.tosLabel.hidden = !self.isValidName;
    [UIView animateWithDuration:0.3 animations:^{
        self.doneButton.alpha = self.isValidName ? 1.0 : 0.0;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    if ([newString isMatchedByRegex:@"[\\s]"]) {
        return NO;
    }
    else {
        if (newString.length > 0) [self checkUsername:newString];
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [self performRegistration];
    }
    return NO;
}

- (void)performRegistration {
    if (!self.isValidName) return;
    [self.controller setValue:self.nameField.text forKey:@"username"];

    [self createUserWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [StatusView showTitle:@"Sign Up Failed" message:error.localizedDescription completion:nil duration:5];
        }
        else {
            [StatusView dismiss];
            if ([Configuration boolFor:@"manual_sms_registration"] || ![PNSupport deviceCanSMS]) {
                [self gotoNextPanel];
            }
            else {
                [self phoneVerificationWithCompletion:^(BOOL sent, BOOL denied) {
                    [self gotoNextPanel];
                }];
            }
        }
    }];
}

- (void)checkUsername:(NSString*)name {
    [self checkUsername:name afterDelay:0.5];
}

- (void)checkUsername:(NSString*)name afterDelay:(NSTimeInterval)delay {

    [self.checkUsernameAvailabilityTimer invalidate];
    self.isValidName = NO;
    self.feedbackLabel.text = @"";
    [self setNeedsLayout];

    NSString *regex = @"^[a-zA-Z0-9\\-]{2,16}$";
    NSString *atLeastOneLetterRegex = @"[a-zA-Z]";
    if ([name isMatchedByRegex:regex] && [name isMatchedByRegex:atLeastOneLetterRegex]) {

        self.feedbackLabel.text = @"";
        self.checkUsernameAvailabilityOperation =
        [[Api sharedApi] operationWithHTTPMethod:@"POST"
                                            path:@"/users/username_status"
                                      parameters:@{@"username":name}
                                     andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {

                                         NSLog(@"%@", responseObject[0]);

                                         if (!error && [responseObject isKindOfClass:[NSArray class]] && [responseObject[0] isEqualToString:@"available"]) {
                                             [self.controller setValue:name forKey:@"username"];
                                             self.feedbackLabel.text = @"Great name!";
                                             self.isValidName = YES;
                                             [self setNeedsLayout];
                                         }
                                         else if (data) {
                                             self.isValidName = NO;
                                             self.feedbackLabel.text = [NSString stringWithFormat:@"Sorry, <i>%@</i> is already taken.", name];
                                             [self setNeedsLayout];
                                         }
                                     }];
        self.checkUsernameAvailabilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(checkAvailability) userInfo:nil repeats:NO];

    } else if (name.length > 16 ){
        self.isValidName = NO;
        self.feedbackLabel.text = @"Too many characters!";

    } else if (name.length > 1) {
        self.isValidName = NO;
        if (![name isMatchedByRegex:atLeastOneLetterRegex])
            self.feedbackLabel.text = @"Screennames must contain at least one letter.";
        else
            self.feedbackLabel.text = @"Only letters, numbers, and _ are allowed.";
        [self setNeedsLayout];

    } else {
        self.isValidName = NO;
        self.feedbackLabel.text = @"";
        [self setNeedsLayout];
    }
}

- (void)checkAvailability {
    if (self.checkUsernameAvailabilityOperation) {
        [[Api sharedApi] enqueueOperation:self.checkUsernameAvailabilityOperation];
        self.checkUsernameAvailabilityOperation = nil;
    }
}

@end
