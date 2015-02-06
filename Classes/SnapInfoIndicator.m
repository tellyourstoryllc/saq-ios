//
//  SnapInfoIndicator.m
//  NoMe
//
//  Created by Jim Young on 1/15/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "SnapInfoIndicator.h"
#import "Story.h"

@interface SnapInfoIndicator()

@end

@implementation SnapInfoIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.buttonColor = COLOR(whiteColor);
    return self;
}

- (void)setSnap:(SkyMessage *)snap
{
    if (_snap == snap)
        return;

    [self.KVOController unobserve:_snap];

    _snap = snap;
    [self updateForSnap];

    [self.KVOController observe:_snap keyPath:@"updated_at" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self updateForSnap];
                          }];

}

- (void)updateForSnap {

    BOOL showSourceIcon = NO;

    if (self.snap.user.isMe) {

        if ([self.snap isKindOfClass:[Story class]]) {
            Story* story = (Story*)self.snap;

            if ([story.permission isEqualToString:@"public"]) {
                [self maskWithImage:[UIImage imageNamed:@"globe"] inverted:YES];
                self.buttonColor = COLOR(publicColor);
            }
            else if ([story.permission isEqualToString:@"friends"]) {
                [self maskWithImage:[UIImage imageNamed:@"friends"] inverted:YES];
                [self setImage:[UIImage tintedImageNamed:@"friends" color:COLOR(blackColor)] forState:UIControlStateNormal];
                self.buttonColor = COLOR(friendColor);
            }
            else if ([story.permission isEqualToString:@"private"]) {
                [self maskWithImage:[UIImage imageNamed:@"lock"] inverted:YES];
                self.buttonColor = COLOR(privateColor);
            }
            else {
                [self setImage:nil forState:UIControlStateNormal];
                self.buttonColor = nil;;
            }
        }
        else {
            self.buttonColor = COLOR(privateColor);
            showSourceIcon = YES;
        }
    }
    else {
        self.buttonColor = COLOR(whiteColor);
        showSourceIcon = YES;
    }

    if (showSourceIcon) {
        if ([self.snap.source isEqualToString:@"camera"]) {
            [self maskWithImage:[UIImage imageNamed:@"knowme-bw2"] inverted:NO];
        }
        else {
            [self maskWithImage:[UIImage imageNamed:@"album"] inverted:NO];
        }
    }
}

@end
