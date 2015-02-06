//
//  PhoneCountryCodeViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 11/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PhoneCountryCodeViewController.h"

@interface CountryCodeCell : UITableViewCell
@property (nonatomic, strong) NSString* countryName;
@property (nonatomic, strong) NSString* code;
@property (nonatomic, assign) BOOL selected;

- (id) initWithName:(NSString*)name code:(NSString*)code;

@end

@interface PhoneCountryCodeViewController () 

@end

@implementation PhoneCountryCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.cells = [NSMutableArray new];

    CountryCodeCell* cell = [[CountryCodeCell alloc] initWithName:@"test" code:@"1"];
    cell.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    [self.cells addObject:cell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didSelectCell:(UITableViewCell*)cell {
    self.selectedCode = @"hey";

    if (self.parentViewController) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

@implementation CountryCodeCell

- (id) initWithName:(NSString*)name code:(NSString*)code {
    self = [super init];
    self.textLabel.text = name;
    return self;
}

@end