//
//  LikeView.h
//  FFM
//
//  Created by Jim Young on 4/26/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface LikeView : UIView

@property (nonatomic, strong) SkyMessage* message;
@property (nonatomic, strong) Story* story;

@end
