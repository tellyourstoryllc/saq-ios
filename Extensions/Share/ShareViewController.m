//
//  ShareViewController.m
//  Share
//
//  Created by Jim Young on 12/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ShareViewController.h"

@interface PermissionConfiguration : SLComposeSheetConfigurationItem
@end

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Please login to KnowMe"
                                                                   message:@"Unable to post because you are not currently logged in."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [self cancel];
                                            }]
     ];

    [self presentViewController:alert animated:YES completion:nil];

}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    NSLog(@"SHAAAARING %@ %@", self.contentText, self.extensionContext.inputItems);

    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[
             [PermissionConfiguration new]
             ];
}

@end

@implementation PermissionConfiguration
- (id)init {
    self = [super init];
    self.title = @"Privacy";

    return self;
}
@end
