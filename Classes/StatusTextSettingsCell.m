//
//  StatusSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "StatusTextSettingsCell.h"
#import "User.h"
#import "Api.h"

@interface StatusTextSettingsCell()<UITextFieldDelegate>

@property (nonatomic, strong) PNLabel* label;
@property (nonatomic, strong) PNTextField* statusField;
@property (assign) BOOL isUpdating;
@end

@implementation StatusTextSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [PNLabel labelWithText:@"Status" andFont:FONT(14)];
        [self addChild:self.label];

        self.statusField = [[PNTextField alloc] initWithFrame:CGRectMake(0,0,0,40)];
        self.statusField.horizontalInset = 5;
        self.statusField.borderStyle = UITextBorderStyleLine;

        self.statusField.frame = CGRectSetOrigin(10, CGRectGetMaxY(self.label.frame), self.statusField.frame);
        self.statusField.delegate = self;
        self.statusField.returnKeyType = UIReturnKeyDone;
        self.statusField.keyboardType = UIKeyboardTypeDefault;
        self.statusField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addChild:self.statusField];

        self.paddingY = 10;
        
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    User* me = [User me];
    self.statusField.text = me.status_text;
    CGRect b = self.bounds;
    self.label.frame = CGRectSetOrigin(20, 0, self.label.frame);
    self.statusField.frame = CGRectSetOrigin(20, CGRectGetMaxY(self.label.frame), CGRectMake(0,0,b.size.width-40,40));
    [super layoutSubviews];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int maxLength = 255;

    NSMutableString* newString = [NSMutableString stringWithString:textField.text];
    [newString replaceCharactersInRange:range
                             withString:string];
    return newString.length < maxLength;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self updateStatus:textField.text];
    return YES;
}

- (void)updateStatus:(NSString*)newStatus {
    if (self.isUpdating || [newStatus isEqualToString:[[User me] status_text]]) return;
    self.isUpdating = YES;
    [[Api sharedApi] postPath:@"/users/update"
                   parameters:@{@"status_text":newStatus}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         self.isUpdating = NO;
                     }];
}

@end
