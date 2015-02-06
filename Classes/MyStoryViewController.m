//
//  StoryMyCollectionViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MyStoryViewController.h"
#include <libkern/OSAtomic.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Group.h"
#import "User.h"
#import "SkyMessage.h"
#import "Api.h"
#import "App.h"
#import "PNUserPreferences.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#import "StoryCollectionCell.h"
#import "AppDelegate.h"
#import "GroupViewController.h"

#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "UpdateAvatarButton.h"
#import "UserAvatarView.h"
#import "AlertView.h"
#import "StatusView.h"
#import "GroupManager.h"

#import "CalloutBubble.h"
#import "PillLabel.h"
#import "UnreadMessageIndicator.h"

#import "AppViewController.h"
#import "SnapCollectionLayout.h"
#import "StoryManager.h"

#import "AddStoryCollectionCell.h"
#import "MyProfileViewController.h"
#import "PersonStoryCardController.h"

@interface MyStoryViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,
UINavigationControllerDelegate, CardViewDelegate, PNCameraDelegate> {

}

@property (nonatomic, strong) User* me;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MyProfileViewController* profileController;

@property (nonatomic, assign) BOOL needsReload;
@property (nonatomic, assign) BOOL completedAPIFetch;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, strong) UIImage* snapshot;

@end

@implementation MyStoryViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    CGRect bounds = self.view.bounds;
    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
    [self.collection registerClass:[AddStoryCollectionCell class] forCellWithReuseIdentifier:@"add_story"];
    self.collection.backgroundColor = [UIColor clearColor];
    self.collection.canCancelContentTouches = YES;
    self.collection.alwaysBounceVertical = YES;

    [self.KVOController observe:[StoryManager manager]
                        keyPath:@"isLoading"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              on_main(^{
                                  [self updateEmptyView];
                              });
                          }];

    __weak MyStoryViewController* weakSelf = self;
    [self.collection addInfiniteScrollingWithActionHandler:^{

        NSString *path = [NSString stringWithFormat:@"/users/%@/stories", [App userId]];
        NSMutableDictionary *params = [ @{ @"limit" : @"40" } mutableCopy];

        NSString* lastStoryId = [[weakSelf.fetchedResultsController.fetchedObjects lastObject] id];
        if (lastStoryId)
            [params setObject:lastStoryId forKey:@"below_story_id"];

        [[Api sharedApi] postPath:path
                       parameters:params
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             on_main(^{
                                 [weakSelf.collection.infiniteScrollingView stopAnimating];

                                 if(!error && [entities count] == 0)
                                     weakSelf.collection.showsInfiniteScrolling = NO;

                                 if (!error)
                                     weakSelf.completedAPIFetch = YES;
                             });
                         }];
    }];

}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsController];

    UIColor* navColor = COLOR(privateColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                        NSForegroundColorAttributeName:COLOR(whiteColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(whiteColor)];

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    self.navigationItem.title = @"ME";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Me" style:UIBarButtonItemStylePlain target:nil action:nil];

    if (!self.me) {
        self.me = [User me];
        [self.view setNeedsLayout];
    }

    if ([self isRootController]) {
//        if (!self.navigationItem.leftBarButtonItem) {
//
//            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"input-photo"]
//                                                                                      style:UIBarButtonItemStylePlain
//                                                                                     target:self
//                                                                                     action:@selector(onCamera)];
//        }

        if (!self.navigationItem.leftBarButtonItem) {

            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-settings-filled"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(onSettings)];
        }
    }

}

- (void)onSettings {
    [[AppViewController sharedAppViewController] openSettings];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isViewVisible]) {

        if (!_completedAPIFetch && [App userId]) {
            NSString *path = [NSString stringWithFormat:@"/users/%@/stories", [App userId]];
            NSMutableDictionary *params = [ @{ @"limit" : @"40" } mutableCopy];
            [[Api sharedApi] postPath:path
                           parameters:params
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 if (!error)
                                     _completedAPIFetch = YES;
                             }];
        }

        [[self visibleAddStoryCell] startCamera];
    }
}

-(void) initFetchedResultsController {

    if (self.fetchedResultsController)
        return;

    NSString* myUserId = [App userId] ?: [[User me] id];
    NSManagedObjectContext* context = [App managedObjectContext];

    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Story"];

    request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND user.id = %@", myUserId];
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

    self.profileController = [MyProfileViewController new];
}

- (void) disconnectData {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.me = nil;
    self.collection.delegate = nil;
    self.collection.dataSource = nil;
    [self.collection reloadData];
}

- (void) reconnectData {
    [super reconnectData];
    [self initFetchedResultsController];
    self.me = [User me];
}

- (void) onUnreadMessage {
    [[AppViewController sharedAppViewController] openUnreadGroup];
}

- (void)didReceiveMemoryWarning {
    AddStoryCollectionCell* cell = (AddStoryCollectionCell*)[self.collection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    NSLog(@"YIKES!!!YIKES!!!YIKES!!!YIKES!!!YIKES!!!YIKES!!!YIKES!!! %@", cell.camcorder);
    [cell stopCamera];
}

#pragma mark NSCollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath* fetchedPath = [self fetchedIndexPathFor:indexPath];

    if (fetchedPath.row < 0) {
        AddStoryCollectionCell* cell = (AddStoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"add_story" forIndexPath:indexPath];
        cell.camcorder.delegate = self;
        for (UIGestureRecognizer* gesture in cell.gestureRecognizers) {
            [cell removeGestureRecognizer:gesture];
        }

        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddTapped:)]];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onAddPressed:)];
        longPress.minimumPressDuration = 0.5;
        [cell addGestureRecognizer:longPress];
        return cell;
    }
    else {
        Story* story = [self.fetchedResultsController.fetchedObjects objectAtIndex:fetchedPath.row];
        StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
        cell.card.delegate = self;
        cell.controller = self;
        cell.story = story;
        cell.clipsToBounds = YES;
        return cell;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView* view = [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                               withReuseIdentifier:@"blank"
                                                      forIndexPath:indexPath];
    if (indexPath.section == 0) {
        self.profileController.view.frame = view.bounds;
        [view addSubview:self.profileController.view];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath* fetchedIndexPath = [self fetchedIndexPathFor:indexPath];
    if (fetchedIndexPath.row < 0) {
        AddStoryCollectionCell* addCell = (AddStoryCollectionCell*)cell;
        if (self.isViewVisible)
            [addCell startCamera];
    }
    else if (fetchedIndexPath.row >= 0) {
        StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
        storyCell.card.audioEnabled = NO;
        storyCell.card.contentMode = UIViewContentModeScaleAspectFill;
        [storyCell.card didAppear];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath* fetchedIndexPath = [self fetchedIndexPathFor:indexPath];
    if (fetchedIndexPath.row < 0) {
        AddStoryCollectionCell* addCell = (AddStoryCollectionCell*)cell;
        [addCell stopCamera];
    }
    if (fetchedIndexPath.row >= 0) {
        StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
        [storyCell willResignFeatured];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath* fetchedIndexPath = [self fetchedIndexPathFor:indexPath];
    if (fetchedIndexPath.row >= 0) {
        Story* story = (Story*)[self.fetchedResultsController.fetchedObjects objectAtIndex:fetchedIndexPath.row];

        if (story.hasVideo || story.hasImage) {

            PersonStoryCardController* vc = [PersonStoryCardController new];
            vc.user = [User me];
            [vc scrollToIndex:fetchedIndexPath.row];
            [self.navigationController pushViewController:vc animated:YES];

//            SnapCardView* card = [[SnapCardView alloc] initWithFrame:self.view.window.bounds];
//            card.message = story;
//            card.delegate = self;
//
//            card.showDismissButton = YES;
//            card.showEditButton = YES;
//            card.showExportButton = YES;
//            card.showInfoButton = YES;
//
//            [card loadContent];
//            [card unhideControls];
//            [self.view.window addSubview:card];
//            [card didAppear];
//            [card didBecomeFeatured];
//
//            // Tap anywhere on the card to dismiss.
//            UITapGestureRecognizer* dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:card action:@selector(onDismiss)];
//            [card addGestureRecognizer:dismissGesture];
//
//            self.presentedCard = card;
//            [self.navigationController setNavigationBarHidden:YES];
//            [self setNeedsStatusBarAppearanceUpdate];

        }
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    NSIndexPath *collectionIndexPath = [self collectionIndexPathFor:indexPath];
    NSIndexPath *newCollectionIndexPath = [self collectionIndexPathFor:newIndexPath];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newCollectionIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = collectionIndexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = collectionIndexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[collectionIndexPath, newCollectionIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
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
        [self updateEmptyView];
        if ([self isViewVisible]) [self featureVideos];
    }];
}

- (NSIndexPath*)collectionIndexPathFor:(NSIndexPath*)fetchedIndexPath {
    return [NSIndexPath indexPathForRow:fetchedIndexPath.row+1 inSection:fetchedIndexPath.section];
}

- (NSIndexPath*)fetchedIndexPathFor:(NSIndexPath*)collectionIndexPath {
    return [NSIndexPath indexPathForRow:collectionIndexPath.row-1 inSection:collectionIndexPath.section];
}

- (AddStoryCollectionCell*)visibleAddStoryCell {
    for (UICollectionViewCell* cell in self.collection.visibleCells) {
        if ([cell isKindOfClass:[AddStoryCollectionCell class]]) {
            return (AddStoryCollectionCell*)cell;
        }
    }
    return nil;
}

- (int) numberOfFetchResults {
    return [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}

- (void)updateEmptyView {}

- (void)scrollToBeginning {
    if (self.fetchedResultsController.fetchedObjects.count) {
        NSIndexPath* topPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collection scrollToItemAtIndexPath:topPath
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
    }
}

- (void)reset {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [self.collection reloadData];
    [self featureVideos];
}

#pragma mark gesture actions

- (void)onAddTapped:(UIGestureRecognizer*)gesture {
    AddStoryCollectionCell* cell = [self visibleAddStoryCell];
    AddStoryCamcorder* camera = [cell camcorder];
    [camera snapWithCompletion:^(UIImage *snap) {

        camera.player.screenshot = snap;
        camera.player.hidden = NO;
        cell.plusLabel.hidden = YES;
        [camera stopPreview];

        self.snapshot = snap;
        PNActionSheet* sheet = [[PNActionSheet alloc] initWithTitle:@"Add Photo As..."
                                                         completion:^(NSInteger buttonIndex, BOOL didCancel) {

                                                             if (!didCancel) {
                                                                 NSString* permission;
                                                                 if (buttonIndex == 2)
                                                                     permission = @"public";
                                                                 else if (buttonIndex == 1)
                                                                     permission = @"friends";
                                                                 else
                                                                     permission = @"private";

                                                                 NSDictionary* params = @{@"source":@"camera", @"permission":permission};
                                                                 [Story publishVideo:nil
                                                                             orImage:snap
                                                                         withOverlay:nil
                                                                              params:params
                                                                          completion:nil];
                                                             }

                                                             [camera startPreviewWithCompletion:^(BOOL success) {
                                                                 AddStoryCollectionCell* cell = [self visibleAddStoryCell];
                                                                 cell.plusLabel.hidden = NO;
                                                             }];
                                                         }
                                                  cancelButtonTitle:@"Discard"
                                             destructiveButtonTitle:nil
                                                   otherButtonArray:@[@"Private", @"Friends", @"Public"]];
        [sheet showInView:self.view];

    }];
}

- (void)onAddPressed:(UILongPressGestureRecognizer*)gesture {
    static NSDate* pressedAt;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        pressedAt = [NSDate date];
        [[[self visibleAddStoryCell] camcorder] resumeRecording];
    }

    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSTimeInterval duration = -1*[pressedAt timeIntervalSinceNow];
        [[[self visibleAddStoryCell] camcorder] stopRecording];
    }
}

#pragma mark camera delegate mathods

- (void)camera:(id)recorder didRecord:(NSURL*)videoUrl
{
    PNCamera* camera = (PNCamera*)recorder;
    camera.player.muted = YES;
    camera.player.backgroundColor = COLOR(darkGrayColor);
    camera.player.screenshot = camera.snapshot;
    [camera startVideoPlayback];
    [camera stopPreview];

    AddStoryCollectionCell* cell = [self visibleAddStoryCell];
    cell.plusLabel.hidden = YES;

    PNActionSheet* sheet = [[PNActionSheet alloc] initWithTitle:@"Add Video As..."
                                                     completion:^(NSInteger buttonIndex, BOOL didCancel) {

                                                         if (!didCancel) {
                                                             NSString* permission;
                                                             if (buttonIndex == 2)
                                                                 permission = @"public";
                                                             else if (buttonIndex == 1)
                                                                 permission = @"friends";
                                                             else
                                                                 permission = @"private";

                                                             NSDictionary* params = @{@"source":@"camera", @"permission":permission};
                                                             [Story publishVideo:videoUrl
                                                                         orImage:nil
                                                                     withOverlay:nil
                                                                          params:params
                                                                      completion:nil];
                                                         }

                                                         [camera startPreviewWithCompletion:^(BOOL success) {
                                                             AddStoryCollectionCell* cell = [self visibleAddStoryCell];
                                                             cell.plusLabel.hidden = NO;
                                                         }];
                                                     }
                                              cancelButtonTitle:@"Discard"
                                         destructiveButtonTitle:nil
                                               otherButtonArray:@[@"Private", @"Friends", @"Public"]];
    [sheet showInView:self.view];
}

- (void)cameraDidFailToRecord:(id)recorder {
}

- (void)cameraidShutoff:(id)recorder {
}

// --

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
