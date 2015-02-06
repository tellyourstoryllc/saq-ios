//
//  PersonCollectionCell.m
//  NoMe
//
//  Created by Jim Young on 1/11/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PersonCollectionCell.h"
#import "UserAvatarView.h"
#import "Story.h"

@interface PersonCollectionCell()

@property UserAvatarView* avatar;

@end

@implementation PersonCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.backgroundColor = COLOR(orangeColor);

    self.avatar = [[UserAvatarView alloc] initWithFrame:self.bounds];
    [self addSubview:self.avatar];

    return self;
}

- (void)setUser:(User *)user {
    _user = user;
    self.avatar.user = user;
}

@end
