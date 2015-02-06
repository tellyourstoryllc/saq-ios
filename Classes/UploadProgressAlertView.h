//
//  PNUploadProgressView.h
//  Peanut
//
//  Created by Jim Young on 6/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PNStatusView.h"

@interface UploadProgressAlertView : PNStatusView

@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) PNLabel* progressLabel;

- (void)setProgress:(float)progress;
- (void)addButton:(UIButton*)button;

@end
