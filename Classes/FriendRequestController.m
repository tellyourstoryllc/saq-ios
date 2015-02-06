//
//  FriendRequestController.m
//  NoMe
//
//  Created by Jim Young on 12/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "FriendRequestController.h"
#import "App.h"
#import "PersonCollectionCell.h"
#import "HorizontalSnapsCollectionLayout.h"

@interface FriendRequestController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) NSInteger numberOfResults;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@end

@implementation FriendRequestController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self initFetchedResultsController];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    HorizontalSnapsCollectionLayout* layout = [HorizontalSnapsCollectionLayout new];
    self.collection.collectionViewLayout = layout;
    [self.collection registerClass:[PersonCollectionCell class] forCellWithReuseIdentifier:@"person"];
    [self.collection reloadData];
}

- (void)initFetchedResultsController {

    if (self.resultsController) return;

    NSManagedObjectContext* moc = [App moc];
    NSFetchRequest *request;

    request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND id != %@ AND is_incoming_friend = YES AND !(is_outgoing_friend = YES) AND !(is_incoming_ignored = YES)", [App userId]];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO]
                                ];

    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:moc
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    [self.resultsController performFetch:nil];
    [self updateNumberOfResults];
    self.resultsController.delegate = self;
}

- (void)updateNumberOfResults {
    id sectionInfo = [[self.resultsController sections] objectAtIndex:0];
    NSUInteger numResults = [sectionInfo numberOfObjects];
    self.numberOfResults = numResults;
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfResults];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PersonCollectionCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"person" forIndexPath:indexPath];
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    id item = [self.resultsController objectAtIndexPath:path];
    if ([item isKindOfClass:[User class]]) {
        cell.user = item;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate friendRequestShouldView:[self.resultsController objectAtIndexPath:indexPath]];
}

#pragma mark NSFetchedResultsControllerDelegate

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

    [self updateNumberOfResults];

    NSLog(@"controllerDidChangeContentcontrollerDidChangeContent: %@", self.collection);
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
    }];
}

@end
