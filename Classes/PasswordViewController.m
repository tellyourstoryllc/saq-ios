//
//  PasswordViewController.m
//
//
//  Created by Jim Young on 3/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PasswordViewController.h"
#import "SkyAccount.h"
#import "Api.h"
#import "StatusView.h"
#import "PNProgress.h"

@interface PasswordViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) PNTextField* oldPasswordField;
@property (nonatomic, strong) PNTextField* freshPasswordField;
@property (nonatomic, strong) PNTextField* confirmPasswordField;

@property (nonatomic, strong) PNButton* button;
@property (nonatomic, strong) PNRichLabel* feedbackLabel;

@end

@implementation PasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Password";

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.oldPasswordField = [[PNTextField alloc] init];
    self.oldPasswordField.backgroundColor = COLOR(whiteColor);
    self.oldPasswordField.secureTextEntry = YES;
    self.oldPasswordField.placeholder = @"Current password";
    self.oldPasswordField.horizontalInset = 10;
    self.oldPasswordField.returnKeyType = UIReturnKeyNext;
    self.oldPasswordField.delegate = self;
    [self.view addSubview:self.oldPasswordField];

    self.freshPasswordField = [[PNTextField alloc] init];
    self.freshPasswordField.backgroundColor = COLOR(whiteColor);
    self.freshPasswordField.secureTextEntry = YES;
    self.freshPasswordField.placeholder = @"New password";
    self.freshPasswordField.horizontalInset = 10;
    self.freshPasswordField.returnKeyType = UIReturnKeyNext;
    self.freshPasswordField.delegate = self;
    [self.view addSubview:self.freshPasswordField];

    self.confirmPasswordField = [[PNTextField alloc] init];
    self.confirmPasswordField.backgroundColor = COLOR(whiteColor);
    self.confirmPasswordField.secureTextEntry = YES;
    self.confirmPasswordField.placeholder = @"Confirm";
    self.confirmPasswordField.horizontalInset = 10;
    self.confirmPasswordField.returnKeyType = UIReturnKeyGo;
    self.confirmPasswordField.delegate = self;
    [self.view addSubview:self.confirmPasswordField];

    self.button = [[PNButton alloc] init];
    [self.button setTitle:@"Set Password" forState:UIControlStateNormal];
    self.button.buttonColor = COLOR(blueColor);
    [self.button addTarget:self action:@selector(submitChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];

    self.feedbackLabel = [[PNRichLabel alloc] init];
    self.feedbackLabel.textAlignment = RTTextAlignmentCenter;
    self.feedbackLabel.font = FONT_B(16);
    [self.view addSubview:self.feedbackLabel];
}

- (void)viewWillLayoutSubviews {
    CGRect b = self.view.bounds;

    CGFloat w = b.size.width;
    CGFloat m = 10;

    CGFloat bw = b.size.width-50;
    CGFloat bh = 50;

    CGFloat y = 80;

    if ([[SkyAccount mine] needs_passwordValue]) {
        self.oldPasswordField.frame = CGRectZero;
    }
    else {
        self.oldPasswordField.frame = CGRectSetTopCenter(w/2, y, CGRectMake(0,0,bw,bh));
        y = CGRectGetMaxY(self.oldPasswordField.frame) + m;
    }

    self.freshPasswordField.frame = CGRectSetTopCenter(w/2, y, CGRectMake(0,0,bw,bh));
    y = CGRectGetMaxY(self.freshPasswordField.frame) + m;

    self.confirmPasswordField.frame = CGRectSetTopCenter(w/2, y, CGRectMake(0,0,bw,bh));

    y = CGRectGetMaxY(self.confirmPasswordField.frame) + m;
    self.button.frame = CGRectSetTopCenter(w/2, y, CGRectMake(0,0,bw,bh));

    y = CGRectGetMaxY(self.button.frame) + m;

    self.feedbackLabel.frame = CGRectMakeCorners(m, y, w-m, b.size.height);

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.oldPasswordField) {
        [self.freshPasswordField becomeFirstResponder];
    }
    else if (textField == self.freshPasswordField) {
        [self.confirmPasswordField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordField) {
        [self submitChange];
    }
    return NO;
}

- (void)submitChange {

    [self.view endEditing:YES];

    if (self.freshPasswordField.text == 0) {
        self.feedbackLabel.text = @"You did not enter a new password.";
    }
    else if (self.confirmPasswordField.text == 0) {
        self.feedbackLabel.text = @"Confirm your password by entering in again.";
    }
    else if (self.freshPasswordField.text.length >= 6 && ![self.freshPasswordField.text isEqualToString:self.confirmPasswordField.text]) {
        self.feedbackLabel.text = @"Your password confirmation does not match.";
        self.confirmPasswordField.text = nil;
    }
    else if (self.freshPasswordField.text.length < 6) {
        self.feedbackLabel.text = @"Passwords must be at least 6 characters.";
    }
    else {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
        if (self.oldPasswordField.text.length) [params setValue:self.oldPasswordField.text forKey:@"password"];
        [params setValue:self.freshPasswordField.text forKey:@"new_password"];

        self.button.enabled = NO;
        [PNProgress show];

        [[Api sharedApi] postPath:@"/accounts/update"
                       parameters:params
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             on_main(^{

                                 self.button.enabled = YES;
                                 [PNProgress dismiss];
                                 if (error) {
                                     [StatusView showTitle:@"Enter your current password" message:nil
                                                completion:^{
                                                    self.oldPasswordField.text = nil;
                                                    [[SkyAccount mine] setNeeds_passwordValue:NO];
                                                    [self.view setNeedsLayout];
                                                } duration:2.0];
                                 }
                                 else {
                                     [[SkyAccount mine] setNeeds_passwordValue:NO];
                                     [[SkyAccount mine] save];
                                     [StatusView showTitle:@"Password updated" message:nil
                                                completion:^{
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }
                                                  duration:1.337];
                                 }
                             });
                         }];
    }
}

@end
