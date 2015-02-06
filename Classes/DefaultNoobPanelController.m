//
//  DefaultNoobPanelController.m
//
//  Created by Jim Young on 3/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "DefaultNoobPanelController.h"
#import "LinearLoginPanel.h"
#import "DefaultWelcomePanel.h"
#import "NoobCamcorderPanel.h"
#import "LinearGenderPanel.h"
#import "LinearAgeGenderPanel.h"
#import "LinearEmailPanel.h"
#import "LinearLocationPanel.h"
#import "LinearPhoneInputPanel.h"
#import "LinearCreateAccountPanel.h"

@implementation DefaultNoobPanelController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panels = @[
                        [LinearLoginPanel new],
                        [DefaultWelcomePanel new],
                        [NoobCamcorderPanel new],
                        [LinearEmailPanel new],
                        [LinearAgeGenderPanel new],
                        [LinearCreateAccountPanel new],
                        ];

        self.currentPanelIndex = 1;
        self.carousel.pagingEnabled = YES;
        self.carousel.bounces = NO;

    }
    return self;
}

- (void) didDisplayPanel:(BasePanel *)panel {
    //    self.carousel.scrollEnabled = [panel isKindOfClass:[LinearLoginPanel class]];
}

- (void) reset {
    self.currentPanelIndex = 1;
    self.email = nil;
    self.username = nil;
    self.gender = nil;
    self.birthdate = nil;
    self.phoneNumber = nil;
    
    if (self.videoFileURL) [[NSFileManager defaultManager] removeItemAtURL:self.videoFileURL error:nil];
    self.videoFileURL = nil;

    for (BasePanel* panel in self.panels) {
        [panel reset];
    }
}

@end