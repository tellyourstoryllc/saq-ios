//
//  PeopleSearchController.h
//  NoMe
//
//  Created by Jim Young on 1/10/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleViewSearchController : UIViewController

@property (strong, nonatomic) NSFetchedResultsController* peopleResults;
@property (strong, nonatomic) NSFetchedResultsController* storyResults;
@property (nonatomic, assign) UICollectionView* collection;

@end
