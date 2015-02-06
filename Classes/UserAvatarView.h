//
//  UserAvatarView.h
//  groups
//
//  Created by Jim Young on 1/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserAvatarView : UIView

@property (nonatomic, strong) User* user;
@property (nonatomic, strong) UIImage* image;

@end
