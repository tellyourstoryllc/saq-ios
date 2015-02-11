//
//  MetaMessageView.h
//  FFM
//
//  Created by Jim Young on 4/26/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetaMessageView : UIView

@property (nonatomic, strong) SkyMessage* message;

@property (nonatomic, strong) PNLabel* label;
@property (nonatomic, strong) UIImageView* imageView;

+ (CGSize) sizeForMessage:(SkyMessage*)message maxWidth:(CGFloat)maxWidth;

@end