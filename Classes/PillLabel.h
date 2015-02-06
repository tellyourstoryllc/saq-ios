//
//  PillLabel.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

//  A label with a "pill" (rounded corner) shaped background.
//  The left and right sides can be configured to be square/rounded separately.

#import <UIKit/UIKit.h>

@interface PillLabel : PNLabel

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) UIColor* pillColor;
@property (nonatomic, assign) BOOL leftCap;
@property (nonatomic, assign) BOOL rightCap;
@property (nonatomic, assign) BOOL topCap;
@property (nonatomic, assign) BOOL bottomCap;

@end
