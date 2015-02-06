//
//  BaseSnapCollectionViewController.h
//  NoMe
//
//  Created by Jim Young on 1/11/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCarouselController.h"
#import "SnapCollectionCell.h"
#import "SnapCardView.h"
#import "PNCircularProgressView.h"

@interface BaseSnapCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, CardViewDelegate>

@property (nonatomic, weak) MainCarouselController* deckController;
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) PNLabel* billboard;
@property (nonatomic, strong) PNCircularProgressView* circleProgress;

-(SnapCollectionCell*)snapCollectionCellForStory:(Story*)story;
-(SnapCollectionCell*)snapCollectionCellForUser:(User*)user;

-(void)setupView;
-(void)featureVideos;
-(void)unfeatureVideos;
-(int)featuredVideoLimit;
-(NSArray*)visibleVideoCells;

-(void)collectionDidChange;
-(void)disconnectData;
-(void)reconnectData;

-(void)reset;

@end