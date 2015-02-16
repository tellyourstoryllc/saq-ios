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
#import "InboxViewController.h"
#import "GroupViewController.h"
#import "PeopleViewController.h"
#import "MeViewController.h"
#import "SettingsViewController.h"
#import "PamphletViewController.h"

@interface MainCarouselController()<UINavigationControllerDelegate>

@property (nonatomic, strong) CarouselNavigationController* peopleNavController;
@property (nonatomic, strong) CarouselNavigationController* myStoryNavController;
@property (nonatomic, strong) CarouselNavigationController* pamphletNavController;
@property (nonatomic, strong) CarouselNavigationController* inboxNavController;

@property (nonatomic, strong) CarouselTabView* tabView;

@end

@implementation MainCarouselController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.peopleController = [[PeopleViewController alloc] initWithNibName:nil bundle:nil];
        self.peopleNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.peopleController];
        self.peopleNavController.carouselController = self;
        self.peopleNavController.delegate = self;

        self.myStoryController = [[MeViewController alloc] initWithNibName:nil bundle:nil];
        self.myStoryNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.myStoryController];
        self.myStoryNavController.carouselController = self;
        self.myStoryNavController.delegate = self;

        self.pamphletController = [[PamphletViewController alloc] initWithNibName:nil bundle:nil];
        self.pamphletNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.pamphletController];
        self.pamphletNavController.carouselController = self;
        self.pamphletNavController.delegate = self;

//        self.inboxController = [[InboxViewController alloc] initWithNibName:nil bundle:nil];
//        self.inboxNavController = [[CarouselNavigationController alloc] initWithRootViewController:self.inboxController];
//        self.inboxNavController.carouselController = self;
//        self.inboxNavController.delegate = self;

        [self addChildViewController:self.myStoryNavController];
        [self addChildViewController:self.peopleNavController];
        [self addChildViewController:self.pamphletNavController];
//        [self addChildViewController:self.inboxNavController];
        [self resetUI];

        self.tabView = [CarouselTabView new];
        self.tabView.carouselController = self;
        [self.view addSubview:self.tabView];

    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tabView.frame = CGRectSetBottomLeft(0, self.view.frame.size.height, CGRectMake(0, 0, self.view.frame.size.width, 35));

    // This sets the initial carousel panel of the application:
    self.carousel.currentItemIndex = 1;
}

- (void) resetUI {
    self.carousel.currentItemIndex = 1;
    [self.peopleController reset];
        [self.inboxController reset];
}

- (void) openPeople {
    [self scrollToIndex:1 withCompletion:nil];
}

- (void) openMyStory {
    [self.carousel scrollToItemAtIndex:0 animated:YES];
}

- (void) openInbox {
    [self.carousel scrollToItemAtIndex:2 animated:YES];
}

- (void) openGroup:(Group*)group {
//    if (group && ![group isEqual:[self currentGroup]]) {
//        NSString* groupId = group.id;
//        on_main(^{
//            GroupViewController* vc = [[GroupViewController alloc] init];
//            vc.group = [Group findById:groupId inContext:[App moc]];
//
//            if (self.carousel.currentItemIndex == 2) {
//                [self.inboxController.navigationController popToRootViewControllerAnimated:NO];
//                [self.inboxController.navigationController pushViewController:vc animated:YES];
//            }
//            else {
//                [self scrollToIndex:2 withCompletion:^{
//                    [self.inboxController.navigationController popToRootViewControllerAnimated:NO];
//                    [self.inboxController.navigationController pushViewController:vc animated:YES];
//                }];
//            }
//        });
//    }
}

- (void) openSettings {
    SettingsViewController* controller = [[SettingsViewController alloc] init];
    PNNavigationController *nav = [[PNNavigationController alloc] initWithRootViewController:controller];
    [self.myStoryController.navigationController presentViewController:nav animated:YES completion:^{
        [self.carousel scrollToItemAtIndex:0 animated:YES];
    }];
}

- (Group*) currentGroup {
    for (UIViewController* vc in self.inboxController.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GroupViewController class]]) {
            return [(GroupViewController*)vc group];
        }
    }
    return nil;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [super carouselDidEndScrollingAnimation:carousel];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionVisibleItems)
        return 3.0;
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
            self.tabView.hidden = self.myStoryNavController.visibleViewController != self.myStoryController;
            break;

        case 1:
            self.tabView.hidden = self.peopleNavController.visibleViewController != self.peopleController;
            break;

        case 2:
            self.tabView.hidden = self.inboxNavController.visibleViewController != self.inboxController;
            break;

        default:
            break;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
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

@end
