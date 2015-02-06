//
//  PhoneVerifyPanel.m
//  SnapCracklePop
//
//  Created by Jim Young on 11/5/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PhoneVerifyPanel.h"
#import "Api.h"
#import "App.h"
#import "User.h"
#import "AppViewController.h"
#import "StatusView.h"
#import "AlertView.h"
#import "PNUserPreferences.h"
#import "PushPermissionManager.h"
#import "DefaultWelcomePanel.h"
#import "DefaultImportContactsPanel.h"
#import "Directory+Snapchat.h"

#import "UILabel+FadeEffect.h"
#import "BackgroundCamera.h"

#import "PhoneCountryCodeViewController.h"
#import "RMPhoneFormat.h"

@interface PhoneVerifyPanel() <UITextFieldDelegate> {
    RMPhoneFormat *_phoneFormat;
    NSMutableCharacterSet *_phoneChars;
}

@property (nonatomic,strong) PNView* formContainer;

@property (strong, nonatomic) PNLabel *countryLabel;

@property (strong, nonatomic) PNTextField *phoneTextField;
@property (strong, nonatomic) PNButton *submitButton;

@property (strong, nonatomic) PNLabel *introLabel;
@property (strong, nonatomic) PNLabel *noticeLabel;
@property (strong, nonatomic) PNRichLabel* tosLabel;
@property (strong, nonatomic) PNRichLabel* blurbLabel;

@property (strong, nonatomic) UIView *topStrip;
@property (nonatomic, strong) UIImageView* logoView;

@property (assign, nonatomic) CGFloat yOffset;

@property (strong, nonatomic) BackgroundCamera *cam;
@property (strong, nonatomic) PhoneCountryCodeViewController* countryController;

@end

@implementation PhoneVerifyPanel

- (void)didAppear {
    [super didAppear];
    [self.phoneTextField becomeFirstResponder];
    [self.cam startPreview];
    [self.introLabel fadeInOverDuration:4 toColor:COLOR(grayColor) completion:^{
        self.phoneTextField.hidden = NO;
    }];
}

-(BOOL)isNeeded {
    return ![App isLoggedIn];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _phoneFormat = [[RMPhoneFormat alloc] init];
        _phoneChars = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
        [_phoneChars addCharactersInString:@"+*#,"];

        self.multipleTouchEnabled = YES; // Required for accessing the secret admin menu
        self.backgroundView.multipleTouchEnabled = YES;

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(defaultNavigationColor);
        [self addSubview:self.topStrip];

        self.cam = [[BackgroundCamera alloc] initWithFrame:CGRectZero];
        self.cam.alpha = 0.2;
        [self addSubview:self.cam];

        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-biglogo"]];
        [self.logoView sizeToFit];
        [self addSubview:self.logoView];

        [self bringSubviewToFront:self.leftButton];

        self.formContainer = [[PNView alloc] init];
        self.formContainer.clipsToBounds = YES;
        [self addSubview:self.formContainer];

        self.submitButton = [[PNButton alloc] init];
        [self.submitButton setTitle:@"OK" forState:UIControlStateNormal];
        self.submitButton.titleLabel.font = FONT_B(24);
        [self.submitButton addTarget:self action:@selector(doSubmit) forControlEvents:UIControlEventTouchUpInside];
        self.submitButton.buttonColor = COLOR(greenColor);
        self.submitButton.enabled = NO;
        [self addSubview:self.submitButton];

        //        self.countryLabel = [PNLabel labelWithText:@"YO" andFont:FONT(24)];
        //        self.countryLabel.userInteractionEnabled = YES;
        //        [self.countryLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCountryCode)]];
        //        [self.formContainer addChild:self.countryLabel];

        self.phoneTextField = [[PNTextField alloc] initWithFrame:CGRectZero];
        self.phoneTextField.font = FONT(30);
        self.phoneTextField.textColor = COLOR(darkGrayColor);
        self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your phone number"
                                                                                    attributes:@{NSForegroundColorAttributeName:[COLOR(darkGrayColor) colorWithAlphaComponent:0.5]}];
        self.phoneTextField.horizontalInset = 5;
        self.phoneTextField.textAlignment = NSTextAlignmentCenter;
        self.phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTextField.returnKeyType = UIReturnKeyNext;

        //        self.emailTextField.font = [[Theme current] boldFontWithSize:18];
        self.phoneTextField.verticalInset = 5;
        self.phoneTextField.delegate = self;
        self.phoneTextField.hidden = YES;
        [self.formContainer addChild:self.phoneTextField];

        self.introLabel = [PNLabel labelWithText:@"Register by entering your area code and phone number." andFont:FONT(14)];
        self.introLabel.textColor = COLOR(grayColor);
        self.introLabel.textAlignment = NSTextAlignmentCenter;
        [self.introLabel makeInvisible];
        [self addSubview:self.introLabel];

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

        //        self.countryController = [PhoneCountryCodeViewController new];
        //        [self.countryController addObserver:self forKeyPath:@"selectedCode" options:NSKeyValueObservingOptionNew context:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        self.leftButton.frame = CGRectMake(0,0,50,30);
        self.leftButton.buttonColor = COLOR(whiteColor);

    }
    return self;
}

- (void)didBecomeActive {
    [self setNeedsLayout];
    self.submitButton.enabled = YES;
}

- (void)keyboardDidBecomeVisible:(BOOL)visible viewFrame:(CGRect)viewFrame keyboardFrame:(CGRect)keyboardFrame {
    [super keyboardDidBecomeVisible:visible viewFrame:viewFrame keyboardFrame:keyboardFrame];
    CGFloat bottom = keyboardFrame.origin.y;
    self.submitButton.frame = CGRectMakeCorners(0, bottom-50, keyboardFrame.size.width, bottom);
    self.noticeLabel.hidden = CGRectIntersectsRect(keyboardFrame, self.frame);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat m = 10;
    CGFloat formWidth = b.size.width-20;
    CGFloat fieldHeight = 54;

    self.cam.frame = b;

    self.topStrip.frame = CGRectMake(0,self.yOffset, b.size.width, 60);
    self.logoView.center = self.topStrip.center;

    self.introLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topStrip.frame), b.size.width, 50);

    CGRect lbf = CGRectMake(0,0, CGRectGetHeight(self.topStrip.frame)-2*m, CGRectGetHeight(self.topStrip.frame)-2*m);
    self.leftButton.frame = CGRectSetOrigin(m, m, lbf);

    //    self.countryLabel.frame = CGRectMake(0, 0, formWidth, fieldHeight);
    self.phoneTextField.frame = CGRectMake(0, 0, formWidth, fieldHeight);

    CGFloat bottom = self.visibleRect.size.height;

    self.submitButton.frame = CGRectMakeCorners(0, bottom-60, b.size.width, bottom);

    self.tosLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.submitButton.frame)-4, CGRectMake(0, 0, b.size.width, 30));
    self.noticeLabel.frame = CGRectSetBottomCenter(b.size.width/2, CGRectGetMinY(self.submitButton.frame)-4, self.noticeLabel.frame);

    self.tosLabel.hidden = !self.noticeLabel.hidden;

    self.blurbLabel.frame = CGRectMakeCorners(0, CGRectGetMaxY(self.topStrip.frame), CGRectGetMinY(self.tosLabel.frame), b.size.width);

    [self.formContainer sizeToFit];
    self.formContainer.center = CGPointMake(b.size.width/2, (CGRectGetMaxY(self.topStrip.frame)+CGRectGetMinY(self.noticeLabel.frame))/2);

    [self adjustBackgroundSize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.phoneTextField) {
        [self doSubmit];
    }
    return NO;
}

- (void)doSubmit {
    self.submitButton.enabled = NO;
    [[Api sharedApi] postPath:@"/phones/verify"
                   parameters:@{@"phone_number":[self.controller valueForKey:@"phoneNumber"],
                                @"phone_verification_code":[self.phoneTextField.text digits]}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         if (!error && ![responseObject valueForKey:@"error"]) {
                             [self.controller setValue:[self.phoneTextField.text digits] forKey:@"phoneVerification"];
                             on_main(^{
                                 [self gotoNextPanel];
                                 self.submitButton.enabled = YES;
                             });
                         }
                     }];
}

- (void)onCountryCode {
    CGRect b = self.bounds;
    self.countryController.view.frame = CGRectMakeCorners(0, CGRectGetMaxY(self.logoView.frame), b.size.width, b.size.height);
    [self.controller addChildViewController:self.countryController];
    [self addSubview:self.countryController.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark UITextViewDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.submitButton.enabled = newString.length >= 4;
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"observe %@ %@", keyPath, change);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.countryController removeObserver:self forKeyPath:@"selectedCode"];
}

@end
