//
//  PersonStoryCardController.m
//  NoMe
//
//  Created by Jim Young on 2/3/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PersonStoryCardController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "App.h"
#import "Api.h"
#import "iCarousel.h"
#import "Story.h"

#import "SnapCardView.h"

#import "PNUserPreferences.h"
#import "AppViewController.h"
#import "StoryManager.h"
#import "StatusView.h"
#import "TutorialBubble.h"

#import "UpdateMediaEditController.h"
#import "MediaAssetManager.h"
#import "SnapInfoView.h"

@interface PersonStoryCardController () <NSFetchedResultsControllerDelegate, iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate, CardViewDelegate, SnapInfoDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iCarousel* carousel;

@property (nonatomic, strong) PNLabel* billboard;
@property (nonatomic, strong) PNButton* exitButton;

// Saved state
@property (nonatomic, assign) BOOL savedNavigationBarHidden;
@property (nonatomic, assign) BOOL isAppearing;

@property (nonatomic, readonly) Story* currentStory;
@property (nonatomic, readonly) SnapCardView* currentCard;
@property (nonatomic, strong) SnapCardView* lastCard;

@property (nonatomic, assign) BOOL isLoadingFromApi;
@property (nonatomic, assign) BOOL shouldLoadFromApi;

@property (nonatomic, assign) NSInteger initialIndex;

@property (nonatomic, strong) SnapInfoView* presentedInfo;

@end

@implementation PersonStoryCardController

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionVisibleItems)
        return 5.0;
    else if (option == iCarouselOptionOffsetMultiplier)
        return 1.5;
    else if (option == iCarouselOptionSpacing)
        return 1.01;
    else
        return value;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(darkGrayColor);

    CGRect b = self.view.bounds;

    self.billboard = [[PNLabel alloc] initWithFrame:self.view.bounds];
    self.billboard.textAlignment = NSTextAlignmentCenter;
    self.billboard.font = HEADFONT(48);
    self.billboard.textColor = COLOR(lightGrayColor);
    [self.view addSubview:self.billboard];

    self.carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];

    self.carousel.bounceDistance = 0.33;
    //    self.carousel.decelerationRate = 0.82;
    //    self.carousel.scrollSpeed = 0.8;

    self.carousel.type = iCarouselTypeLinear;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.pagingEnabled = YES;
    self.carousel.clipsToBounds = YES;
    [self.view addSubview:self.carousel];

    UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swiper.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    swiper.delegate = self;
    [self.carousel.contentView addGestureRecognizer:swiper];

    self.exitButton = [[PNButton alloc] initWithFrame:CGRectMake(2, 2, 50, 50)];
    self.exitButton.buttonColor = COLOR(whiteColor);
    self.exitButton.alpha = 0.66f;
    [self.exitButton maskWithImage:[UIImage imageNamed:@"up-chevron"] inverted:YES];
    [self.exitButton addTarget:self action:@selector(onExit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectData) name:kWillClearDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectData) name:kDidClearDataNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectData) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectDataDelayed) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.shouldLoadFromApi = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.savedNavigationBarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = YES;

    if (!self.fetchedResultsController) {
        [self initFetchedResultsController];
        [self.carousel reloadData];
        if (self.initialIndex > 0) {
            self.carousel.currentItemIndex = self.initialIndex;
            self.initialIndex = -1;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // See if view is actually visisble:
    self.isAppearing = [self isViewVisible];

    if (self.isAppearing) {

        [self updateBillboard];
        [self.currentCard didAppear];
        self.lastCard = self.currentCard;

        if (!self.user && self.carousel.currentItemIndex == 0) {
            Story* story = self.fetchedResultsController.fetchedObjects.firstObject;
            [[PNUserPreferences shared] setPreference:@"last_story_viewed" dateValue:story.created_at];
            if (!story.viewedValue) {
                [story.managedObjectContext performBlock:^{
                    story.viewedValue = YES;
                    [story save];
                }];
            }
            [[StoryManager manager] updateUnreadCount];
        }

        [self unhideControls];
    }

    if (!self.currentCard && self.currentStory){
        NSLog(@"WTFFFFFFFFFFFFFFFFFFFFFFFF reloading! %@ del:%@ source:%@", self.carousel, self.carousel.delegate, self.carousel.dataSource);
        [self.carousel reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = self.savedNavigationBarHidden;
    self.isAppearing = NO;
    [self.lastCard willResignFeatured];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.currentCard didDisappear];
}

-(void) initFetchedResultsController {
    if (self.fetchedResultsController) {
        self.fetchedResultsController.delegate = nil;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Story"];

    if (self.user)
        request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND user.id = %@", self.user.id];

    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                ];
    request.fetchLimit = 500;

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[App managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
}

- (void)updateAppearance {

    if (!self.currentCard && self.currentStory) {
        [self.carousel reloadItemAtIndex:self.carousel.currentItemIndex animated:NO];
    }

    if (self.isAppearing && self.lastCard != self.currentCard) {
        [self.lastCard didDisappear];
        [self.currentCard didAppear];
        self.lastCard = self.currentCard;
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self updateBillboard];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self insertObject:anObject atIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self deleteObject:anObject atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self moveObject:anObject fromIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [self updateObject:anObject atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(object && indexPath, @"MUST have object and indexPath to update carousel");
    [self.carousel insertItemAtIndex:indexPath.row animated:NO];
    if (indexPath.row < self.carousel.currentItemIndex)
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex+1 animated:NO];
    [self updateAppearance];
}

- (void)deleteObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(object && indexPath, @"MUST have object and indexPath to update carousel");
    [self.carousel removeItemAtIndex:indexPath.row animated:NO];
    if (indexPath.row < self.carousel.currentItemIndex)
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex-1 animated:NO];
    [self updateAppearance];
}

- (void)updateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(object && indexPath, @"MUST have object and indexPath to update carousel");
    [self updateAppearance];
}

- (void)moveObject:(id)object fromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    NSAssert(object && indexPath && newIndexPath, @"MUST have object and indexPath to update carousel");
    [self reloadIndex:indexPath.row];
    [self reloadIndex:newIndexPath.row];
}

- (void)reloadIndex:(NSInteger)index {
    [self.carousel reloadItemAtIndex:index animated:NO];
    [self updateAppearance];
}

- (void)updateBillboard {
    if (!self.fetchedResultsController.fetchedObjects.count) {
        if (!self.user) {
            self.billboard.text = @"Friends' Stories";
            self.view.backgroundColor = COLOR(darkGrayColor);
        }
        else if (self.user.isMe) {
            self.billboard.text = @"My Story";
            self.view.backgroundColor = COLOR(blackColor);
        }
        else {
            self.billboard.text = [NSString stringWithFormat:@"%@'s Story", self.user.displayName];
        }    }
    else
        self.billboard.text = nil;
}

- (NSInteger)numberOfItems {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

#pragma mark iCarousel delegate and data source methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self numberOfItems];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {

    NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
    Story* story = [self.fetchedResultsController objectAtIndexPath:path];

    SnapCardView* tv = [[SnapCardView alloc] initWithFrame:self.view.bounds];
    tv.delegate = self;
    tv.message = story;

    if (story.user.isMe) {
        tv.showEditButton = YES;
        tv.showExportButton = YES;
        tv.showReplyButton = NO;
    }
    else {
        tv.showEditButton = NO;
        tv.showExportButton = NO;
        tv.showReplyButton = YES;
    }
    tv.showInfoButton = YES;

    int preloadDistance = 3;
    if (index >= self.carousel.currentItemIndex - preloadDistance &&
        index <= self.carousel.currentItemIndex + preloadDistance) {
        [tv loadContent];
    }

    return tv;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return self.view.bounds.size.width;
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    [self setEditing:NO animated:YES];
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    NSLog(@"end dragging: %d", decelerate);
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel {
    [self hideControls];
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {

    self.presentedInfo.snap = self.currentStory;

    int preloadDistance = 3;
    for (int x = self.carousel.currentItemIndex - preloadDistance;
         x <= self.carousel.currentItemIndex + preloadDistance;
         x++) {
        SnapCardView* view = (SnapCardView*)[self.carousel itemViewAtIndex:x];
        [view loadContent];
    }

    if ([self numberOfItems] - self.carousel.currentItemIndex < preloadDistance)
        [self loadStoriesFromApi];

}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [self unhideControls];
    [self updateAppearance];
    [self.currentCard didBecomeFeatured];
}

- (SnapCardView*)currentCard {
    UIView* view = [self.carousel itemViewAtIndex:self.carousel.currentItemIndex];
    if ([view isKindOfClass:[SnapCardView class]])
        return (SnapCardView*)view;
    else
        return nil;
}

- (Story*)currentStory {
    if (self.carousel.currentItemIndex >= self.fetchedResultsController.fetchedObjects.count)
        return nil;

    if (self.carousel.currentItemIndex < 0)
        return nil;

    NSIndexPath* path = [NSIndexPath indexPathForRow:self.carousel.currentItemIndex inSection:0];
    return [self.fetchedResultsController objectAtIndexPath:path];
}

- (SnapCardView*)nextCard {
    if (self.carousel.currentItemIndex > self.carousel.numberOfItems-2)
        return nil;

    UIView* view = [self.carousel itemViewAtIndex:self.carousel.currentItemIndex+1];
    if ([view isKindOfClass:[SnapCardView class]])
        return (SnapCardView*)view;
    else
        return nil;
}

- (void)scrollToBeginning {
    if (self.carousel.currentItemIndex == 0) return;

    [self.carousel scrollToItemAtIndex:0 animated:NO];
    [self updateAppearance];
}

- (void)onExit {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSwipe:(UIGestureRecognizer*)gesture {
    [self onExit];
}

- (void)onCamera {
    [[AppViewController sharedAppViewController] openCamera];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing)
        [self dismissPresentedInfo];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self hideControls];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self unhideControls];
}

- (void)hideControls {
    [[self currentCard] hideControls];
}

- (void)unhideControls {
    [[self currentCard] unhideControls];
}

- (void) disconnectData {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
}

- (void) reconnectData {
    [self initFetchedResultsController];
}

- (void) reconnectDataDelayed {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reconnectData];
    });
}

- (void)loadStoriesFromApi {

    if (!self.shouldLoadFromApi || self.isLoadingFromApi) return;

    __weak PersonStoryCardController* weakSelf = self;

    NSString *path = [NSString stringWithFormat:@"/users/%@/stories", weakSelf.user.id];
    NSMutableDictionary *params = [ @{ @"limit" : @"40" } mutableCopy];

    NSString* lastStoryId = [[weakSelf.fetchedResultsController.fetchedObjects lastObject] id];
    if (lastStoryId)
        [params setObject:lastStoryId forKey:@"below_story_id"];

    weakSelf.isLoadingFromApi = YES;

    [[Api sharedApi] postPath:path
                   parameters:params
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         if(!error && [entities count] == 0)
                             weakSelf.shouldLoadFromApi = NO;

                         weakSelf.isLoadingFromApi = NO;
                     }];
}

- (void)scrollToIndex:(NSUInteger)index {
    if (self.carousel && self.fetchedResultsController)
        self.carousel.currentItemIndex = index;
    else
        self.initialIndex = index;
}

#pragma mark CardViewDelegate methods

- (void)card:(SnapCardView *)card didSelectExport:(SkyMessage *)snap {

    if (!snap.user.isMe)
        return;

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

    [self dismissPresentedInfo];
    UpdateMediaEditController* vc = [UpdateMediaEditController new];
    vc.snap = snap;
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
        info.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*(1.f-1.f/GOLDEN_MEAN));
        info.delegate = self;
        [self.view addSubview:info];
        self.presentedInfo = info;
    }
}

- (void)dismissPresentedInfo {
    [self.presentedInfo removeFromSuperview];
    self.presentedInfo = nil;
}

#pragma mark SnapInfoDelegate methods

- (void)snapInfo:(SnapInfoView*)infoView didDismiss:(SkyMessage*)snap {
    [infoView removeFromSuperview];
    self.presentedInfo = nil;
}

- (void)snapInfo:(SnapInfoView*)infoView didDelete:(SkyMessage*)snap {
}

- (void)snapInfo:(SnapInfoView*)infoView didUpdate:(SkyMessage*)snap toPermission:(NSString*)newPermission {}

- (void)snapInfo:(SnapInfoView*)infoView didFlag:(SkyMessage*)snap withOptions:(NSDictionary*)options {}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
