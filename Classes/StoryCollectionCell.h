//
//  StoryCollectionCell.h
//  SnapCracklePop
//
//  Created by Jim Young on 9/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Story.h"
#import "SnapCollectionCell.h"
#import "SnapCardView.h"

@interface StoryCollectionCell : SnapCollectionCell

// If user is set, cell shows their last story.
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Story* story;

@property (nonatomic, assign) UIViewController* controller;

@end
