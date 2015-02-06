//
//  PNUploadProgressView.m
//  Peanut
//
//  Created by Jim Young on 6/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "UploadProgressAlertView.h"
#import "PNSupport.h"

@interface UploadProgressAlertView()
@property NSMutableArray* buttonArray;
@end

@implementation UploadProgressAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

//      self.titleLabel.font = [[Theme current] boldFontWithSize:18];

      self.buttonArray = [NSMutableArray arrayWithCapacity:2];

      self.progressView = [[UIProgressView alloc] init];
      [self addSubview:self.progressView];

      self.progressLabel = [[PNLabel alloc] init];
//      self.progressLabel.textColor = [[Theme current] whiteColor];
//      self.progressLabel.font = [[Theme current] lightFontWithSize:14.0];
      self.progressLabel.textAlignment = NSTextAlignmentCenter;
      [self addSubview:self.progressLabel];
    }
    return self;
}

- (void)showInView:(UIView *)view {
  [super showInView:view];
  self.frame = CGRectSetBottomCenter(view.bounds.size.width/2, view.bounds.size.height, self.frame);
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect b = self.bounds;
  CGFloat m = 5;
  CGFloat ml = 7;
  
  CGFloat maxY = MAX(CGRectGetMaxY(self.titleLabel.frame), CGRectGetMaxY(self.messageLabel.frame));

  self.progressView.frame = CGRectMake(m, maxY+m, b.size.width-2*m, 20);
  self.progressLabel.frame = CGRectOffset(CGRectInset(self.progressView.frame, 0, -5), 0, 15);

  // Layout buttons:
  maxY = CGRectGetMaxY(self.progressLabel.frame);
  for (UIView* button in self.buttonArray) {
    button.frame = CGRectMake(ml, maxY+m, b.size.width-2*ml, button.frame.size.height);
    maxY = CGRectGetMaxY(button.frame);
  }
}

- (void)setProgress:(float)progress {
  NSInteger percent = (int)(100*progress);
  self.progressView.progress = progress;
  self.progressLabel.text = [NSString stringWithFormat:@"%d%% complete", percent];
}

- (void)addButton:(UIButton *)button {
  [self.buttonArray addObject:button];
  [self addSubview:button];
}

@end