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

@property PNButton* meButton;
@property PNButton* peopleButton;
@property PNButton* linksButton;
@property PNButton* inboxButton;

@end

@implementation CarouselTabView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.meButton = [PNButton new];
    self.meButton.disabledColor = COLOR(greenColor);
    [self.meButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMe)]];
    [self.meButton setImage:[UIImage tintedImageNamed:@"record" color:[self.meButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.meButton setImage:[UIImage tintedImageNamed:@"record" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
    [self addSubview:self.meButton];

    self.peopleButton = [PNButton new];
    self.peopleButton.disabledColor = COLOR(turquoiseColor);
    [self.peopleButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPeople)]];
    [self.peopleButton setImage:[UIImage tintedImageNamed:@"play-icon" color:[self.peopleButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.peopleButton setImage:[UIImage tintedImageNamed:@"play-icon" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
    [self addSubview:self.peopleButton];

    self.linksButton = [PNButton new];
    self.linksButton.disabledColor = COLOR(blueColor);
    [self.linksButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLinks)]];
    [self.linksButton setImage:[UIImage tintedImageNamed:@"help" color:[self.linksButton.disabledColor darken:15]] forState:UIControlStateNormal];
    [self.linksButton setImage:[UIImage tintedImageNamed:@"help" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
    [self addSubview:self.linksButton];

//    self.inboxButton = [PNButton new];
//    self.inboxButton.disabledColor = COLOR(purpleColor);
//    [self.inboxButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInbox)]];
//    [self.inboxButton setImage:[UIImage tintedImageNamed:@"message" color:[self.inboxButton.disabledColor darken:15]] forState:UIControlStateNormal];
//    [self.inboxButton setImage:[UIImage tintedImageNamed:@"message" color:COLOR(whiteColor)] forState:UIControlStateDisabled];
//    [self addSubview:self.inboxButton];

    for (PNButton* button in [self allButtons]) {
        button.buttonColor = [[button.disabledColor desaturate:0] darken:0];
//        button.buttonColor = [[button.disabledColor desaturate:50] darken:25];
    }

    return self;
}

- (void)layoutSubviews {

    CGRect b = self.bounds;

    CGFloat buttonWidth = (b.size.width+10)/[[self allButtons] count];
    CGRect buttonRect = CGRectMake(0, 0, buttonWidth, b.size.height);

    self.meButton.frame = buttonRect;
    self.peopleButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.meButton.frame), 0, buttonRect);
    self.linksButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.peopleButton.frame), 0, buttonRect);

}

- (NSArray*)allButtons {
    return @[self.meButton, self.peopleButton, self.linksButton];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;

    for (PNButton* button in [self allButtons]) {
        button.enabled = YES;
    }

    switch (_currentIndex) {

        case 0:
            self.meButton.enabled = NO;
            break;

        case 1:
            self.peopleButton.enabled = NO;
            break;

        case 2:
            self.linksButton.enabled = NO;
            break;

//        case 3:
//            self.inboxButton.enabled = NO;
//            break;

        default:
            break;
    }
}

- (void)onPeople {
    [self.carouselController openPeople];
}

- (void)onMe {
    [self.carouselController openMyStory];
}

- (void)onLinks {
    [self.carouselController scrollToIndex:2 withCompletion:nil];
}

- (void)onInbox {
    [self.carouselController openInbox];
}

@end
