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

@end

@implementation SharePreferenceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(whiteColor);

    _shareContainer = [PNView new];
    [self.view addSubview:_shareContainer];

    //--
    _shareLabel = [PNLabel labelWithText:@"Is it OK to post your video on our YouTube channel?" andFont:FONT(16)];
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
    
    _saveButton = [[PNButton alloc] initWithFrame:CGRectMake(0, 0, 220, 60)];
    [_saveButton setTitle:@"OK" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.hidden = YES;
    [self.view addSubview:_saveButton];

    NSArray* buttons = @[_shareYesButton, _shareNoButton, _saveButton];
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
    _shareContainer.frame = CGRectSetTopCenter(b.size.width/2, b.size.height/(1+GOLDEN_MEAN), _shareContainer.frame);
    CGFloat y = CGRectGetMaxY(_shareContainer.frame);
    _saveButton.frame = CGRectSetTopCenter(b.size.width/2, y+40, _saveButton.frame);
}

- (void)onShareNo {
    _shareNoButton.selected = YES;
    _shareYesButton.selected = NO;
    _saveButton.hidden = NO;
}

- (void)onShareYes {
    _shareNoButton.selected = NO;
    _shareYesButton.selected = YES;
    _saveButton.hidden = NO;
}

- (void)onSave {
    NSString* pref = _shareYesButton.selected ? @"anywhere" : nil;
    [self.delegate sharePreferenceController:self didSelectPreference:pref];
}

@end
