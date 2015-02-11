//
//  SettingsViewController.m
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "SettingsViewController.h"
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

#import "UIView+FirstResponder.h"
#import "DAKeyboardControl.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure nav bar

    self.navigationItem.title = @"Settings";
    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"BebasNeueBold" size:26] forKey:UITextAttributeFont];
    [titleBarAttributes setValue:COLOR(whiteColor) forKey:UITextAttributeTextColor];
    [titleBarAttributes setValue:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    navBar.titleTextAttributes = titleBarAttributes;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera-close"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeSettings)];
    self.navigationItem.leftBarButtonItem.tintColor = COLOR(whiteColor);

    [navBar setBarTintColor:COLOR(darkGrayColor)];

    self.table.backgroundColor = COLOR(defaultBackgroundColor);

    PNTableCell* usernameCell = [PNTableCell centeredCellContaining:[PNLabel labelWithText:[[User me] username] andFont:USERFONT(28)]];
    usernameCell.paddingY = 20;
    [usernameCell sizeToFit];

    NSString* helloString = [NSString stringWithFormat:@"Your avatar and wallpaper are seen only by friends who are also using %@", kAppTitle];
    PNLabel* helloLabel = [PNLabel labelWithText:helloString andFont:FONT(12)];
    [helloLabel sizeToFitTextWidth:300];
    PNTableCell* helloCell = [PNTableCell centeredCellContaining:helloLabel];

    // Logout cell
    LogoutSettingsCell* logoutCell = [[LogoutSettingsCell alloc] init];
    logoutCell.controller = self;

    // Info
    InfoSettingsCell* infoCell = [[InfoSettingsCell alloc] init];
    infoCell.controller = self;

    CloseSettingsCell* doneCell = [[CloseSettingsCell alloc] init];
    [doneCell.button addTarget:self action:@selector(closeSettings) forControlEvents:UIControlEventTouchUpInside];

    // Sounds
    SoundSettingsCell* soundCell = [[SoundSettingsCell alloc] init];

    // Graphics prefs
    GraphicsSettingsCell* graphicsCell = [[GraphicsSettingsCell alloc] init];

    // Copyright
    CopyrightSettingsCell* copyrightCell = [[CopyrightSettingsCell alloc] init];

    // Finally assemble everything together
    self.cells = [@[
                    usernameCell,
                    // avatarCell,
                    // wallpaperCell,
                    // helloCell,
                    //                    bandwidthCell,
                    infoCell,
                    //                    passwordCell,
                    logoutCell,
                    soundCell,
                    graphicsCell,
                    copyrightCell,

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
    __weak SettingsViewController* weakSelf = self;
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
