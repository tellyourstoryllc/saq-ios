//
//  InboundMessagesCollectionLayout.m
//  NoMe
//
//  Created by Jim Young on 1/13/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "HorizontalSnapsCollectionLayout.h"

@implementation HorizontalSnapsCollectionLayout

- (instancetype) init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 5;
        self.minimumLineSpacing = 5;
    }
    return self;
}

- (CGFloat)targetWidth {
    return 70;
}

- (CGFloat)aspectRatio {
    return 1.0;
}

@end
