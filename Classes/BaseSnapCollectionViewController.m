//
//  BaseSnapCollectionViewController.m
//  NoMe
//
//  Created by Jim Young on 1/11/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "BaseSnapCollectionViewController.h"
#import "SnapCollectionLayout.h"
#import "App.h"

@interface BaseSnapCollectionViewController ()

@property (nonatomic, weak) SkyMessage* lastFeaturedStory;
@property (nonatomic, assign) CMTime lastFeaturedStoryTime;

@end

@implementation BaseSnapCollectionViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    CGRect bounds = self.view.bounds;
    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.circleProgress = [[PNCircularProgressView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width/4,bounds.size.width/4)];
    self.circleProgress.lineWidth = 5;
    self.circleProgress.tintColor = COLOR(orangeColor);
    self.circleProgress.hidden = YES;
    [self.view addSubview:self.circleProgress];

    self.billboard = [[PNLabel alloc] initWithFrame:CGRectZero];
    self.billboard.textAlignment = NSTextAlignmentCenter;
    self.billboard.font = FONT_B(24);
    self.billboard.textColor = COLOR(greenColor);
    [self.view addSubview:self.billboard];

    self.collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[SnapCollectionLayout new]];
    self.collection.dataSource = self;
    self.collection.delegate = self;
    self.collection.backgroundColor = [UIColor clearColor];
    self.collection.canCancelContentTouches = YES;
    self.collection.alwaysBounceVertical = YES;
    self.collection.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"blank"];
    [self.collection registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"blank"];
    [self.collection registerClass:[UICollectionReusableView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"blank"];
    [self.view addSubview:self.collection];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectData) name:kWillClearDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectData) name:kDidClearDataNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectData) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectDataDelayed) name:UIApplicationWillEnterForegroundNotification object:nil];

}

-(void)viewDidLayoutSubviews {

    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;

    if (self.navigationController) {
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusBarHeight = 20;
        self.collection.contentInset = UIEdgeInsetsMake(navBarHeight+statusBarHeight+4, 0, 0, 0);
    }

    self.collection.frame = CGRectMakeCorners(0, 0, width, height);
    self.billboard.frame = CGRectMakeCorners(0, 0, width, height);
    self.billboard.frame = CGRectInset(self.billboard.frame, 8, 0);

    self.circleProgress.center = self.billboard.center;
}

-(int)featuredVideoLimit {
    return [App simulatanenousVideoLimit];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self setupView];
}

-(void)setupView {}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak BaseSnapCollectionViewController* weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf isViewVisible]) {
            if (weakSelf.lastFeaturedStory) {
                SnapCollectionCell* cell = [weakSelf featureStory:self.lastFeaturedStory];
                cell.card.shouldStartPlayingAtTime = weakSelf.lastFeaturedStoryTime;
            }
            else
                [weakSelf featureVideos];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    SnapCollectionCell* cell = (SnapCollectionCell*)[[self featuringVideos] firstObject];
    self.lastFeaturedStory = cell.card.message;
    self.lastFeaturedStoryTime = cell.card.videoPlayer.currentTime;
    [self unfeatureVideos];
}

- (void) disconnectData {
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.collection.delegate = nil;
    self.collection.dataSource = nil;
    [self.collection reloadData];
}

- (void) reconnectData {
    self.collection.dataSource = self;
    self.collection.delegate = self;
    [self.collection reloadData];
}

- (void) reconnectDataDelayed {
    __weak BaseSnapCollectionViewController* weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf reconnectData];
    });
}

#pragma mark NSCollectionView methods

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell isKindOfClass:[SnapCollectionCell class]]) {
        SnapCollectionCell* storyCell = (SnapCollectionCell*)cell;
        storyCell.card.audioEnabled = NO;
        storyCell.card.contentMode = UIViewContentModeScaleAspectFill;
        [storyCell.card didAppear];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell isKindOfClass:[SnapCollectionCell class]]) {
        SnapCollectionCell* storyCell = (SnapCollectionCell*)cell;
        [storyCell willResignFeatured];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

// Size of section headers. Defaults to CGSizeZero
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

// Size of section footers. Defaults to CGSizeZero
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)collectionDidChange {
    __weak BaseSnapCollectionViewController* weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf isViewVisible]) {
            [weakSelf featureVideos];
        }
    });
};

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self unfeatureVideos];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self featureVideos];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self featureVideos];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self featureVideos];
}

- (void)card:(SnapCardView *)card didFinishPresenting:(SkyMessage *)snap {
    SnapCollectionCell* cell = [self cellForCard:card];
    if (cell) {
        [self hideOptions];

        [cell willResignFeatured];
        [cell didPresentOptions];

        id success = [self featureVideoAfter:cell];
        if (!success && self.visibleVideoCells.count > 2)
            [self featureVideos];
    }
}

- (void)featureVideos {

    NSArray* videoCells = [self visibleVideoCells];
    NSArray* unfeaturedCells = [videoCells filteredArrayUsingBlock:^BOOL(SnapCollectionCell* cell, NSDictionary *bindings) {
        return !cell.isFeatured;
    }];

    int activateCount = self.featuredVideoLimit - videoCells.count + unfeaturedCells.count;

    if (activateCount > 0) {
        for (SnapCollectionCell* cell in unfeaturedCells) {
            [cell didBecomeFeatured];
            activateCount--;
            if (!activateCount) break;
        }
    }
}

- (NSArray*)featuringVideos {
    NSArray* videoCells = [self visibleVideoCells];
    return [videoCells filteredArrayUsingBlock:^BOOL(SnapCollectionCell* cell, NSDictionary *bindings) {
        return cell.isFeatured;
    }];
}

- (void)unfeatureVideos {
    for (SnapCollectionCell* cell in [self visibleVideoCells]) {
        [cell willResignFeatured];
    }
}

- (void)hideOptions {
    for (SnapCollectionCell* cell in [self visibleVideoCells]) {
        [cell willResignOptions];
    }
}

- (SnapCollectionCell*)featureVideoAfter:(SnapCollectionCell*)currentCell {

    SnapCollectionCell* lastCell = nil;
    SnapCollectionCell* nextCell = nil;
    for (SnapCollectionCell* cell in [self visibleVideoCells]) {
        if (lastCell == currentCell) {
            nextCell = cell;
            break;
        }
        lastCell = cell;
    }

    [nextCell didBecomeFeatured];
    return nextCell;
}

- (void)featureVideoAt:(SnapCollectionCell*)target {
    for (SnapCollectionCell* cell in [self visibleVideoCells]) {
        if (cell == target) {
            [cell didBecomeFeatured];
            break;
        }
    }
}

- (SnapCollectionCell*)featureStory:(SkyMessage*)target {
    for (SnapCollectionCell* cell in [self visibleVideoCells]) {
        if ([cell.card.message isEqual:target]) {
            [cell didBecomeFeatured];
            return cell;
        }
    }
    return nil;
}

- (NSArray*)visibleVideoCells {
    NSArray* videoCells = [self.collection.visibleCells filteredArrayUsingBlock:^BOOL(UICollectionViewCell* cell, NSDictionary *bindings) {
        if ([cell isKindOfClass:[SnapCollectionCell class]]) {
            SnapCollectionCell* storyCell = (SnapCollectionCell*)cell;
            return storyCell.card.hasVideo;
        }
        else
            return NO;
    }];

    return [videoCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell* cell1, UICollectionViewCell* cell2) {
        NSInteger r1 = [[self.collection indexPathForCell:cell1] row];
        NSInteger r2 = [[self.collection indexPathForCell:cell2] row];
        if (r1 < r2)
            return NSOrderedAscending;
        else if (r1 > r2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

- (SnapCollectionCell*)cellForCard:(SnapCardView*)card {
    NSArray* cells =[[self visibleVideoCells] filteredArrayUsingBlock:^BOOL(SnapCollectionCell* cell, NSDictionary *bindings) {
        return cell.card == card;
    }];
    return [cells lastObject];
}

-(SnapCollectionCell*)snapCollectionCellForStory:(Story*)story {
    return nil;
}

-(SnapCollectionCell*)snapCollectionCellForUser:(User*)user {
    return nil;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)reset {}

-(BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
