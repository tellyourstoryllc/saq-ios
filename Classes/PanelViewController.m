//
//  PanelViewController.m
//  groups
//
//  Created by Jim Young on 11/27/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PanelViewController.h"
#import "BasePanel.h"
#import "PNKit.h"
#import "iCarousel.h"
#import "Flurry.h"

@interface PanelViewController() <UITextFieldDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>

// An array of panels (subclasses of BasePanel)
@property(strong) NSMutableArray* filteredSignupPanels;
@property(strong) UIImageView* backgroundImageView;

@property(nonatomic, copy) void (^afterCarouselScrollingBlock)();

@property(nonatomic, strong) BasePanel* previousPanel;
@property(nonatomic, strong) BasePanel* appearingPanel;

@end

@implementation PanelViewController

- (void)commonInit {

    self.panels = [[NSMutableArray alloc] init];

    // Setup carousel
    self.carousel = [[iCarousel alloc] initWithFrame:CGRectZero];
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.scrollEnabled = YES;
    self.carousel.type = iCarouselTypeLinear;
    self.currentPanelIndex = 0;

    [self.view addSubview:self.carousel];
    self.navigationController.delegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundImageView.frame = self.view.bounds;
    self.carousel.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)updatePanelsAndCarousel {
    self.filteredSignupPanels = [[self.panels filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
        BasePanel* panel = (BasePanel*)obj;
        panel.controller = self;
        if ([panel isNeeded]) {
            panel.delegate = self;
            return YES;
        } else {
            return NO;
        }
    }] mutableCopy];

    [self.carousel reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePanelsAndCarousel];
    [self.carousel scrollToItemAtIndex:self.currentPanelIndex animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didDisplayPanel:self.currentPanel];
    if ([self.delegate respondsToSelector:@selector(panelViewController:didDisplayPanel:)])
        [self.delegate panelViewController:self didDisplayPanel:self.currentPanel];
    [self.appearingPanel didAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self didHidePanel:self.currentPanel];
    if ([self.delegate respondsToSelector:@selector(panelViewController:didHidePanel:)])
        [self.delegate panelViewController:self didHidePanel:self.currentPanel];
    [self.appearingPanel didDisappear];
//    [self.currentPanel didDisappear];
//    self.appearingPanel = nil;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [self updateNavButtons];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [parent.navigationItem setLeftBarButtonItem:self.navigationItem.leftBarButtonItem];
    [parent.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem];
//    [[self currentPanel] didAppear];
}

- (void)updateNavButtons {

    self.navigationItem.leftBarButtonItem = [[self currentPanel] leftBarButton];
    self.navigationItem.rightBarButtonItem = [[self currentPanel] rightBarButton];

    if (self.parentViewController) {
        [self.parentViewController.navigationItem setLeftBarButtonItem:self.navigationItem.leftBarButtonItem];
        [self.parentViewController.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem];

        NSString* title = [[self currentPanel] title];
        [self.parentViewController.navigationItem setTitle:title];
    }
}

- (BasePanel*) currentPanel {
    if (self.currentPanelIndex < self.filteredSignupPanels.count)
        return (BasePanel*)[self.filteredSignupPanels objectAtIndex:self.currentPanelIndex];
    else
        return nil;
}

#pragma mark - PanelDelegate methods

- (BOOL)requestNextPanel:(BasePanel *)panel {
    panel = panel ?: self.currentPanel;
    return [self gotoPanelAfter:panel];
}

- (BOOL)requestPreviousPanel:(BasePanel *)panel {
    panel = panel ?: self.currentPanel;
    return [self gotoPanelBefore:panel];
}

- (NSDictionary*) userInfo {
    return nil;
}

#pragma mark - Actions

// Advance carousel to next panel, regardless of valid state of current panel.
- (BOOL)gotoPanelAfter:(BasePanel*)currentView {

    NSUInteger nextIndex = [self.panels indexOfObject:currentView] + 1;
    while (nextIndex < self.panels.count && ![(BasePanel*)[self.panels objectAtIndex:nextIndex] isNeeded]) nextIndex++;

    if (nextIndex < self.panels.count) {
        BasePanel* nextView = [self.panels objectAtIndex:nextIndex];

        [self updatePanelsAndCarousel];
        // Index may have changed- figure it out
        NSUInteger newIndex = [self.filteredSignupPanels indexOfObject:nextView];

        [self.carousel scrollToItemAtIndex:newIndex duration:0.5];
        self.currentPanelIndex = newIndex;
        [self updateNavButtons];

        return YES;
    } else {
        return NO;
    }
}

- (BOOL)gotoPanelBefore:(BasePanel*)currentView {

    NSInteger nextIndex = [self.panels indexOfObject:currentView] - 1;
    while (nextIndex >=0 && ![(BasePanel*)[self.panels objectAtIndex:nextIndex] isNeeded]) nextIndex--;

    if (nextIndex >= 0) {
        BasePanel* nextView = [self.panels objectAtIndex:nextIndex];

        [self updatePanelsAndCarousel];
        // Index may have changed- figure it out
        NSInteger newIndex = [self.filteredSignupPanels indexOfObject:nextView];

        [self.carousel scrollToItemAtIndex:newIndex duration:0.3];
        self.currentPanelIndex = newIndex;
        [self updateNavButtons];

        return YES;
    } else {
        return NO;
    }
}

- (void) willHidePanel:(BasePanel*)panel {}
- (void) didHidePanel:(BasePanel*)panel {}
- (void) willDisplayPanel:(BasePanel*)panel {}
- (void) didDisplayPanel:(BasePanel*)panel {}

#pragma mark iCarouselDataSource, iCarouselDelegate methods
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.filteredSignupPanels count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIView* v = [self.filteredSignupPanels objectAtIndex:index];
    v.frame = carousel.bounds;
    return v;
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    [self updatePanelsAndCarousel];
    NSLog(@"carouselWillBeginDragging");
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel {
    self.previousPanel = [self currentPanel];
}

- (void) carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    self.currentPanelIndex = carousel.currentItemIndex;

    if (self.previousPanel && self.previousPanel != self.currentPanel) {
        if (self.appearingPanel == self.previousPanel) {
            [self.previousPanel didDisappear];
        }
        [self didHidePanel:self.previousPanel];
        if ([self.delegate respondsToSelector:@selector(panelViewController:didHidePanel:)])
            [self.delegate panelViewController:self didHidePanel:self.previousPanel];
    }

    if (self.appearingPanel == self.currentPanel) {
        // do nothing
    }
    else {
        [self.currentPanel didAppear];
        self.appearingPanel = self.currentPanel;
    }

    [self didDisplayPanel:self.currentPanel];

    if ([self.delegate respondsToSelector:@selector(panelViewController:didDisplayPanel:)])
        [self.delegate panelViewController:self didDisplayPanel:self.currentPanel];
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
}

@end
