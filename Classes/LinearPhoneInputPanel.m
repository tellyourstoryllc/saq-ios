//
//  LinearPhoneInputPanel.m
//
//
//  Created by Jim Young on 3/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearPhoneInputPanel.h"
#import "Api.h"
#import "PNProgress.h"
#import "StatusView.h"

@interface LinearPhoneInputPanel()<UITextFieldDelegate>

@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic, strong) PNRichLabel* sloganLabel;
@property (nonatomic, strong) PNRichLabel* infoLabel;
@property (nonatomic, strong) PNTextField* phoneField;

@property (nonatomic,strong) PNButton* doneButton;

@property (assign, nonatomic) CGFloat yOffset;

@property (assign, nonatomic) BOOL isValid;

@end

@implementation LinearPhoneInputPanel

- (BOOL)isNeeded {
    return ([Configuration boolFor:@"manual_sms_registration"] || ![PNSupport deviceCanSMS]);
}

- (void)didAppear {
    [super didAppear];
    [self.phoneField becomeFirstResponder];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self.rightButton setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
        self.rightButton.buttonColor = [UIColor clearColor];

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(defaultNavigationColor);
        [self addSubview:self.topStrip];

        [self bringSubviewToFront:self.rightButton];

        self.sloganLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.sloganLabel.font = [UIFont fontWithName:@"Gauge-Heavy" size:24];
        self.sloganLabel.textAlignment = RTTextAlignmentCenter;
        self.sloganLabel.textColor = COLOR(whiteColor);
        [self addSubview:self.sloganLabel];

        self.phoneField = [[PNTextField alloc] init];
        self.phoneField.font = FONT_B(30);
        self.phoneField.textColor = COLOR(darkGrayColor);
        self.phoneField.backgroundColor = COLOR(whiteColor);
        self.phoneField.layer.borderColor = [COLOR(grayColor) CGColor];
        self.phoneField.layer.borderWidth = 1.0;
        self.phoneField.keyboardType = UIKeyboardTypePhonePad;
        self.phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your mobile #"
                                                                               attributes:@{NSForegroundColorAttributeName:COLOR(grayColor)}];
        self.phoneField.horizontalInset = 5;
        self.phoneField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.phoneField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.phoneField.returnKeyType = UIReturnKeyDone;
        self.phoneField.textAlignment = NSTextAlignmentCenter;
        self.phoneField.delegate = self;
        [self addSubview:self.phoneField];

        self.doneButton = [[PNButton alloc] init];
        [self.doneButton setImage:[UIImage imageNamed:@"right-arrow"] forState:UIControlStateNormal];
        self.doneButton.titleLabel.font = FONT_B(18);
        self.doneButton.buttonColor = COLOR(greenColor);
        self.doneButton.cornerRadius = 20;
        self.doneButton.alpha = 0.0;
        [self.doneButton addTarget:self action:@selector(submitNumber) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];

        self.infoLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.infoLabel.font = FONT(14);
        self.infoLabel.textColor = COLOR(darkGrayColor);
        [self addSubview:self.infoLabel];

        self.sloganLabel.text = [Configuration stringFor:@"phone_input_slogan"] ?: @"Find Friends";
        self.infoLabel.text = [Configuration stringFor:@"phone_input_info"] ?: [NSString stringWithFormat:@"<i>%@</i> uses your mobile number and contacts to find and connect you to your friends.", kAppTitle];
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
    self.rightButton.frame = CGRectSetTopRight(b.size.width-m, m, lbf);

    [self.sloganLabel sizeToFitTextWidth:b.size.width-2*m];
    self.sloganLabel.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.topStrip.frame)+20, self.sloganLabel.frame);

    CGFloat y = MAX(CGRectGetMaxY(self.sloganLabel.frame)+20, b.size.height*0.2+self.yOffset);

    self.phoneField.frame = CGRectSetTopCenter(b.size.width/2, y, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.doneButton.frame = CGRectSetMiddleRight(b.size.width-10, CGRectGetMidY(self.phoneField.frame), CGRectMake(0,0,buttonHeight,buttonHeight));
    self.doneButton.cornerRadius = buttonHeight/2;

    self.infoLabel.frame = CGRectMakeCorners(30, CGRectGetMaxY(self.phoneField.frame)+5,
                                             b.size.width-30, b.size.height);

    [UIView animateWithDuration:0.3 animations:^{
        self.doneButton.alpha = self.isValid ? 1.0 : 0.0;
    }];

    if ([Configuration boolFor:@"signup_require_phone"]) self.rightButton.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    self.isValid = [newString isPhoneNumber];
    [UIView animateWithDuration:0.3 animations:^{
        self.doneButton.alpha = self.isValid ? 1.0 : 0.0;
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.phoneField) {
        [self submitNumber];
    }
    return NO;
}

- (void)submitNumber {
    if (!self.isValid) return;

    [PNProgress show];

    [[Api sharedApi] postPath:@"/phones/create"
                   parameters:@{@"phone_number":self.phoneField.text}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         [PNProgress dismiss];
                         if (!error) {
                             [self.controller setValue:self.phoneField.text forKey:@"phoneNumber"];
                             [self gotoNextPanel];
                         }
                         else {
                             [StatusView showTitle:@"Error" message:@"Please check the number and try again" completion:nil duration:2.0];
                         }
                     }];
}

- (void) rightButtonTapped {
    [self.controller setValue:nil forKey:@"phoneNumber"];
    [self gotoNextPanel];
}

@end
