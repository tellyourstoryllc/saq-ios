//
//  TodayViewController.h
//  Recent Stories
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>

@interface TodayBaseViewController : UIViewController<NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIView *cardLeft;
@property (weak, nonatomic) IBOutlet UIView *cardMiddle;
@property (weak, nonatomic) IBOutlet UIView *cardRight;

@property (nonatomic, strong) UILabel* labelLeft;
@property (nonatomic, strong) UILabel* labelMiddle;
@property (nonatomic, strong) UILabel* labelRight;

@property (nonatomic,strong) UIButton* buttonLeft;
@property (nonatomic,strong) UIButton* buttonMiddle;
@property (nonatomic,strong) UIButton* buttonRight;

- (void)clearCards;
- (void)onTouch:(id)sender;
- (void)removeAllSubviews:(UIView*)view;
- (void)expandAllSubviews:(UIView*)parent;

@end
