//
//  CarouselTabView.m
//  NoMe
//
//  Created by Jim Young on 12/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CarouselTabView.h"
#import "UnreadMessageIndicator.h"

@interface CarouselTabView()

@property PNButton* peopleButton;
@property PNButton* meButton;
@property PNButton* cameraButton;
@property PNButton* friendsButton;
@property PNButton* inboxButton;

@property UnreadMessageIndicator* unreadMessageView;

@end

@implementation CarouselTabView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

//    self.backgroundColor = COLOR(blueColor);

    self.peopleButton = [PNButton new];
    self.peopleButton.disabledColor = COLOR(publicColor);
    [self.peopleButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPeople)]];
    [self.peopleButton setImage:[UIImage tintedImageNamed:@"globe" color:[self.peopleButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.peopleButton setImage:[UIImage tintedImageNamed:@"globe" color:COLOR(blackColor)] forState:UIControlStateDisabled];
    [self addSubview:self.peopleButton];

    self.friendsButton = [PNButton new];
    self.friendsButton.disabledColor = COLOR(friendColor);
    [self.friendsButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriends)]];
    [self.friendsButton setImage:[UIImage tintedImageNamed:@"friends" color:[self.friendsButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.friendsButton setImage:[UIImage tintedImageNamed:@"friends" color:COLOR(blackColor)] forState:UIControlStateDisabled];
    [self addSubview:self.friendsButton];

    self.cameraButton = [PNButton new];
    self.cameraButton.disabledColor = COLOR(blackColor);
    [self.cameraButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCamera)]];
    [self.cameraButton setImage:[UIImage tintedImageNamed:@"input-photo" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    [self addSubview:self.cameraButton];

    self.meButton = [PNButton new];
    self.meButton.disabledColor = COLOR(privateColor);
    [self.meButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMe)]];
    [self.meButton setImage:[UIImage tintedImageNamed:@"home" color:[self.meButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.meButton setImage:[UIImage tintedImageNamed:@"home" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
    [self addSubview:self.meButton];

    self.inboxButton = [PNButton new];
    self.inboxButton.disabledColor = COLOR(purpleColor);
    [self.inboxButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInbox)]];
    [self.inboxButton setImage:[UIImage tintedImageNamed:@"message" color:[self.inboxButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.inboxButton setImage:[UIImage tintedImageNamed:@"message" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
    [self addSubview:self.inboxButton];

    for (PNButton* button in [self allButtons]) {
        button.buttonColor = [[button.disabledColor desaturate:0] darken:0];
//        button.buttonColor = [[button.disabledColor desaturate:50] darken:25];
    }

    self.unreadMessageView = [[UnreadMessageIndicator alloc] initWithFrame:CGRectZero];
    self.unreadMessageView.userInteractionEnabled = NO;
    [self.inboxButton addSubview:self.unreadMessageView];

    return self;
}

- (void)layoutSubviews {

    CGRect b = self.bounds;

    CGFloat buttonWidth = (b.size.width+10)/5;
    CGRect buttonRect = CGRectMake(0, 0, buttonWidth, b.size.height);
    CGRect cameraButtonRect = CGRectMake(0, 0, buttonWidth-10, b.size.height);

    self.peopleButton.frame = buttonRect;
    self.friendsButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.peopleButton.frame), 0, buttonRect);
    self.cameraButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.friendsButton.frame), 0, cameraButtonRect);
    self.meButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.cameraButton.frame), 0, buttonRect);
    self.inboxButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.meButton.frame), 0, buttonRect);

    self.unreadMessageView.frame = CGRectSetMiddleRight(buttonRect.size.width-4, buttonRect.size.height/2, CGRectMake(0,0,36,36));
    self.unreadMessageView.layer.cornerRadius = 18;
}

- (NSArray*)allButtons {
    return @[self.peopleButton, self.friendsButton, self.meButton, self.inboxButton, self.cameraButton];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;

    for (PNButton* button in [self allButtons]) {
        button.enabled = YES;
    }

    switch (_currentIndex) {
        case 0:
            self.peopleButton.enabled = NO;
            break;

        case 1:
            self.friendsButton.enabled = NO;
            break;

        case 3:
            self.meButton.enabled = NO;
            break;

        case 4:
            self.inboxButton.enabled = NO;
            break;

        default:
            break;
    }
}

- (void)onPeople {
    [self.carouselController openPeople];
}

- (void)onFriends {
    [self.carouselController openFriends];
}

- (void)onCamera {
    [self.carouselController openCamera];
}

- (void)onMe {
    [self.carouselController openMyStory];
}

- (void)onInbox {
    [self.carouselController openInbox];
}

@end
