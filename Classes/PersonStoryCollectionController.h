//
//  PersonStoryViewController.h
//  NoMe
//
//  Created by Jim Young on 12/27/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BaseSnapCollectionViewController.h"

@interface PersonStoryCollectionController : BaseSnapCollectionViewController

@property (nonatomic, strong) User* user;

@end
