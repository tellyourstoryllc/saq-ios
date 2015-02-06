//
//  StoryCamcorder.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCamera.h"
#import "StoryPublishView.h"

@interface StoryCamera : BaseCamera

@property (nonatomic, strong) StoryPublishView* publishView;

@end
