//
//  DefaultNoobViewController.m
//
//
//  Created by Jim Young on 3/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "DefaultNoobViewController.h"
#import "PNKit.h"
#import "DAKeyboardControl.h"
#import "DefaultNoobPanelController.h"
#import "UIView+FirstResponder.h"
#import "BasePanel.h"

@interface DefaultNoobViewController ()<PanelViewControllerDelegate>

@property (nonatomic, strong) DefaultNoobPanelController* panelController;

@property (nonatomic, strong) UIImageView* backgroundView;

@end

@implementation DefaultNoobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panelController = [[DefaultNoobPanelController alloc] init];
        self.panelController.delegate = self;
        [self addChildViewController:self.panelController];

        self.backgroundView = [[UIImageView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(defaultBackgroundColor);
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.panelController.view];
}

- (void)viewDidLayoutSubviews {

    CGRect b = self.view.bounds;
    self.backgroundView.frame = b;

    if ([self.panelController.currentPanel containsFirstResponder]) {
        self.panelController.view.frame = CGRectSetBottomLeft(0, b.size.height-[UIApplication visibleKeyboardHeight], b);
    }
    else {
        self.panelController.view.frame = b;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.panelController.view.frame = self.view.bounds;
}

- (void) resetUI {
    [self.panelController reset];
    [self.panelController.view setNeedsLayout];
    [self.view setNeedsLayout];
}

- (void) panelViewController:(PanelViewController*)controller didDisplayPanel:(BasePanel*)panel {
    [Logger log:[[NSString stringWithFormat:@"noob.show.%@", panel.class] lowercaseString]];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
