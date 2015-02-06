//
//  SnapCollectionLayout.m
//  SnapCracklePop
//
//  Created by Jim Young on 9/23/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCollectionLayout.h"
#import "AppViewController.h"

@implementation SnapCollectionLayout

- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = 2;
        self.minimumLineSpacing = 2;

        CGRect windowFrame = [[[[AppViewController sharedAppViewController] view] window] frame];
        int itemsPerRow = windowFrame.size.width / ([self targetWidth]+self.minimumInteritemSpacing);
        CGFloat calculatedWidth =  (windowFrame.size.width / itemsPerRow)-self.minimumInteritemSpacing;

        CGRect rect = CGRectIntegral(CGRectMake(0, 0, calculatedWidth, calculatedWidth*[self aspectRatio]));
        self.itemSize = CGSizeMake(rect.size.width, rect.size.height);
    }
    return self;
}

- (CGFloat)targetWidth {
    return 100.0;
}

- (CGFloat)aspectRatio {
    return 1.775;
}

@end
