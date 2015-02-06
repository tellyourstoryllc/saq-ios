//
//  LinearPhoneVerifyPanel.m
//
//
//  Created by Jim Young on 3/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearPhoneVerifyPanel.h"
#import "Api.h"
#import "StatusView.h"
#import "PNProgress.h"

@interface LinearPhoneVerifyPanel()<UITextFieldDelegate>

@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic, strong) PNRichLabel* sloganLabel;
@property (nonatomic, strong) PNRichLabel* infoLabel;
@property (nonatomic, strong) PNTextField* codeField;

@property (nonatomic,strong) PNButton* doneButton;

@property (assign, nonatomic) CGFloat yOffset;

@property (assign, nonatomic) BOOL isValid;

@end

@implementation LinearPhoneVerifyPanel

- (BOOL)isNeeded {
    return [self.controller valueForKey:@"phoneNumber"] != nil;
}

- (void)didAppear {
    [super didAppear];
    [self.codeField becomeFirstResponder];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(defaultNavigationColor);
        [self addSubview:self.topStrip];

        [self bringSubviewToFront:self.leftButton];

        self.sloganLabel = [[PNRichLabel alloc] initWithFrame:CGRectZero];
        self.sloganLabel.font = [UIFont fontWithName:@"Gauge-Heavy" size:24];
        self.sloganLabel.textAlignment = RTTextAlignmentCenter;
        self.sloganLabel.textColor = COLOR(whiteColor);
        [self addSubview:self.sloganLabel];

        self.codeField = [[PNTextField alloc] init];
        self.codeField.font = FONT_B(30);
        self.codeField.textColor = COLOR(darkGrayColor);
        self.codeField.backgroundColor = COLOR(whiteColor);
        self.codeField.layer.borderColor = [COLOR(grayColor) CGColor];
        self.codeField.layer.borderWidth = 1.0;
        self.codeField.keyboardType = UIKeyboardTypePhonePad;
        self.codeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter code"
                                                                                attributes:@{NSForegroundColorAttributeName:COLOR(grayColor)}];
        self.codeField.horizontalInset = 5;
        self.codeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.codeField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.codeField.returnKeyType = UIReturnKeyDone;
        self.codeField.textAlignment = NSTextAlignmentCenter;
        self.codeField.delegate = self;
        [self addSubview:self.codeField];

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

        self.sloganLabel.text = [Configuration stringFor:@"phone_verify_slogan"] ?: @"Verification";
        self.infoLabel.text = [Configuration stringFor:@"phone_verify_info"] ?: @"Type in the verification code that was sent to your mobile. It may take a few minutes to arrive.";
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

    self.codeField.frame = CGRectSetTopCenter(b.size.width/2, y, CGRectMake(0, 0, buttonWidth, buttonHeight));
    self.doneButton.frame = CGRectSetMiddleRight(b.size.width-10, CGRectGetMidY(self.codeField.frame), CGRectMake(0,0,buttonHeight,buttonHeight));
    self.doneButton.cornerRadius = buttonHeight/2;

    self.infoLabel.frame = CGRectMakeCorners(30, CGRectGetMaxY(self.codeField.frame),
                                             b.size.width-30, b.size.height);

    [UIView animateWithDuration:0.3 animations:^{
        self.doneButton.alpha = self.isValid ? 1.0 : 0.0;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    self.isValid = newString.length >= 4;
    [UIView animateWithDuration:0.3 animations:^{
        self.doneButton.alpha = self.isValid ? 1.0 : 0.0;
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.codeField) {
        [self submitNumber];
    }
    return NO;
}

- (void)submitNumber {
    if (!self.isValid) return;
    NSString* number = [self.controller valueForKey:@"phoneNumber"];
    [PNProgress show];
    [[Api sharedApi] postPath:@"/phones/verify"
                   parameters:@{@"phone_number":number, @"phone_verification_code":self.codeField.text }
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         on_main(^{
                             [PNProgress dismiss];
                             if (entities.anyObject) {
                                 [self gotoNextPanel];
                             }
                             else {
                                 [StatusView showTitle:@"Incorrect code" message:@"Please check your code and try again" completion:nil duration:2.5];
                             }
                         });
                     }];
}

@end
