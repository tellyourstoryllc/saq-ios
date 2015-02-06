//
//  PeopleViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/11/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "FriendViewController.h"
#import "Api.h"
#import "App.h"
#import "AppViewController.h"
#import "PersonCollectionCell.h"
#import "PersonStoryCollectionController.h"
#import "StoryCollectionCell.h"
#import "PillLabel.h"
#import "PNCamera.h"
#import "UIImage+Mask.h"
#import "FriendRequestController.h"
#import "SnapCollectionLayout.h"

@interface FriendViewLayout : SnapCollectionLayout
@end

@implementation FriendViewLayout

@end

@interface FriendViewController ()<NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, FriendRequestDelegate>

@property (strong, nonatomic) FriendRequestController* requestController;
@property (strong, nonatomic) NSFetchedResultsController* friendResultsController;

@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.collection.collectionViewLayout = [[FriendViewLayout alloc] init];
    [self.collection registerClass:[PersonCollectionCell class] forCellWithReuseIdentifier:@"person"];
    [self.collection registerClass:[StoryCollectionCell class] forCellWithReuseIdentifier:@"story"];
}

-(void)setupView {
    [super setupView];
    [self initFetchedResultsControllers];
    [self.collection reloadData];

    UIColor* navColor = COLOR(friendColor);
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

    self.navigationItem.title = @"FRIENDS";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

}

- (void)initFetchedResultsControllers {

    if (self.friendResultsController)
        return;

    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND id != %@ AND is_outgoing_friend = YES", [App userId]];
    request.sortDescriptors = @[
                                   [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                   ];

    self.friendResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                           managedObjectContext:[App moc]
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    [self.friendResultsController performFetch:nil];
    self.friendResultsController.delegate = self;

    self.requestController = [[FriendRequestController alloc] init];
    self.requestController.delegate = self;
}

- (void)setRequestController:(FriendRequestController *)requestController {
    [self.KVOController unobserve:_requestController];
    _requestController = requestController;
    [self.KVOController observe:_requestController
                        keyPath:@"numberOfResults"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self.collection reloadData];
                          }];
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self.friendResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Section 0 header: friend requests
    // Section 0 items: friends added
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    id item = [self.friendResultsController objectAtIndexPath:path];
    if ([item isKindOfClass:[User class]]) {
        User* user = (User*)item;
        if (user.last_story) {
            StoryCollectionCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"story" forIndexPath:indexPath];
            cell.story = user.last_story;
            return cell;
        }
        else {
            PersonCollectionCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"person" forIndexPath:indexPath];
            cell.user = item;
            return cell;
        }
    }
    return nil;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {

        UICollectionReusableView* view = [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                                                             withReuseIdentifier:@"blank"
                                                                                    forIndexPath:indexPath];
        view.backgroundColor = COLOR(lightGrayColor);
        PNInsetLabel* label = [PNInsetLabel labelWithText:@"People who added me" andFont:HEADFONT(20)];
        label.insets = UIEdgeInsetsMake(0, 4, 4, 0);
        [view addSubview:label];

        self.requestController.view.frame = CGRectSetOrigin(0, CGRectGetMaxY(label.frame), self.requestController.view.frame);
        [view addSubview:self.requestController.view];
        return view;
    }
    else if (indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionFooter]) {

        UICollectionReusableView* view = [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                                                             withReuseIdentifier:@"blank"
                                                                                    forIndexPath:indexPath];

        NSMutableAttributedString* string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"My friend id:  "
                                                                       attributes:@{NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                                                                    NSFontAttributeName:FONT(18)}]];

        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[[[User me] friend_code] lowercaseString]
                                                                       attributes:@{NSForegroundColorAttributeName:COLOR(orangeColor),
                                                                                    NSFontAttributeName:FONT_B(24)}]];

        PNInsetLabel* label = [PNInsetLabel new];
        label.insets = UIEdgeInsetsMake(8, 4, 4, 0);
        label.attributedText = string;
        [label sizeToFit];
        [view addSubview:label];

        label.userInteractionEnabled = YES;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriendCode)];
        [label addGestureRecognizer:gesture];

        // "?" button
        PNButton* button = [[PNButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
        button.cornerRadius = 15;
        button.titleLabel.font = FONT_B(24);
        [button setTitle:@"?" forState:UIControlStateNormal];
        button.buttonColor = COLOR(grayColor);
        button.frame = CGRectSetMiddleRight(view.frame.size.width-4, view.frame.size.height/2, button.frame);
        [view addSubview:button];

        UITapGestureRecognizer* gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFriendCode)];
        [button addGestureRecognizer:gesture2];

        return view;
    }

    return [self.collection dequeueReusableSupplementaryViewOfKind:kind
                                               withReuseIdentifier:@"blank"
                                                      forIndexPath:indexPath];
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.requestController.numberOfResults)
        return CGSizeMake(self.view.bounds.size.width, 140);
    else
        return CGSizeZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.view.bounds.size.width, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.friendResultsController objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[User class]]) {
        [[AppViewController sharedAppViewController] openProfileForUser:item];
    }
}

-(void)disconnectData {
    self.friendResultsController.delegate = nil;
    self.friendResultsController = nil;

    self.requestController.delegate = nil;
    self.requestController = nil;
    
    [super disconnectData];
}

-(void)reconnectData {
    [self initFetchedResultsControllers];
    [super reconnectData];
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

#pragma mark FriendRequestDelegate methods

- (void)friendRequestShouldApprove:(User*)user {

}

- (void)friendRequestShouldIgnore:(User*)user {

}

- (void)friendRequestShouldView:(User*)user {
    [[AppViewController sharedAppViewController] openProfileForUser:user];
}

//

- (void)onFriendCode {
    NSLog(@"FRIEND CODE TAPPED!");

}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
