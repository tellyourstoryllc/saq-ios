//
//  MyStoryController.h
//  TellYourStory
//
//  Created by Jim Young on 2/9/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeViewController.h"

@interface MyStoryController : UIViewController

@property (nonatomic, assign) MeViewController* meController;
@property (nonatomic, strong) User* user;

- (void)showOptions;

@end
