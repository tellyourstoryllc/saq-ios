//
//  PreferencesViewController.m
//  groups
//
//  Created by Jim Young on 1/21/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AppViewController.h"
#import "App.h"
#import "User.h"
#import "SkyAccount.h"
#import "AlertView.h"
#import "UIImageView+AFNetworking.h"

#import "StatusSettingsCell.h"
#import "StatusTextSettingsCell.h"
#import "NotificationSettingsCell.h"
#import "SoundSettingsCell.h"
#import "GraphicsSettingsCell.h"
#import "LogoutSettingsCell.h"
#import "InfoSettingsCell.h"
#import "CopyrightSettingsCell.h"
#import "CloseSettingsCell.h"
#import "PasswordSettingsCell.h"
#import "BandwidthSettingsCell.h"

#import "UIView+FirstResponder.h"
#import "DAKeyboardControl.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure nav bar

    self.navigationItem.title = @"Preferences";
    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"BebasNeueBold" size:26] forKey:UITextAttributeFont];
    [titleBarAttributes setValue:COLOR(navTitleColor) forKey:UITextAttributeTextColor];
    [titleBarAttributes setValue:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    navBar.titleTextAttributes = titleBarAttributes;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(closeSettings)];
    self.navigationItem.leftBarButtonItem.tintColor = COLOR(blackColor);

    [navBar setBarTintColor:COLOR(defaultNavigationColor)];
    self.table.backgroundColor = COLOR(whiteColor);
    self.table.contentInset = UIEdgeInsetsMake(8,0,0,0);

    // Status
    StatusSettingsCell* statusCell = [[StatusSettingsCell alloc] init];
    StatusTextSettingsCell* statusTextCell = [[StatusTextSettingsCell alloc] init];

    // Notification prefs
    NotificationSettingsCell* notificationsCell = [[NotificationSettingsCell alloc] init];

    // Sounds
    SoundSettingsCell* soundCell = [[SoundSettingsCell alloc] init];

    // Graphics prefs
    GraphicsSettingsCell* graphicsCell = [[GraphicsSettingsCell alloc] init];

    // Bandwidth prefs
    BandwidthSettingsCell* bandwidthCell = [[BandwidthSettingsCell alloc] init];

    // Password cell
    PasswordSettingsCell* passwordCell = [[PasswordSettingsCell alloc] init];
    passwordCell.controller = self;

    // Logout cell
    LogoutSettingsCell* logoutCell = [[LogoutSettingsCell alloc] init];
    logoutCell.controller = self;

    // Info
    InfoSettingsCell* infoCell = [[InfoSettingsCell alloc] init];
    infoCell.controller = self;

    CloseSettingsCell* doneCell = [[CloseSettingsCell alloc] init];
    [doneCell.button addTarget:self action:@selector(closeSettings) forControlEvents:UIControlEventTouchUpInside];

    // Copyright
    CopyrightSettingsCell* copyrightCell = [[CopyrightSettingsCell alloc] init];

    // Finally assemble everything together
    self.cells = [@[
//                    notificationsCell,
                    soundCell,
                    graphicsCell,
//                    bandwidthCell,
                    infoCell,
//                    passwordCell,
                    logoutCell,
//                    doneCell,
                    copyrightCell
                    ] mutableCopy];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)closeSettings {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cells.count > indexPath.row)
        return [self.cells objectAtIndex:indexPath.row];
    else
        return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak PreferencesViewController* weakSelf = self;
    [self.view addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        CGRect vizFrame = CGRectIntersection(keyboardFrameInView, weakSelf.view.bounds);
        CGRect slice;
        CGRect remainder;
        CGRectDivide(weakSelf.view.bounds, &slice, &remainder, vizFrame.size.height, CGRectMaxYEdge);
        weakSelf.table.frame = remainder;
    }];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeKeyboardControl];
}

@end

