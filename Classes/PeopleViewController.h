//
//  StoryCollectionViewController.h
//  SnapCracklePop
//
//  Created by Jim Young on 9/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSnapCollectionViewController.h"
#import "MainCarouselController.h"
#import "InviteViewController.h"
#import "StoryShareViewController.h"

@interface PeopleViewController : BaseSnapCollectionViewController <StoryShareViewControllerDelegate>

@property (nonatomic, weak) MainCarouselController* deckController;

- (void)scrollToBeginning;

@end
