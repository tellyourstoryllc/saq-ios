//
//  UserAvatarView.m
//  groups
//
//  Created by Jim Young on 1/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "UserAvatarView.h"
#import "FastMediaLoader.h"
#import "SnapCardView.h"

@interface UserAvatarView()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) SnapCardView* card;

@end

@implementation UserAvatarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.borderWidth = 0.0;

        self.card = [[SnapCardView alloc] initWithFrame:self.bounds];
        [self addSubview:self.card];

        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];

    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
    self.card.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage*)image {
    return self.imageView.image;
}

- (void)setUser:(User *)user {
    if (_user != user) {
        [self.KVOController unobserve:_user];
        _user = user;
        [self update];
        __weak UserAvatarView* weakSelf = self;
        if (_user) {
            [self.KVOController observe:_user keyPath:@"updated_at" options:NSKeyValueObservingOptionNew
                                  block:^(id observer, id object, NSDictionary *change) {
                                      [weakSelf update];
                                  }];
        }
    }

    if (!user) {
        self.layer.borderColor = [COLOR(grayColor) CGColor];
        self.imageView.image = nil;
    }
}

- (void)update {
    if (self.user.avatar_url) {
        [[FastMediaLoader shared] loadImageForUrlString:self.user.avatar_url
                                         withCompletion:^(UIImage *image) {
                                             on_main(^{
                                                 self.image = image;
                                                 self.card.message = nil;
                                             });
                                         }];
    }
    else if (self.user.last_story) {
        self.card.message = self.user.last_story;
        [self.card loadContentWithCompletion:^{
            self.image = nil;
        }];
    }
    else {
        self.image = [UIImage imageNamed:@"placeholder-user-avatar"];
    }
}

@end
