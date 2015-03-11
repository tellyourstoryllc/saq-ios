//
//  NoobBasePanel.h
//  groups
//
//  Created by Jim Young on 11/27/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAKeyboardControl.h"
#import "PNView.h"
#import "PanelViewController.h"

@interface BasePanel : PNView

@property (nonatomic, retain) IBOutlet UIView* bundledView;
@property (nonatomic, assign) PanelViewController* controller;
@property (nonatomic, weak) id <PanelDelegate> delegate;

@property (nonatomic, strong) UIBarButtonItem* leftBarButton;
@property (nonatomic, strong) UIBarButtonItem* rightBarButton;

@property (nonatomic, readonly) BOOL appeared;

// Should the panel controller present this panel to the user? (Default: YES)
- (BOOL) isNeeded;

- (void) didAppear;
- (void) didFirstAppear;
- (void) didDisappear;
- (BOOL) canGotoNextPanel;
- (BOOL) canGotoPreviousPanel;
- (BOOL) gotoNextPanel;
- (BOOL) gotoPreviousPanel;

- (NSString*) title;

- (void) reset;

- (void) keyboardDidBecomeVisible:(BOOL)visible viewFrame:(CGRect)viewFrame keyboardFrame:(CGRect)keyboardFrame;

@end
