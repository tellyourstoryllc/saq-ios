//
//  MainCarouselController.m
//  SnapCracklePop
//
//  Created by Jim Young on 8/2/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MainCarouselController.h"
#import "CarouselNavigationController.h"
#import "Api.h"
#import "App.h"

#import "CarouselTabView.h"
#import "PNNavigationController.h"
#import "CenterViewController.h"
#import "InboxViewController.h"
#import "GroupViewController.h"
#import "PeopleViewController.h"
#import "MyStoryViewController.h"
#import "SettingsViewController.h"
#import "FriendViewController.h"
#import "PersonStoryCollectionController.h"
#import "PersonStoryCardController.h"

#import "CETurnAnimationController.h"

@interface MainCarouselController()<UINavigationControllerDelegate>

@property (nonatomic, strong) CarouselNavigationController* inboxNavController;
@property (nonatomic, strong) CarouselNavigationController* peopleNavController;
@property (nonatomic, strong) CarouselNavigationController* myStoryNavController;
@property (nonatomic, strong) CarouselNavigationController* friendNavController;

@property (nonatomic, strong) CarouselTabView* tabView;

@end

@implementation MainCarouselController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.cameraController = [[CenterViewController alloc] initWithNibName:nil bundle:nil];
        self.cameraController.mainController = self;

        self.peopleController = [[PeopleViewController alloc] initWithNibName:nil bundle:nil];
        self.peopleNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.peopleController];
        self.peopleNavController.carouselController = self;
        self.peopleNavController.delegate = self;

        self.myStoryController = [[MyStoryViewController alloc] initWithNibName:nil bundle:nil];
        self.myStoryNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.myStoryController];
        self.myStoryNavController.carouselController = self;
        self.myStoryNavController.delegate = self;

        self.friendController = [[FriendViewController alloc] initWithNibName:nil bundle:nil];
        self.friendNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.friendController];
        self.friendNavController.carouselController = self;
        self.friendNavController.delegate = self;

        self.inboxController = [[InboxViewController alloc] initWithNibName:nil bundle:nil];
        self.inboxNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.inboxController];
        self.inboxNavController.carouselController = self;
        self.inboxNavController.delegate = self;

        [self addChildViewController:self.peopleNavController];
        [self addChildViewController:self.friendNavController];
        [self addChildViewController:self.cameraController];
        [self addChildViewController:self.myStoryNavController];
        [self addChildViewController:self.inboxNavController];
        [self resetUI];

        self.tabView = [CarouselTabView new];
        self.tabView.carouselController = self;
        [self.view addSubview:self.tabView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin) name:kLoginStateNotification object:nil];

    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tabView.frame = CGRectSetBottomLeft(0, self.view.frame.size.height, CGRectMake(0, 0, self.view.frame.size.width, 35));

    // This sets the initial carousel panel of the application:
    self.carousel.currentItemIndex = 2;
}

- (void) resetUI {
    self.carousel.currentItemIndex = 2;
    [self.inboxController reset];
    [self.peopleController reset];
    [self.friendController reset];
    [self.myStoryController reset];
}

- (void) openPeople {
    [self scrollToIndex:0 withCompletion:nil];
}

- (void) openFriends {
    [self.carousel scrollToItemAtIndex:1 animated:YES];
}

- (void) openMyStory {
    [self.carousel scrollToItemAtIndex:3 animated:YES];
}

- (void) openInbox {
    [self.carousel scrollToItemAtIndex:4 animated:YES];
}

- (void) openProfileForUser:(User*)user {
    if (user.isMe)
        [self openMyStory];
    else if (user != [self currentProfileUser]) {
        PersonStoryCollectionController* vc = [[PersonStoryCollectionController alloc] init];
        vc.user = user;
        on_main(^{
            UINavigationController* navController;
            if (user.is_incoming_friendValue || user.is_outgoing_friendValue) {
                navController = self.friendNavController;
                [self.carousel scrollToItemAtIndex:1 animated:YES];
            }
            else {
                navController = self.peopleNavController;
                [self.carousel scrollToItemAtIndex:0 animated:YES];
            }


            [navController popToRootViewControllerAnimated:YES];
            [navController pushViewController:vc animated:YES];
        });
    }
}

- (void) openNewStories {
    [self scrollToIndex:2 withCompletion:^{
        [self.peopleController scrollToBeginning];
    }];
}

- (void) openCameraForGroup:(Group*)group {
    [self openGroup:group];
    [self scrollToIndex:3 withCompletion:nil];
}

- (void) openCamera {
    [self scrollToIndex:2 withCompletion:nil];
}

- (void) closeCamera {
    [self scrollToIndex:3 withCompletion:nil];
}

- (void) openGroup:(Group*)group {
    if (group && ![group isEqual:[self currentGroup]]) {
        NSString* groupId = group.id;
        on_main(^{
            GroupViewController* vc = [[GroupViewController alloc] init];
            vc.group = [Group findById:groupId inContext:[App moc]];

            if (self.carousel.currentItemIndex == 4) {
                [self.inboxController.navigationController popToRootViewControllerAnimated:NO];
                [self.inboxController.navigationController pushViewController:vc animated:YES];
            }
            else {
                [self scrollToIndex:4 withCompletion:^{
                    [self.inboxController.navigationController popToRootViewControllerAnimated:NO];
                    [self.inboxController.navigationController pushViewController:vc animated:YES];
                }];
            }
        });
    }
}

- (void) openSettings {
    SettingsViewController* controller = [[SettingsViewController alloc] init];
    PNNavigationController *nav = [[PNNavigationController alloc] initWithRootViewController:controller];
    [self.myStoryController.navigationController presentViewController:nav animated:YES completion:^{
        [self.carousel scrollToItemAtIndex:3 animated:YES];
    }];
    PNLOG(@"open_settings");
}

- (Group*) currentGroup {
    for (UIViewController* vc in self.inboxController.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GroupViewController class]]) {
            return [(GroupViewController*)vc group];
        }
    }
    return nil;
}

- (User*) currentProfileUser {
    PersonStoryCollectionController* storyController;
    for (UIViewController* vc in self.inboxController.navigationController.viewControllers) {
        if ([vc isKindOfClass:[PersonStoryCollectionController class]]) {
            storyController = (PersonStoryCollectionController*)vc;
            if (storyController.user)
                return storyController.user;
        }
    }
    return nil;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [super carouselDidEndScrollingAnimation:carousel];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionVisibleItems)
        return 5.0;
    else if (option == iCarouselOptionSpacing)
        return 1.01;
    else if (option == iCarouselOptionOffsetMultiplier)
        return 1.5;
    else
        return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [super carouselCurrentItemIndexDidChange:carousel];
    self.tabView.currentIndex = carousel.currentItemIndex;
    [self updateTabView];
}

- (void)updateTabView {
    switch (self.tabView.currentIndex) {
        case 0:
            self.tabView.hidden = self.peopleNavController.visibleViewController != self.peopleController;
            break;

        case 1:
            self.tabView.hidden = self.friendNavController.visibleViewController != self.friendController;
            break;

        case 2:
            self.tabView.hidden = YES;
            break;

        case 3:
            self.tabView.hidden = self.myStoryNavController.visibleViewController != self.myStoryController;
            break;

        case 4:
            self.tabView.hidden = self.inboxNavController.visibleViewController != self.inboxController;
            break;

        default:
            break;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)onLogin {
//    self.myStoryController.user = [User me];
}

- (UIPanGestureRecognizer*) panGestureRecognizer {
    NSArray* gestures = self.carousel.contentView.gestureRecognizers;
    for (UIGestureRecognizer* g in gestures) {
        if ([g isKindOfClass:[UIPanGestureRecognizer class]])
            return (UIPanGestureRecognizer*)g;
    }
    return nil;
}

#pragma mark UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [self updateTabView];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[PersonStoryCardController class]] || [toVC isKindOfClass:[PersonStoryCardController class]]) {
        CETurnAnimationController* anim = [CETurnAnimationController new];
        anim.duration = 0.5;
        anim.flipDirection = CEDirectionHorizontal;
        anim.reverse = (operation == UINavigationControllerOperationPop) ? YES : NO;
        return anim;
    }
    else
        return nil;
}

@end
