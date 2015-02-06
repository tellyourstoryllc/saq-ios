//
//  InboundMessagesController.m
//  NoMe
//
//  Created by Jim Young on 12/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "InboundMessagesController.h"
#import "MessageCollectionCell.h"
#import "App.h"
#import "HorizontalSnapsCollectionLayout.h"

@interface InboundMessagesController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, assign) NSInteger numberOfResults;

// See: http://samwize.com/2014/07/07/implementing-nsfetchedresultscontroller-for-uicollectionview/
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@property (nonatomic, assign) BOOL needsReload;

@end

@implementation InboundMessagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self initFetchedResultsController];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    HorizontalSnapsCollectionLayout* layout = [HorizontalSnapsCollectionLayout new];
    self.collection.collectionViewLayout = layout;
    self.collection.alwaysBounceVertical = NO;
    [self.collection registerClass:[MessageCollectionCell class] forCellWithReuseIdentifier:@"snap"];
    self.collection.backgroundColor = COLOR(yellowColor);

    [self.collection reloadData];
}

- (void)initFetchedResultsController {

    if (self.fetchedResultsController) return;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];

    request.predicate = [NSPredicate predicateWithFormat:@"ANY members.id == %@ AND id != NULL AND isHidden == NO AND last_received_message_at != NULL AND last_user_message = NULL AND (deleted_at == NULL OR deleted_at < last_received_message_at)", [App userId]];

    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"last_received_message_at" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];

    request.fetchLimit = 500;

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:[App managedObjectContext]
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
    [self.fetchedResultsController performFetch:nil];
    [self updateNumberOfResults];
    self.fetchedResultsController.delegate = self;
}

- (void) updateNumberOfResults {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numResults = [sectionInfo numberOfObjects];
    self.numberOfResults = numResults;
}

#pragma mark NSCollectionView methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfResults;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Group* group = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    MessageCollectionCell* cell = (MessageCollectionCell*) [self.collection dequeueReusableCellWithReuseIdentifier:@"snap" forIndexPath:indexPath];
    cell.group = group;
    cell.card.delegate = self;
    cell.clipsToBounds = YES;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
      willDisplayCell:(UICollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath {

    MessageCollectionCell* storyCell = (MessageCollectionCell*)cell;
    storyCell.card.audioEnabled = NO;
    storyCell.card.contentMode = UIViewContentModeScaleAspectFill;
    [storyCell.card didAppear];
}

-(void)collectionView:(UICollectionView *)collectionView
 didEndDisplayingCell:(UICollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath {

    MessageCollectionCell* storyCell = (MessageCollectionCell*)cell;
    [storyCell willResignFeatured];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Group* group = (Group*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [self.delegate inboundMessagesDidOpenGroup:group];
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

    [self updateNumberOfResults];

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

@end
