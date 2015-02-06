//
//  LikeView.m
//  FFM
//
//  Created by Jim Young on 4/26/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LikeView.h"
#import "StatusView.h"
#import "PNUserPreferences.h"
#import "PNUIAlertView.h"

@interface LikeView()
@property (nonatomic, strong) UIImageView* image;
@end

@implementation LikeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:self.bounds];
        self.image.userInteractionEnabled = YES;
        [self addSubview:self.image];

        UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] init];
        [gest addTarget:self action:@selector(onTap)];
        [self.image addGestureRecognizer:gest];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
    self.image.frame = CGRectInset(b, b.size.width/5, b.size.height/5);
}

- (void)setMessage:(SkyMessage *)message {
    if (message == _message) return;
    [_message removeObserver:self forKeyPath:@"updated_at"];
    _message = message;
    [_message addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];
    [self updateImage];
}

- (void)setStory:(Story*)story {
    [self setMessage:story];
}

- (Story*)story {
    if ([_message isKindOfClass:[Story class]])
        return (Story*)_message;
    else
        return nil;
}

- (void)onTap {

    if (self.message && !self.message.user.isMe) {
        [self toggleStatus];
    }

    else {
        [StatusView showTitle:[NSString stringWithFormat:@"%@ ❤️", self.message.likes_count]
                      message:nil completion:nil duration:1.5];
    }

}

- (void)toggleStatus {
    if (self.message.likedValue) {
        [self.message unlikeWithCompletion:^(NSSet *entities, id responseObject, NSError *error) {
            on_main(^{
                [self updateImage];
            });
        }];
    }
    else {
        [StatusView showTitle:@"You ❤️ it!" message:nil completion:nil duration:1.5];
        [self.message likeWithCompletion:^(NSSet *entities, id responseObject, NSError *error) {
            on_main(^{
                [self updateImage];
            });
        }];
    }
}

- (void)updateImage {
    self.image.image = self.message.likedValue ? [UIImage imageNamed:@"heart-filled"] : [UIImage imageNamed:@"heart"];
}

- (void)dealloc {
    [_message removeObserver:self forKeyPath:@"updated_at"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.message) {
        on_main(^{
            [self updateImage];
        });
    }
}

@end
