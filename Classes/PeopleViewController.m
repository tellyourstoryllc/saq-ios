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
#import "Story.h"
#import "Api.h"
#import "App.h"
#import "FlagReason.h"
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
#import "PushPermissionManager.h"

#import "PNCircularProgressView.h"
#import "UIScrollView+SVInfiniteScrolling.h"

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
@property (nonatomic, assign) int lastOffset;

@property (nonatomic, assign) BOOL shouldSkipPush;

@end

@implementation PeopleViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
    [self.collection registerClass:[PersonCollectionCell class] forCellWithReuseIdentifier:@"user"];
    [self.collection registerClass:[AddStoryCollectionCell class] forCellWithReuseIdentifier:@"add_story"];

    [[StoryManager manager] addObserver:self forKeyPath:@"isLoading" options:NSKeyValueObservingOptionNew context:nil];

    __weak PeopleViewController* weakSelf = self;
    [self.collection addInfiniteScrollingWithActionHandler:^{

        NSMutableDictionary *params = [ @{ @"limit" : @"40", @"offset" : @(weakSelf.lastOffset) } mutableCopy];

        [[StoryManager manager] loadPublicFeedWithParams:params
                                           andCompletion:^(NSSet *stories) {
                                               on_main(^{
                                                   [weakSelf.collection.infiniteScrollingView stopAnimating];

                                                   if(stories.count == 0) {
                                                       weakSelf.collection.showsInfiniteScrolling = NO;
                                                   }
                                                   weakSelf.lastOffset += 40;
                                               });
                                           }];
        
    }];

}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsController];
    self.featuredVideoLimit = [App simulatanenousVideoLimit];

    UIColor* navColor = COLOR(turquoiseColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(24),
                                        NSForegroundColorAttributeName:COLOR(whiteColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(whiteColor)];

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
    if (!self.shouldSkipPush) {
        self.shouldSkipPush = YES;
        [self unfeatureVideos];
        [[PushPermissionManager manager] requestWithCompletion:^(NSData *token) {
            [self featureVideos];
        }];
    }
}

-(void)initFetchedResultsController {
    if (self.fetchedResultsController)
        return;

    NSManagedObjectContext* context = [App managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Story"];
    request.predicate = [NSPredicate predicateWithFormat:@"obliterated != YES AND id != NULL AND in_feed = YES"];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                ];
    request.fetchLimit = 500;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

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

-(NSInteger)addCellSpacing {
    return 16;
}

-(NSInteger)numberOfAddCellsBeforeResult:(NSInteger)resultRow {
    return 1 + (int)(resultRow/([self addCellSpacing]-1));
}

-(NSInteger)numberOfAddCellsBeforeRow:(NSInteger)collectionRow {
    return 1 + (int)(collectionRow/([self addCellSpacing]));
}

-(BOOL)isRowAnAddCell:(NSInteger)collectionRow {
    return collectionRow % [self addCellSpacing] == 0;
}

-(NSInteger)collectionIndexForResult:(NSInteger)resultRow {
    return resultRow + [self numberOfAddCellsBeforeResult:resultRow];
}

-(NSInteger)resultRowForCollectionRow:(NSInteger)collectionRow {
    return collectionRow - [self numberOfAddCellsBeforeRow:collectionRow];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSInteger count = [sectionInfo numberOfObjects];
    int result = count + [self numberOfAddCellsBeforeResult:count];
    return result;
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
        NSIndexPath* adjustedPath = [NSIndexPath indexPathForRow:[self resultRowForCollectionRow:indexPath.row] inSection:0];
        Story* story = [self.fetchedResultsController existingObjectAtIndexPath:adjustedPath];
        StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
        cell.card.delegate = self;
        cell.controller = self;
        cell.story = story;
        cell.clipsToBounds = YES;

        cell.userInteractionEnabled = YES;
        cell.card.userInteractionEnabled =YES;

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
    id item = [collectionView cellForItemAtIndexPath:indexPath];
    if ([item isKindOfClass:[StoryCollectionCell class]]) {
        StoryCollectionCell* cell = (StoryCollectionCell*)item;

        if (cell.isPresentingOptions) {
//            [cell.card.message likeWithCompletion:nil];
        }
        else if (cell.isFeatured) {
            [self hideOptions];
            [cell willResignFeatured];
        }
        else {
            [self hideOptions];
            [self unfeatureVideos];
            [self featureVideoAt:item];
        }
    }
}

#pragma mark NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent %@", self);
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

-(void)controller:(NSFetchedResultsController *)controller
 didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex
    forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    NSLog(@"didChangeSection");

    sectionIndex = 0;
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"didChangeObject");

    indexPath = [NSIndexPath indexPathForRow:[self collectionIndexForResult:indexPath.row] inSection:indexPath.section];
    newIndexPath = [NSIndexPath indexPathForRow:[self collectionIndexForResult:newIndexPath.row] inSection:newIndexPath.section];

    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            [_itemChanges addObject:change];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            [_itemChanges addObject:change];
            break;
        case NSFetchedResultsChangeUpdate:
//            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            [_itemChanges addObject:change];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    NSLog(@"controllerDidChangeContent");
//    if (_itemChanges.count) {
//        [self.collection reloadData];
//        [self collectionDidChange];
//    }
//
//    _itemChanges = nil;
//    _sectionChanges = nil;

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
            self.billboard.text = nil;
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
    [self unfeatureVideos];
    [[AppViewController sharedAppViewController] openMyStory];
}

#pragma mark CardViewDelegate methods

- (void)card:(SnapCardView *)card didSelectLike:(SkyMessage *)snap {
    [snap likeWithCompletion:nil];
}

- (void)card:(SnapCardView *)card didSelectFlag:(SkyMessage *)snap {
    __block NSDictionary* reasons = [FlagReason dictionary];
    __block NSMutableArray* buttonText = [[reasons allKeys] mutableCopy];
    [buttonText addObject:@"Cancel"];

    AlertView* av = [[AlertView alloc] initWithTitle:@"Report Video"
                                             message:@"Please report any inappropriate or offensive content that you find"
                                      andButtonArray:buttonText];
    [av showWithCompletion:^(NSInteger buttonIndex) {
        if (buttonIndex < reasons.count) {
            NSString* reasonText = buttonText[buttonIndex];
            NSString* reasonId = reasons[reasonText];

            if ([snap isKindOfClass:[Story class]]) {
                Story* story = (Story*)snap;
                [story apiFlagWithReason:reasonId
                           andCompletion:^(NSSet *entities, id responseObject, NSError *error) {
                               [PNUIAlertView showWithMessage:@"Thank you. Our staff will review this video."];
                           }];
            }
        }
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

-(void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
