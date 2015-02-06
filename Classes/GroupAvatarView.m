//
//  GroupAvatarView.m
//  groups
//
//  Created by Jim Young on 1/21/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "GroupAvatarView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"

@interface GroupAvatarView()
@property (assign) BOOL isLoading;
@property (assign) BOOL shouldRetry;
@end

@implementation GroupAvatarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.borderWidth = 0.0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layer.cornerRadius = self.frame.size.height/2;
}

- (void)setGroup:(Group *)group {
    if (_group != group) {
        [_group removeObserver:self forKeyPath:@"avatar_url"];
        _group = group;
        self.image = nil;
        [self loadImage];
        [group addObserver:self forKeyPath:@"avatar_url" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"avatar_url"]) {
        self.image = nil;
        [self loadImage];
    }
}

- (void)loadImage {
    if (!self.isLoading && (self.shouldRetry || !self.image)) {
        if (self.group.avatar_url) {
            self.isLoading = YES;
            __weak GroupAvatarView* weakSelf = self;
            [self setImageWithURL:[NSURL URLWithString:self.group.avatar_url]
                 placeholderImage:[UIImage imageNamed:@"default-room"]
                          options:SDWebImageRetryFailed
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                            if (error) {
                                weakSelf.shouldRetry = YES;
                            }
                            else {
                                weakSelf.shouldRetry = NO;
                                if (image.images)
                                    [weakSelf setImage:[image.images firstObject]];
                            }
                            weakSelf.isLoading = NO;
                        }];
        }
        else {
            [self setImage:[UIImage imageNamed:@"default-room"]];
        }
    }
}

- (void)dealloc {
    [self.group removeObserver:self forKeyPath:@"avatar_url"];
}

@end
