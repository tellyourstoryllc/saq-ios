//
//  SnapCollectionViewController.h
//  SnapCracklePop
//
//  Created by Jim Young on 9/23/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCarouselController.h"
#import "InviteViewController.h"
#import "StoryShareViewController.h"
#import "BaseSnapCollectionViewController.h"

@interface InboxViewController : BaseSnapCollectionViewController <StoryShareViewControllerDelegate>

@property (nonatomic, weak) MainCarouselController* deckController;

- (void)scrollToBeginning;

@end
