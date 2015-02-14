//
//  SnapCollectionCell.h
//  SnapCracklePop
//
//  Created by Jim Young on 9/23/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnapCardView.h"

@interface SnapCollectionCell : UICollectionViewCell

@property (nonatomic, strong) SnapCardView* card;
@property (nonatomic, readonly) BOOL isFeatured;
@property (nonatomic, readonly) BOOL isPresentingOptions;

- (void)didBecomeFeatured;
- (void)willResignFeatured;

- (void)didPresentOptions;
- (void)willResignOptions;

@end
