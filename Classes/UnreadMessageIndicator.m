//
//  UnreadMessageIndicator.m
//
//
//  Created by Jim Young on 3/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "UnreadMessageIndicator.h"
#import "GroupManager.h"

@interface UnreadMessageIndicator()

@property (weak, nonatomic) GroupManager* groupManager;
@property (nonatomic, strong) PNLabel* label;

@end

@implementation UnreadMessageIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [_groupManager removeObserver:self forKeyPath:@"unreadCount"];
        _groupManager = [GroupManager manager];

        self.label = [PNLabel labelWithText:@"88" andFont:FONT_B(16)];
        self.label.textColor = COLOR(whiteColor);
        self.label.textAlignment = NSTextAlignmentCenter;
        [self updateForValue:0];
        [self addSubview:self.label];

        [_groupManager addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];

    }
    return self;
}

- (void)updateForValue:(int)count {
    if (count) {
        self.label.text = [NSString stringWithFormat:@"%d", count];
        self.backgroundColor = COLOR(redColor);
    }
    else {
        self.label.text = nil;
        self.backgroundColor = [UIColor clearColor];
        [self.layer removeAllAnimations];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateForValue:self.groupManager.unreadCount];
        [self setNeedsDisplay];
    });
}

- (void) dealloc {
    [self.groupManager removeObserver:self forKeyPath:@"unreadCount"];
    self.groupManager = nil;
}

@end
