//
//  CarouselTabView.h
//  NoMe
//
//  Created by Jim Young on 12/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCarouselController.h"

@interface CarouselTabView : UIView

@property (nonatomic, assign) MainCarouselController* carouselController;
@property (nonatomic, assign) NSInteger currentIndex;
@end
