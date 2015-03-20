//
//  SnapCollectionViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 9/23/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "InboxViewController.h"
#include <libkern/OSAtomic.h>

#import "Group.h"
#import "User.h"
#import "SkyMessage.h"
#import "Api.h"
#import "App.h"
#import "PNUserPreferences.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "MessageCollectionCell.h"
#import "AppDelegate.h"
#import "GroupViewController.h"

#import "AlertView.h"
#import "StatusView.h"
#import "GroupManager.h"

#import "CalloutBubble.h"
#import "PillLabel.h"

#import "AppViewController.h"
#import "SnapCollectionLayout.h"
#import "GroupManager.h"

#import "InboundMessagesController.h"
#import "HorizontalSnapsCollectionLayout.h"

@interface InboxCollectionLayout : SnapCollectionLayout
@end

@implementation InboxCollectionLayout
- (CGFloat)targetWidth {
    return 300.0;
}

- (CGFloat)aspectRatio {
    return 0.25;
}
@end

@interface InboxViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,
UINavigationControllerDelegate, InboundMessagesDelegate, MessageCollectionCellDelegate>

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) InboundMessagesController* inboundController;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, assign) BOOL needsReload;

@end

@implementation InboxViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.collection.collectionViewLayout = [InboxCollectionLayout new];
    [self.collection registerClass:[MessageCollectionCell class] forCellWithReuseIdentifier:@"snap"];

}

-(void)viewDidLayoutSubviews {

    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;

    self.collection.contentInset = UIEdgeInsetsMake(4,0,0,0);
    self.collection.frame = CGRectMakeCorners(0, 0, width, height);
    self.billboard.frame = CGRectMakeCorners(0, 0, width, height);
    self.billboard.frame = CGRectInset(self.billboard.frame, 8, 0);

    self.circleProgress.center = self.billboard.center;
}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsController];

    UIColor* navColor = COLOR(purpleColor);
    //    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-biglogo"]]];
    self.navigationItem.title = @"INBOX";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Inbox" style:UIBarButtonItemStylePlain target:nil action:nil];

    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                        NSForegroundColorAttributeName:COLOR(whiteColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(whiteColor)];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isViewVisible]) {
        [self featureVideos];
        [Logger log:@"messages.view" withObjectsAndKeys:@(self.fetchedResultsController.fetchedObjects.count), @"count",
         @([[self visibleVideoCells] count]), @"visible_videos", nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unfeatureVideos];
}

-(void) initFetchedResultsController {

    if (self.fetchedResultsController)
        return;

    NSManagedObjectContext* context = [App managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];

    request.predicate = [NSPredicate predicateWithFormat:@"ANY members.id == %@ AND id != NULL AND isHidden == NO AND last_received_message_at != NULL AND last_user_message != NULL AND (deleted_at == NULL OR deleted_at < last_received_message_at)", [App userId]];

    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"last_received_message_at" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];

    request.fetchLimit = 500;

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

    [self.fetchedResultsController performFetch:nil];
    self.fetchedResultsController.delegate = self;
    [self updateEmptyView];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.collection reloadData];

    self.inboundController = [InboundMessagesController new];
    self.inboundController.delegate = self;
}

- (void)setInboundController:(InboundMessagesController *)inboundController
{
    [self.KVOController unobserve:_inboundController];
    _inboundController = inboundController;
    [self.KVOController observe:_inboundController
                        keyPath:@"numberOfResults"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self.collection reloadData];
                          }];
}

- (void)disconnectData
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.collection.delegate = nil;
    self.collection.dataSource = nil;
    [self.collection reloadData];
}

- (void)reconnectData {
    [super reconnectData];
    [self initFetchedResultsController];
}

#pragma mark NSCollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Group* group = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    MessageCollectionCell* cell = (MessageCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"snap" forIndexPath:indexPath];
    cell.delegate = self;
    cell.group = group;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    MessageCollectionCell* storyCell = (MessageCollectionCell*)cell;
    storyCell.card.audioEnabled = NO;
    [storyCell.card didAppear];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {

    MessageCollectionCell* storyCell = (MessageCollectionCell*)cell;
    [storyCell endEditing:YES];
    [storyCell willResignFeatured];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    Group* group = (Group*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
//    [[AppViewController sharedAppViewController] openGroup:group];
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
         viewForSupplementaryElementOfKind:(NSString *)kind
                               atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView* view = [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"blank"
                                                                                forIndexPath:indexPath];
    self.inboundController.view.frame = view.bounds;
    [view addSubview:self.inboundController.view];
    view.clipsToBounds = YES;
    return view;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.inboundController.numberOfResults)
        return CGSizeMake(self.view.bounds.size.width, 120);
    else
        return CGSizeZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark InboundMessagesDelegate methods

- (void)inboundMessagesDidOpenGroup:(Group*)group {
    [[AppViewController sharedAppViewController] openGroup:group];
}

- (void)inboundMessagesDidClearGroup:(Group*)group {
}

#pragma mark MessageCollectionCellDelegate methods

- (void)messageCell:(MessageCollectionCell*)cell didOpen:(Group*)group
{
    [[AppViewController sharedAppViewController] openGroup:group];
}

- (void)messageCell:(MessageCollectionCell*)cell didClear:(Group*)group
{
    NSLog(@"CLEAR???");
}

#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
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

// Convenience method
- (int) numberOfFetchResults {
    return [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}

- (void)updateEmptyView {

    if ([self numberOfFetchResults] == 0) {

        if ([[GroupManager manager] isLoading]) {
            self.billboard.text = @"loading messages";
            self.circleProgress.hidden = NO;
            [self.circleProgress startSpinProgressBackgroundLayer];
        }
        else {
            NSString* emptyLabelString = [Configuration stringFor:@"empty_snaps_notice"] ?: [NSString stringWithFormat:@"no messages"];
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

- (void)scrollToBeginning {
    if (self.fetchedResultsController.fetchedObjects.count) {
        NSIndexPath* topPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collection scrollToItemAtIndexPath:topPath
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    on_main(^{
        [self updateEmptyView];
    });
}

- (void)reset {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [self.collection reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    self.collection.showsPullToRefresh = NO;
}

@end
