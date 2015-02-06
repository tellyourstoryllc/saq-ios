//
//  GroupMemberView.m
//  groups
//
//  Created by Jim Young on 12/3/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "GroupMemberView.h"
#import "UIImageView+AFNetworking.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface GroupMemberView()

@property (nonatomic, strong) PNLabel* nameLabel;
@property (nonatomic, strong) UIImageView* avatarView;

@end

@implementation GroupMemberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.nameLabel = [[PNLabel alloc] init];
        self.nameLabel.font = FONT_B(14);
        self.nameLabel.textColor = COLOR(darkGrayColor);
        [self addSubview:self.nameLabel];

        self.avatarView = [[UIImageView alloc] init];
        self.avatarView.clipsToBounds = YES;
        self.avatarView.layer.borderColor = [COLOR(grayColor) CGColor];
        self.avatarView.layer.borderWidth = 2.0;
        [self addSubview:self.avatarView];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat m = 10;

    self.avatarView.frame = CGRectMake(0,0,self.avatarSize,self.avatarSize);
    self.avatarView.layer.cornerRadius = self.avatarSize/2;
    if (self.angleName) {
        self.nameLabel.frame = CGRectMake(0,0,100,20);
        self.nameLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(77));
        self.nameLabel.frame = CGRectSetTopCenter(CGRectGetMidX(self.avatarView.frame), CGRectGetMaxY(self.avatarView.frame)+2*m, self.nameLabel.frame);
    }
    else {
        [self.nameLabel sizeToFit];
        self.nameLabel.frame = CGRectSetTopCenter(CGRectGetMidX(self.avatarView.frame), CGRectGetMaxY(self.avatarView.frame), self.nameLabel.frame);
    }
}

- (void)setMember:(User *)member {
    _member = member;
    [self.avatarView setImageWithURL:[NSURL URLWithString:_member.avatar_url] placeholderImage:nil];
    self.nameLabel.text = _member.name;
}

@end
