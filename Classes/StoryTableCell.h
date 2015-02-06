//
//  StoryTableCell.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import "SnapCardView.h"

@interface StoryTableCell : UITableViewCell

@property (nonatomic, strong) SnapCardView* snapCard;
@property (nonatomic, strong) Story* story;

+ (CGFloat) heightForStory:(Story*)story;

@end
