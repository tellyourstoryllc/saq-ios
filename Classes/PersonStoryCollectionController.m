//
//  PersonStoryViewController.m
//  NoMe
//
//  Created by Jim Young on 12/27/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PersonStoryCollectionController.h"
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
#import "MediaAssetManager.h"

#import "AddStoryCollectionCell.h"
#import "SnapInfoView.h"

#import "PersonProfileViewController.h"
#import "PersonStoryCardController.h"
#import "UpdateMediaEditController.h"
#import "GroupViewController.h"

@interface PersonStoryCollectionController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,
UINavigationControllerDelegate, CardViewDelegate, PNCameraDelegate, SnapInfoDelegate, PersonProfileDelegate> {

}

@property (nonatomic, strong) User* me;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PersonProfileViewController* profileController;

@property (nonatomic, strong) SnapCardView* presentedCard;
@property (nonatomic, strong) SnapInfoView* presentedInfo;

@property (nonatomic, assign) BOOL needsReload;
@property (nonatomic, assign) BOOL completedAPIFetch;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, strong) UIImage* snapshot;

@end

@implementation PersonStoryCollectionController

-(void)viewDidLoad {
    [super viewDidLoad];

    CGRect bounds = self.view.bounds;
    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
    self.collection.backgroundColor = [UIColor clearColor];
    self.collection.canCancelContentTouches = YES;
    self.collection.alwaysBounceVertical = YES;

    UISwipeGestureRecognizer* swipey = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe)];
    swipey.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipey];

    [self.KVOController observe:[StoryManager manager]
                        keyPath:@"isLoading"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              on_main(^{
                                  [self updateEmptyView];
                              });
                          }];

    __weak PersonStoryCollectionController* weakSelf = self;
    [self.collection addInfiniteScrollingWithActionHandler:^{

        NSString *path = [NSString stringWithFormat:@"/users/%@/stories", weakSelf.user.id];
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

-(void)didSwipe {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsController];

    if (_user) {
        self.navigationItem.title = _user.username ?: @"KNOW.ME";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_user.username ?: @"Profile")
                                                                                 style:UIBarButtonItemStylePlain target:nil action:nil];

        UIColor* navColor = _user.is_outgoing_friendValue ? COLOR(friendColor) : COLOR(publicColor);

        UINavigationBar* navBar = self.navigationController.navigationBar;
        [navBar setBarTintColor:navColor];
        [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                     forBarMetrics:UIBarMetricsDefault];

        NSShadow* shadow = [NSShadow new];
        [shadow setShadowColor:nil];
        NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                            NSForegroundColorAttributeName:COLOR(blackColor),
                                            NSShadowAttributeName:shadow};
        [navBar setTitleTextAttributes:barTextAttributes];
        navBar.shadowImage = [UIImage new];
    }
}

- (void)setUser:(User *)user {
    if (user == _user) return;

    _user = user;
    [self setupView];

    self.fetchedResultsController = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
    [self.navigationController setNavigationBarHidden:(self.presentedCard != nil)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isViewVisible]) {
        [self featureVideos];

        if (!_completedAPIFetch && [App userId]) {
            NSString *path = [NSString stringWithFormat:@"/users/%@/stories", self.user.id];
            NSMutableDictionary *params = [ @{ @"limit" : @"40" } mutableCopy];
            [[Api sharedApi] postPath:path
                           parameters:params
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 if (!error)
                                     _completedAPIFetch = YES;
                             }];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unfeatureVideos];
}

-(void) initFetchedResultsController {

    if (self.fetchedResultsController || !self.user)
        return;

    NSManagedObjectContext* context = [App managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Story"];
    request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND user.id = %@", self.user.id];
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

    PersonProfileViewController* vc = [PersonProfileViewController new];
    vc.user = self.user;
    vc.delegate = self;
    self.profileController = vc;
}

- (void) disconnectData {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.collection.delegate = nil;
    self.collection.dataSource = nil;
    [self.collection reloadData];
}

- (void) reconnectData {
    [super reconnectData];
    [self initFetchedResultsController];
}

#pragma mark NSCollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Story* story = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    StoryCollectionCell* cell = (StoryCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
    cell.card.delegate = self;
    cell.controller = self;
    cell.story = story;
    cell.clipsToBounds = YES;
    return cell;
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
    return CGSizeMake(self.view.bounds.size.width, 60);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
    storyCell.card.audioEnabled = NO;
    storyCell.card.contentMode = UIViewContentModeScaleAspectFill;
    [storyCell.card didAppear];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    StoryCollectionCell* storyCell = (StoryCollectionCell*)cell;
    [storyCell willResignFeatured];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    Story* story = (Story*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];

    if (story.hasVideo || story.hasImage) {
        PersonStoryCardController* vc = [PersonStoryCardController new];
        vc.user = self.user;
        [vc scrollToIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
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
    NSIndexPath *collectionIndexPath = indexPath;
    NSIndexPath *newCollectionIndexPath = newIndexPath;

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

- (void)dismissPresentedCard {
    if (!self.presentedCard) return;

    [self dismissPresentedInfo];
    [self.navigationController setNavigationBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];

    [self.presentedCard removeFromSuperview];
    [self.presentedCard didDisappear];
    self.presentedCard = nil;
    [self featureVideos];
}

- (void)dismissPresentedInfo {
    [self.presentedInfo removeFromSuperview];
    self.presentedInfo = nil;
}

#pragma mark CardViewDelegate methods

- (void)card:(SnapCardView *)card didSelectDismiss:(SkyMessage *)snap {
    [self dismissPresentedInfo];
    [self.navigationController setNavigationBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];

    [card removeFromSuperview];
    [card didDisappear];
    self.presentedCard = nil;
    [self featureVideos];
}

- (void)card:(SnapCardView *)card didSelectExport:(SkyMessage *)snap {

    void (^saveErrorBlock)() = ^() {
        [StatusView showTitle:@"Unable to save to Camera Roll"
                      message:[NSString stringWithFormat:@"You must go to device Settings > Privacy > Photos > Turn on %@.", kAppTitle]
                   completion:nil
                     duration:5];
        [Logger log:@"story.video.save.fail.noauth"];
    };

    PNActionSheet* sheet = [[PNActionSheet alloc]
                            initWithTitle:nil
                            completion:^(NSInteger buttonIndex, BOOL didCancel) {

                                if (buttonIndex == 0) {
                                    [snap fetchCompositeMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl) {
                                        if (photo) {
                                            [[MediaAssetManager manager]
                                             saveImage:photo
                                             withCompletion:^(NSURL *assetURL, NSError *error) {
                                                 if (error) {
                                                     saveErrorBlock();
                                                     [Logger log:@"story.photo.save.fail"];
                                                 }
                                                 else {
                                                     [StatusView showTitle:@"Saved to Camera Roll" message:nil completion:nil duration:2.0];
                                                     [Logger log:@"story.photo.save.success"];
                                                 }
                                             }];
                                        }

                                        else if (videoUrl) {
                                            [[MediaAssetManager manager]
                                             saveVideo:videoUrl
                                             withCompletion:^(NSURL *assetURL, NSError *error) {
                                                 if (error) {
                                                     saveErrorBlock();
                                                     [Logger log:@"story.video.save.fail"];
                                                 }
                                                 else {
                                                     [StatusView showTitle:@"Saved to Camera Roll" message:nil completion:nil duration:2.0];
                                                     [Logger log:@"story.video.save.success"];
                                                 }
                                             }];
                                        }
                                        else {

                                        }
                                    }];
                                }
                            }
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonArray:@[@"Save to Camera Roll"]];

    [self dismissPresentedInfo];
    [sheet showInView:self.view];
}

- (void)card:(SnapCardView *)card didSelectEdit:(SkyMessage *)snap {
    [card removeFromSuperview];
    [card didDisappear];
    self.presentedCard = nil;
    [self dismissPresentedInfo];

    UpdateMediaEditController* vc = [UpdateMediaEditController new];
    vc.snap = snap;
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)card:(SnapCardView*)card didSelectInfo:(SkyMessage*)snap {

    if (self.presentedInfo) {
        [self dismissPresentedInfo];
    }
    else {
        SnapInfoView* info = [SnapInfoView new];
        info.snap = snap;
        info.frame = CGRectMake(0, 0, 300, 200);
        info.delegate = self;
        [card addSubview:info];
        self.presentedInfo = info;
    }
}

#pragma mark SnapInfoDelegate methods

- (void)snapInfo:(SnapInfoView*)infoView didDismiss:(SkyMessage*)snap {
    [infoView removeFromSuperview];
    self.presentedInfo = nil;
}

- (void)snapInfo:(SnapInfoView*)infoView didDelete:(SkyMessage*)snap {
    [self dismissPresentedCard];
}

- (void)snapInfo:(SnapInfoView*)infoView didUpdate:(SkyMessage*)snap toPermission:(NSString*)newPermission {}

- (void)snapInfo:(SnapInfoView*)infoView didFlag:(SkyMessage*)snap withOptions:(NSDictionary*)options {}

#pragma mark PersonProfileDelegate method

- (void)profileDidSelectMessage:(User*)user {
    GroupViewController* vc = [GroupViewController new];
    vc.group = user.oneToOneGroup;
    [self.navigationController pushViewController:vc animated:YES];
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
