//
//  GraffitiColorBar.h
//
//
//  Created by Jim Young on 3/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSColorPickerView.h"

@interface GraffitiColorBar : UIControl

@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIView* controlView;
@property (nonatomic, assign) CGRect inactiveFrame;
@property (nonatomic, assign) CGRect pickerFrame;
@property (nonatomic, strong) RSColorPickerView* picker;

- (void)setImage:(UIImage*)image;

@end