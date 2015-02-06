//
//  RegistrationPanel.h
//  groups
//
//  Created by Jim Young on 11/28/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "BasePanel.h"
#import "PNFacebookAdapter.h"
#import "Group.h"
#import "Directory.h"

@interface RegistrationBasePanel : BasePanel

@property (nonatomic, strong) PNButton* leftButton;
@property (nonatomic, strong) PNButton* rightButton;

@property (nonatomic, strong) UIView* backgroundView;

- (void) adjustBackgroundSize;

// Dumb convenience method
- (CGRect) buttonValley; // the rect between the buttons:

- (void) leftButtonTapped;
- (void) rightButtonTapped;

// Common functionality used in login/signup:

- (void) createUserWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void) phoneVerificationWithCompletion:(void (^)(BOOL sent, BOOL denied))completion;
- (void) exitRegistration;

- (UIFont *) headerFont;

@end