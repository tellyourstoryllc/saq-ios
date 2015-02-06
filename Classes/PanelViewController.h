//
//  PanelViewController.h
//  groups
//
//  Created by Jim Young on 11/27/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@class BasePanel;
@class PanelViewController;

@protocol PanelDelegate <NSObject>

@optional
- (BOOL) requestNextPanel:(BasePanel*)panel;
- (BOOL) requestPreviousPanel:(BasePanel*)panel;
- (NSDictionary*) userInfo;
@end

@protocol PanelViewControllerDelegate <NSObject>

@optional
- (void) panelViewController:(PanelViewController*)controller didHidePanel:(BasePanel*)panel;
- (void) panelViewController:(PanelViewController*)controller didDisplayPanel:(BasePanel*)panel;
@end

@interface PanelViewController : UIViewController <PanelDelegate, iCarouselDataSource, iCarouselDelegate>

- (BOOL)gotoPanelBefore:(BasePanel*)currentView;
- (BOOL)gotoPanelAfter:(BasePanel*)currentView;

@property (nonatomic, strong) iCarousel* carousel;

@property (nonatomic, assign) NSUInteger currentPanelIndex;
@property (nonatomic, readonly) BasePanel* currentPanel;
@property (nonatomic, strong) NSArray* panels;
@property (nonatomic, weak) id<PanelViewControllerDelegate> delegate;

// Intended to be overridden by subclasses
- (void) didHidePanel:(BasePanel*)panel;
- (void) didDisplayPanel:(BasePanel*)panel;

@end
