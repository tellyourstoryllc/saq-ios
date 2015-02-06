//
//  OneToOneDetailViewController.h
//  groups
//
//  Created by Jim Young on 12/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "MainCarouselController.h"

@interface OneToOneDetailViewController : PNSimpleTableViewController
@property (nonatomic, strong) Group *group;
@property (nonatomic, weak) MainCarouselController *deckController;
@end
