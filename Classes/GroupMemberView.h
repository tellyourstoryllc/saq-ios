//
//  GroupMemberView.h
//  groups
//
//  Created by Jim Young on 12/3/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "User.h"

@interface GroupMemberView : UIView

@property (nonatomic, strong) Group* group;
@property (nonatomic, strong) User* member;
@property (nonatomic, assign) CGFloat avatarSize;
@property (nonatomic, assign) BOOL angleName;

@end