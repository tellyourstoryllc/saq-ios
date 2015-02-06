//
//  StoryMyCollectionViewController.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCarouselController.h"
#import "InviteViewController.h"
#import "StoryShareViewController.h"
#import "BaseSnapCollectionViewController.h"

@interface MyStoryViewController : BaseSnapCollectionViewController <StoryShareViewControllerDelegate>

- (void)scrollToBeginning;

@end
