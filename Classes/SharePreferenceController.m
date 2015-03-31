//
//  SharePreferenceController.m
//  TellYourStory
//
//  Created by Jim Young on 3/31/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "SharePreferenceController.h"

@interface SharePreferenceController()

@property (strong) PNButton* saveButton;

@property (strong) PNButton* shareYesButton;
@property (strong) PNButton* shareNoButton;
@property (strong) PNLabel* shareLabel;
@property (strong) PNView* shareContainer;

@property (strong) PNButton* anywhereYesButton;
@property (strong) PNButton* anywhereNoButton;
@property (strong) PNLabel* anywhereLabel;
@property (strong) PNView* anywhereContainer;

@end

@implementation SharePreferenceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(whiteColor);
    CGRect b = self.view.bounds;

    _shareContainer = [PNView new];
    [self.view addSubview:_shareContainer];

    _anywhereContainer = [PNView new];
    [self.view addSubview:_anywhereContainer];

    //--
    _shareLabel = [PNLabel labelWithText:@"Would you like your video to be viewable from our anywhere channel?" andFont:FONT(16)];
    [_shareLabel sizeToFitTextWidth:220];
    [_shareContainer addChild:_shareLabel];

    _shareNoButton = [[PNButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_shareLabel.frame)+10, 100, 60)];
    [_shareNoButton setTitle:@"No" forState:UIControlStateNormal];
    [_shareNoButton addTarget:self action:@selector(onShareNo) forControlEvents:UIControlEventTouchUpInside];
    [_shareContainer addChild:_shareNoButton];

    _shareYesButton = [[PNButton alloc] initWithFrame:CGRectMake(120, CGRectGetHeight(_shareLabel.frame)+10, 100, 60)];
    [_shareYesButton setTitle:@"Yes" forState:UIControlStateNormal];
    [_shareYesButton addTarget:self action:@selector(onShareYes) forControlEvents:UIControlEventTouchUpInside];
    [_shareContainer addChild:_shareYesButton];

    [_shareContainer sizeToFit];

    //--
    _anywhereLabel = [PNLabel labelWithText:@"Is it ok for the anywhere video to be shared onto other sites such as The Huffington Post, Twitter, Facebook, etc.?" andFont:FONT(16)];
    [_anywhereLabel sizeToFitTextWidth:220];
    [_anywhereContainer addChild:_anywhereLabel];

    _anywhereNoButton = [[PNButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_anywhereLabel.frame)+10, 100, 60)];
    [_anywhereNoButton setTitle:@"No" forState:UIControlStateNormal];
    [_anywhereNoButton addTarget:self action:@selector(onanywhereNo) forControlEvents:UIControlEventTouchUpInside];
    [_anywhereContainer addChild:_anywhereNoButton];

    _anywhereYesButton = [[PNButton alloc] initWithFrame:CGRectMake(120, CGRectGetHeight(_anywhereLabel.frame)+10, 100, 60)];
    [_anywhereYesButton setTitle:@"Yes" forState:UIControlStateNormal];
    [_anywhereYesButton addTarget:self action:@selector(onanywhereYes) forControlEvents:UIControlEventTouchUpInside];
    [_anywhereContainer addChild:_anywhereYesButton];

    [_anywhereContainer sizeToFit];

    _anywhereContainer.hidden = YES;

    //--

    _saveButton = [[PNButton alloc] initWithFrame:CGRectMake(0, 0, 220, 60)];
    [_saveButton setTitle:@"OK" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.enabled = NO;
    [self.view addSubview:_saveButton];

    NSArray* buttons = @[_shareYesButton, _shareNoButton, _anywhereYesButton, _anywhereNoButton, _saveButton];
    for (PNButton* button in buttons) {
        button.buttonColor = COLOR(grayColor);
        button.selectedColor = COLOR(blueColor);
        button.disabledColor = COLOR_ALPHA(grayColor, 0.5);
        button.cornerRadius = 5;
    }

}

- (void)viewWillLayoutSubviews {
    [self adjustLayout];
}

- (void)adjustLayout {
    CGRect b = self.view.bounds;
    _shareContainer.frame = CGRectSetTopCenter(b.size.width/2, 30, _shareContainer.frame);
    _anywhereContainer.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(_shareContainer.frame)+20, _anywhereContainer.frame);
    CGFloat y = _anywhereContainer.hidden ? CGRectGetMaxY(_shareContainer.frame) : CGRectGetMaxY(_anywhereContainer.frame);
    _saveButton.frame = CGRectSetTopCenter(b.size.width/2, y+40, _saveButton.frame);

    _anywhereContainer.alpha = _anywhereContainer.hidden ? 0.0 : 1.0; // for the sake of fading in/out during animation.
}

- (void)onShareNo {
    _shareNoButton.selected = YES;
    _shareYesButton.selected = NO;
    _anywhereContainer.hidden = YES;
    _saveButton.enabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self adjustLayout];
    }];
}

- (void)onShareYes {
    _shareNoButton.selected = NO;
    _shareYesButton.selected = YES;
    _anywhereContainer.hidden = NO;
    _saveButton.enabled = _shareNoButton.selected || (_shareYesButton.selected && (_anywhereNoButton.selected || _anywhereYesButton.selected));
    [UIView animateWithDuration:0.3 animations:^{
        [self adjustLayout];
    }];
}

- (void)onanywhereNo {
    _anywhereNoButton.selected = YES;
    _anywhereYesButton.selected = NO;
    _saveButton.enabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self adjustLayout];
    }];
}

- (void)onanywhereYes {
    _anywhereNoButton.selected = NO;
    _anywhereYesButton.selected = YES;
    _saveButton.enabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self adjustLayout];
    }];
}

- (void)onSave {
    NSString* pref = nil;
    if (_shareYesButton.selected && _anywhereYesButton.selected)
        pref = @"anywhere";
    else if (_shareYesButton.selected)
        pref = @"youtube";

    [self.delegate sharePreferenceController:self didSelectPreference:pref];
}

@end
