//
//  UnreadStoryIndicator.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "FriendRequestIndicator.h"
#import "StoryManager.h"

@interface FriendRequestIndicator()

@property (weak, nonatomic) StoryManager* storyManager;
@property (nonatomic, strong) PNLabel* label;

@end

@implementation FriendRequestIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [_storyManager removeObserver:self forKeyPath:@"unreadCount"];
        _storyManager = [StoryManager manager];

        self.label = [PNLabel labelWithText:@"88" andFont:FONT_B(16)];
        self.label.textColor = COLOR(whiteColor);
        self.label.textAlignment = NSTextAlignmentCenter;
        [self updateForValue:0];
        [self addSubview:self.label];

        [_storyManager addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];

    }
    return self;
}

- (void)updateForValue:(int)count {
    if (count) {
        self.label.text = (count > 9) ? @"9+" : [NSString stringWithFormat:@"%d", count];
        self.backgroundColor = COLOR(purpleColor);
    }
    else {
        self.label.text = nil;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateForValue:self.storyManager.unreadCount];
        [self setNeedsDisplay];
    });
}

- (void) dealloc {
    [self.storyManager removeObserver:self forKeyPath:@"unreadCount"];
    self.storyManager = nil;
}

@end
