//
//  PersonStoryCardController.h
//  NoMe
//
//  Created by Jim Young on 2/3/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonStoryCardController : UIViewController

@property (nonatomic, strong) User* user;

- (void)scrollToIndex:(NSUInteger)index;

@end
