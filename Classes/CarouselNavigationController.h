//
//  CarouselNavigationController.h
//  NoMe
//
//  Created by Jim Young on 1/24/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PNNavigationController.h"
#import "MainCarouselController.h"

@interface CarouselNavigationController : PNNavigationController

@property (nonatomic, assign) MainCarouselController* carouselController;

@end
