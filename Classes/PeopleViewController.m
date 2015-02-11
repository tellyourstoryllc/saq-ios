//
//  StoryCollectionViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 9/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PeopleViewController.h"
#include <libkern/OSAtomic.h>
#import "Group.h"
#import "User.h"
#import "SkyMessage.h"
#import "Api.h"
#import "App.h"
#import "PNUserPreferences.h"

#import "StoryCollectionCell.h"
#import "PersonCollectionCell.h"
#import "AddStoryCollectionCell.h"

#import "AppDelegate.h"
#import "GroupViewController.h"

#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "AlertView.h"
#import "StatusView.h"
#import "GroupManager.h"
#import "Contact.h"

#import "CalloutBubble.h"
#import "PillLabel.h"
#import "UnreadMessageIndicator.h"

#import "AppViewController.h"
#import "StoryManager.h"

#import "PNCircularProgressView.h"

@interface PeopleViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, CardViewDelegate>

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) User* me;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) CalloutBubble* topBubble;

@property (nonatomic, assign) int featuredVideoLimit;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, assign) BOOL needsReload;

@end

@implementation PeopleViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
    [self.collection registerClass:[PersonCollectionCell class] forCellWithReuseIdentifier:@"user"];
    [self.collection registerClass:[AddStoryCollectionCell class] forCellWithReuseIdentifier:@"add_story"];

    [[StoryManager manager] addObserver:self forKeyPath:@"isLoading" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsController];
    self.featuredVideoLimit = [App simulatanenousVideoLimit];

    UIColor* navColor = COLOR(publicColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                        NSForegroundColorAttributeName:COLOR(blackColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(blackColor)];

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    self.navigationItem.title = @"Our Stories";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collection reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isViewVisible]) {
        [self featureVideos];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self unfeatureVideos];
}

-(void)initFetchedResultsController {

    if (self.fetchedResultsController)
        return;

    NSString* myUserId = [App userId] ?: [[User me] id];
    NSManagedObjectContext* context = [App managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Story"];
    request.predicate = [NSPredicate predicateWithFormat:@"in_feed = YES AND user.id != %@ AND id != NULL", myUserId];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                ];
    request.fetchLimit = 500;

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"feed"];

    [self.fetchedResultsController performFetch:nil];
    [self updateEmptyView];
    self.fetchedResultsController.delegate = self;
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.collection reloadData];
}

-(void)disconnectData {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [super disconnectData];
}

-(void)reconnectData {
    [self initFetchedResultsController];
    [super reconnectData];
}

#pragma mark NSCollectionView methods

-(NSInteger)addCellOffset {
    return 0;
}

-(NSInteger)addCellSpacing {
    return 10;
}

-(NSInteger)numberOfAddCellsForRow:(NSInteger)totalCells {
    if (totalCells < [self addCellSpacing])
        return 1;
    else
        return (totalCells + [self addCellOffset]) / [self addCellSpacing];
}

-(BOOL)isRowAnAddCell:(NSInteger)row {
    return (row - [self addCellOffset]) % [self addCellSpacing] == 0;
}

-(NSInteger)actualRowFor:(NSInteger)row {
    return row - [self numberOfAddCellsForRow:row];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSInteger count = [sectionInfo numberOfObjects];
    return count + [self numberOfAddCellsForRow:count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([self isRowAnAddCell:indexPath.row]) {
        AddStoryCollectionCell* cell = (AddStoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"add_story" forIndexPath:indexPath];
        for (UIGestureRecognizer* gesture in cell.gestureRecognizers) {
            [cell removeGestureRecognizer:gesture];
        }

        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddTapped)]];
        return cell;
    }
    else {
        Story* story = [self.fetchedResultsController.fetchedObjects objectAtIndex:[self actualRowFor:indexPath.row]];
        StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
        cell.card.delegate = self;
        cell.controller = self;
        cell.story = story;
        cell.clipsToBounds = YES;
        
        return cell;
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView
      willDisplayCell:(UICollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2 || indexPath.section == 3) {
        StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
        storyCell.card.audioEnabled = NO;
        storyCell.card.contentMode = UIViewContentModeScaleAspectFill;
        [storyCell.card didAppear];
    }
}

-(void)collectionView:(UICollectionView *)collectionView
 didEndDisplayingCell:(UICollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2 || indexPath.section == 3) {
        StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
        [storyCell willResignFeatured];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

-(void)controller:(NSFetchedResultsController *)controller
 didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex
    forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];

    sectionIndex = 0;
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath {

    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self.collection performBatchUpdates:^{
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collection insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collection deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeMove:
                    case NSFetchedResultsChangeUpdate:
                        break;
                }
            }];
        }
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collection insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collection deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        // Cell should update itself using KVO or other means.
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collection moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
        [self collectionDidChange];
    }];
}

// Convenience method
-(int)numberOfFetchResults {
    return [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}

-(void)updateEmptyView {

    if ([self numberOfFetchResults] == 0) {
        if ([[StoryManager manager] isLoading]) {
            self.billboard.text = @"Loading...";
            self.circleProgress.hidden = NO;
            [self.circleProgress startSpinProgressBackgroundLayer];
        }
        else {
            NSString* emptyLabelString = [Configuration stringFor:@"empty_feed_notice"] ?: [NSString stringWithFormat:@"?"];
            self.billboard.text = emptyLabelString;
            self.circleProgress.hidden = YES;
            [self.circleProgress stopSpinProgressBackgroundLayer];
        }
    }
    else {
        self.billboard.text = nil;
        self.circleProgress.hidden = YES;
        [self.circleProgress stopSpinProgressBackgroundLayer];
    }
}

-(void)scrollToBeginning {
    if (self.fetchedResultsController.fetchedObjects.count) {
        NSIndexPath* topPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collection scrollToItemAtIndexPath:topPath
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    on_main(^{
        [self updateEmptyView];
    });
}


- (void)onAddTapped {
    [[AppViewController sharedAppViewController] openMyStory];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

-(void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
