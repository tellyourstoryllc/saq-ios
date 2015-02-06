//
//  AddStoryCollectionCell.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNCamera.h"

@interface AddStoryCamcorder : PNCamera
- (void) snapWithCompletion:(void (^)(UIImage* snap))completion;
@end

@interface AddStoryCollectionCell : UICollectionViewCell

@property (nonatomic, strong) AddStoryCamcorder* camcorder;
@property (nonatomic, readonly) PNLabel* plusLabel;

- (void)startCamera;
- (void)stopCamera;

@end
