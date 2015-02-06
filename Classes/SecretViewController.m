//
//  SecretViewController.m
//  groups
//
//  Created by Jim Young on 12/10/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "SecretViewController.h"
#import "StatusView.h"
#import "PNUserPreferences.h"
#import "Api.h"

@interface SecretViewController ()

@end

@implementation SecretViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Cells:

        self.cells = [@[] mutableCopy];

        // use prod servers

        PNTableCell* cell = [[PNTableCell alloc] init];
        PNButton* button = [[PNButton alloc] initWithFrame:CGRectMake(0,0,200,60)];
        [button setBorderWithColor:COLOR(whiteColor) width:2];
        button.cornerRadius = 30;
        button.buttonColor = COLOR(grayColor);
        button.selectedColor = COLOR(greenColor);
        button.selected = ![[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference];
        [button setTitle:@"PROD" forState:UIControlStateNormal];
        [cell addChild:button];
        cell.centerX = YES;
        cell.paddingY = 20;
        [cell sizeToFit];
        [self.cells addObject:cell];

        PNTableCell* cell2 = [[PNTableCell alloc] init];
        PNButton* button2 = [[PNButton alloc] initWithFrame:CGRectMake(0,0,200,60)];
        [button2 setBorderWithColor:COLOR(whiteColor) width:2];
        button2.cornerRadius = 30;
        button2.buttonColor = COLOR(grayColor);
        button2.selectedColor = COLOR(greenColor);
        button2.selected = [[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference];
        [button2 setTitle:@"DEV" forState:UIControlStateNormal];
        [cell2 addChild:button2];
        cell2.centerX = YES;
        cell2.paddingY = 20;
        [cell2 sizeToFit];
        [self.cells addObject:cell2];

        __weak PNButton* weButt = button;
        __weak PNButton* weButt2 = button2;

        [button setTappedBlock:^{
            [[PNUserPreferences shared] setPreference:kDevApiServerSelectedPreference boolValue:NO];
            weButt.selected = YES;
            weButt2.selected = NO;
            [Api sharedApiForcingNewClient:YES];
            [Api fastApiForcingNewClient:YES];
            [Api slowApiForcingNewClient:YES];
        }];

        [button2 setTappedBlock:^{
            [[PNUserPreferences shared] setPreference:kDevApiServerSelectedPreference boolValue:YES];
            weButt2.selected = YES;
            weButt.selected = NO;
            [Api sharedApiForcingNewClient:YES];
            [Api fastApiForcingNewClient:YES];
            [Api slowApiForcingNewClient:YES];
        }];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;

    self.navigationItem.title = @"Hello Friend";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera-close"] style:UIBarButtonItemStylePlain target:self action:@selector(hamburgerPressed)];
    self.navigationItem.leftBarButtonItem.tintColor = COLOR(blackColor);

    [navBar setBarTintColor:COLOR(orangeColor)];
    self.table.backgroundColor = COLOR(blueColor);
}

- (void) hamburgerPressed {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
