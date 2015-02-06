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
#import "AppDelegate.h"
#import "GroupViewController.h"
#import "InviteViewController.h"
#import "ContactSearchField.h"

#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "UpdateAvatarButton.h"
#import "UserAvatarView.h"
#import "AlertView.h"
#import "StatusView.h"
#import "GroupManager.h"
#import "Contact.h"

#import "CalloutBubble.h"
#import "PillLabel.h"
#import "UnreadMessageIndicator.h"

#import "AppViewController.h"
#import "PersonStoryCollectionController.h"
#import "StoryManager.h"

#import "PNCircularProgressView.h"
#import "PeopleViewSearchController.h"

@interface PeopleSearchView : UICollectionReusableView
@property (nonatomic, strong) PeopleViewSearchController* controller;
@end

@implementation PeopleSearchView

- (void)setController:(PeopleViewSearchController *)controller {
    _controller = controller;
    self.controller.view.frame = self.bounds;
    [self addSubview:self.controller.view];
}

@end

@interface PeopleViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,
ContactSearchFieldDelegate, UINavigationControllerDelegate, CardViewDelegate>

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) User* me;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) CalloutBubble* topBubble;

@property (nonatomic, assign) int featuredVideoLimit;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, assign) BOOL needsReload;

@property (nonatomic, strong) PeopleViewSearchController* searchController;

@end

@implementation PeopleViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
    [self.collection registerClass:[PersonCollectionCell class] forCellWithReuseIdentifier:@"user"];
    [self.collection registerClass:[PeopleSearchView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"search"];

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

    self.navigationItem.title = @"meet PEOPLE";
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
        
        [TutorialBubble dismissTutorialNamed:@"center_feed"];
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

    self.searchController = [PeopleViewSearchController new];
    self.searchController.storyResults.delegate = self;
    self.searchController.peopleResults.delegate = self;
    self.searchController.collection = self.collection;
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    else if (section == 1) {
        id sectionInfo = [[self.searchController.peopleResults sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
    else if (section == 2) {
        id sectionInfo = [[self.searchController.storyResults sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
    else {
        id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1) {
        User* user = [self.searchController.peopleResults.fetchedObjects objectAtIndex:indexPath.row];
        PersonCollectionCell* cell = (PersonCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"user" forIndexPath:indexPath];
        cell.user = user;
        cell.clipsToBounds = YES;

        return cell;
    }
    else if (indexPath.section == 2) {
        Story* story = [self.searchController.storyResults.fetchedObjects objectAtIndex:indexPath.row];
        StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
        cell.card.delegate = self;
        cell.controller = self;
        cell.story = story;
        cell.clipsToBounds = YES;

        return cell;
    }
    else {
        Story* story = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
        cell.card.delegate = self;
        cell.controller = self;
        cell.story = story;
        cell.clipsToBounds = YES;
        
        return cell;
    }
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

    if (indexPath.section == 2 || indexPath.section == 3) {
        PersonStoryCollectionController* vc = [PersonStoryCollectionController new];
        Story* story = (Story*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        vc.user = story.user;

        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
            [self presentViewController:vc animated:YES completion:nil];
        
        PNLOG(@"story_tiles.select");
    }
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
         viewForSupplementaryElementOfKind:(NSString *)kind
                               atIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        PeopleSearchView* view = [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                                                             withReuseIdentifier:@"search"
                                                                                    forIndexPath:indexPath];
        view.controller = self.searchController;
        return view;
    }

    return [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                               withReuseIdentifier:@"blank"
                                                      forIndexPath:indexPath];
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGSizeMake(self.view.bounds.size.width, 60);
    else
        return CGSizeZero;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.searchController.editing = NO;
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

    if (controller == self.searchController.peopleResults)
        sectionIndex = 1;
    else if (controller == self.searchController.storyResults)
        sectionIndex = 2;
    else if (controller == self.fetchedResultsController)
        sectionIndex = 3;

    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath {

    if (controller == self.searchController.peopleResults) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
    }
    else if (controller == self.searchController.storyResults) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:2];
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:2];
    }
    else if (controller == self.fetchedResultsController) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:3];
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:3];
    }

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
