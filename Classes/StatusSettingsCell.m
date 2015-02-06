//
//  StatusSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "StatusSettingsCell.h"
#import "User.h"
#import "Api.h"

#define kStatusButtonWidth 80
#define kStatusButtonCornerRadius 5

@interface StatusSettingsCell()

@property (nonatomic, strong) PNButton* greenButton;
@property (nonatomic, strong) PNButton* yellowButton;
@property (nonatomic, strong) PNButton* redButton;

@end

@implementation StatusSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.greenButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,kStatusButtonWidth,40)];
        self.greenButton.cornerRadius = kStatusButtonCornerRadius;
        self.greenButton.selectedColor = COLOR(greenColor);
        self.greenButton.buttonColor = [COLOR(greenColor) colorWithAlphaComponent:0.15];
        [self.greenButton setTitle:@"Here" forState:UIControlStateNormal];
        [self.greenButton addTarget:self action:@selector(selectedGreen) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.greenButton];

        self.yellowButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,kStatusButtonWidth,40)];
        self.yellowButton.cornerRadius = kStatusButtonCornerRadius;
        self.yellowButton.selectedColor = COLOR(yellowColor);
        self.yellowButton.buttonColor = [COLOR(yellowColor) colorWithAlphaComponent:0.15];
        [self.yellowButton setTitle:@"Away" forState:UIControlStateNormal];
        [self.yellowButton addTarget:self action:@selector(selectedYellow) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.yellowButton];

        self.redButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,kStatusButtonWidth,40)];
        self.redButton.cornerRadius = kStatusButtonCornerRadius;
        self.redButton.selectedColor = COLOR(redColor);
        self.redButton.buttonColor = [COLOR(redColor) colorWithAlphaComponent:0.15];
        [self.redButton setTitle:@"Busy" forState:UIControlStateNormal];
        [self.redButton addTarget:self action:@selector(selectedRed) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.redButton];

    }
    return self;
}

- (void)layoutSubviews {

    User *me = [User me];
    if(!me)
        return;
    
    switch (me.status_ordinalValue) {
        case 0:
            [self selectedGreen];
            break;

        case 1:
            [self selectedYellow];
            break;

        case 2:
            [self selectedRed];
            break;

        default:
            break;
    }

    self.greenButton.frame = CGRectSetOrigin(20, 0, self.greenButton.frame);
    self.yellowButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.greenButton.frame)+20, 0, self.yellowButton.frame);
    self.redButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.yellowButton.frame)+20, 0, self.redButton.frame);
    [super layoutSubviews];
}

- (void)selectedGreen {
    self.greenButton.selected = YES;
    self.yellowButton.selected = NO;
    self.redButton.selected = NO;
    [self updateStatus:@"available"];
}

- (void)selectedYellow {
    self.greenButton.selected = NO;
    self.yellowButton.selected = YES;
    self.redButton.selected = NO;
    [self updateStatus:@"away"];
}

- (void)selectedRed {
    self.greenButton.selected = NO;
    self.yellowButton.selected = NO;
    self.redButton.selected = YES;
    [self updateStatus:@"do_not_disturb"];
}

- (void)updateStatus:(NSString*)status {
    PNLOG(@"group.update_status");
    [[Api sharedApi] postPath:@"/users/update"
                   parameters:@{@"status":status}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                     }];
}

@end
