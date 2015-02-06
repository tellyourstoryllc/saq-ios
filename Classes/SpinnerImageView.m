//
//  SpinnerImageView.m
//  NoMe
//
//  Created by Jim Young on 12/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SpinnerImageView.h"
#import "UIImage+AnimatedGIF.h"

@implementation SpinnerImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    NSString *gifFilepath = [[NSBundle mainBundle] pathForResource:@"spinner-animated" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:gifFilepath];
    self.image = [UIImage animatedImageWithAnimatedGIFData:gifData];

    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIImage* image = self.image.images[0];
    return image.size;
}

@end
