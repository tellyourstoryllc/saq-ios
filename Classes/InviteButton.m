//
//  InviteButton.m
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "InviteButton.h"

#import "User.h"
#import "Api.h"
#import "App.h"
#import "AlertView.h"
#import "StatusView.h"
#import "AppViewController.h"
#import "PNUserContacts.h"
#import "PNMailComposeViewController.h"
#import "PNMessageComposeViewController.h"

@implementation InviteButton

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(wasTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSArray*) inviteMethodPreferredOrder {
    return @[@(InviteMethodTextMessage),
             @(InviteMethodEmail),
             @(InviteMethodFacebook),
             @(InviteMethodTwitter),
             @(InviteMethodClipboard)];
}

- (NSArray*) availableInviteMethods {
    NSMutableArray* results = [@[@(InviteMethodClipboard)] mutableCopy];

    if ([MFMailComposeViewController canSendMail]) [results addObject:@(InviteMethodEmail)];
    if ([MFMessageComposeViewController canSendText]) [results addObject:@(InviteMethodTextMessage)];
//    if ([[User me] facebook_id]) [results addObject:@(InviteMethodFacebook)];

    return results;
}

- (NSString*) buttonLabelForInviteMethod:(InviteMethodType)inviteMethod {
    switch (inviteMethod) {
        case InviteMethodNone:
            return @"Cancel";
            break;

        case InviteMethodClipboard:
            return @"Copy link to clipboard";
            break;

        case InviteMethodTextMessage:
            return @"Text message";
            break;

        case InviteMethodEmail:
            return @"Send link via email";
            break;

        case InviteMethodFacebook:
            return @"Post to Facebook";
            break;

        case InviteMethodTwitter:
            return @"Post to Twitter";
            break;

        default:
            return nil;
            break;
    }
}

- (void) performActionForInviteMethod:(InviteMethodType)inviteMethod {
    switch (inviteMethod) {
        case InviteMethodNone:
            if (self.callback) self.callback(inviteMethod, NO);
            break;

        case InviteMethodClipboard:
            [self inviteByClipboard];
            break;

        case InviteMethodTextMessage:
            [self inviteBySMS];
            break;

        case InviteMethodEmail:
            [self inviteByEmail];
            break;

        case InviteMethodFacebook:
            //
            break;

        case InviteMethodTwitter:
            //
            break;

        default:
            break;
    }
}

- (void) wasTapped {

    NSParameterAssert(self.presentingController);
    NSParameterAssert(self.group);

    PNLOG(@"invite.button_tapped");

    NSArray* availableMethods = [self availableInviteMethods];
    NSArray* methodArray = [[self inviteMethodPreferredOrder] filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
        return [availableMethods containsObject:obj];
    }];

    NSArray* labelArray = [methodArray mapUsingBlock:^id(id obj) {
        return [self buttonLabelForInviteMethod:[obj intValue]];
    }];

    NSString* formatString = [Configuration stringFor:@"share_sheet_title"] ?: @"This group can be joined using the key: %@";
    [[[PNActionSheet alloc] initWithTitle:[NSString stringWithFormat:formatString, self.group.join_code.uppercaseString]
                               completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                   if (didCancel) {
                                       [self performActionForInviteMethod:InviteMethodNone];
                                   }
                                   else {
                                       [self performActionForInviteMethod:[[methodArray objectAtIndex:buttonIndex] intValue]];
                                   }
                               }
                        cancelButtonTitle:[self buttonLabelForInviteMethod:InviteMethodNone]
                   destructiveButtonTitle:nil
                         otherButtonArray:labelArray
      ] showInView:self.presentingController.view];
}

- (void)inviteByEmail {

    void (^potato)() = ^{

        PNMailComposeViewController* mailController = [[PNMailComposeViewController alloc] init];

        NSString* titleFormatString = [Configuration stringFor:@"share_email_title"] ?: @"Join our group";
        [mailController setSubject:[NSString stringWithFormat:titleFormatString, self.group.name]];

        NSString* bodyFormatString = [Configuration stringFor:@"share_email_body"] ?: @"Join our group chat: <br>%@<p>";
        NSString* body = [NSString stringWithFormat:bodyFormatString, self.group.join_url, self.group.join_code.uppercaseString];

        // Add avatar inline?
        //UIImage* screenshot = self.group.avatar;
        //if (screenshot) {
        //    NSData* imgData = [NSData dataWithData:UIImageJPEGRepresentation([[screenshot reorientedImage]
        //                                                                      imageByScalingProportionallyToSize:CGSizeMake(150, 150)], 0.7)];
        //    [mailController addAttachmentData:imgData mimeType:@"image/jpeg" fileName:@"skymob.jpg"];
        //}

        [mailController setMessageBody:body isHTML:YES];
        [mailController setCompletion:^(MFMailComposeResult result, NSError* error) {
            if (result == MessageComposeResultSent) {
                PNLOG(@"invite.email.sent");
                if (self.callback) self.callback(InviteMethodEmail, YES);
            }
            else {
                PNLOG(@"invite.email.unsent");
                if (self.callback) self.callback(InviteMethodEmail, NO);
            }
        }];

        [self.presentingController presentViewController:mailController animated:YES completion:^{
            PNLOG(@"invite.email.show");
        }];
    };

    [PNUserContacts requestContactsWithCompletion:^(BOOL granted, NSArray *contacts) {
        if (granted)
            PNLOG(@"invite.email.request_contact.granted");
        else
            PNLOG(@"invite.email.request_contact.denied");

        potato();
    }];
}

- (void)inviteByClipboard {
    NSString* clipboardFormat = [Configuration stringFor:@"share_clipboard_body"] ?: @"%@";
    NSString* clipboardString = [NSString stringWithFormat:clipboardFormat, self.group.join_url];
    [[UIPasteboard generalPasteboard] setString:clipboardString];
    [AlertView showWithTitle:@"Copied to clipboard:" andMessage:clipboardString];
    PNLOG(@"invite.clipboard");
    if (self.callback) self.callback(InviteMethodClipboard, YES);
}

- (void)inviteBySMS {
    void (^potato)() = ^{

        PNMessageComposeViewController* messageController = [[PNMessageComposeViewController alloc] init];

        NSString* formatString = [Configuration stringFor:@"share_sms_body"] ?: @"%@";
        [messageController setBody:[NSString stringWithFormat:formatString, self.group.join_url]];
        [messageController setCompletion:^(MessageComposeResult result) {
            if (result == MessageComposeResultSent) {
                PNLOG(@"invite.text.sent");
                if (self.callback) self.callback(InviteMethodTextMessage, YES);
            }
            else {
                PNLOG(@"invite.text.unsent");
                if (self.callback) self.callback(InviteMethodTextMessage, NO);
            }
        }];

        [self.presentingController presentViewController:messageController animated:YES completion:^{
            PNLOG(@"invite.text.show");
        }];
    };
    
    [PNUserContacts requestContactsWithCompletion:^(BOOL granted, NSArray *contacts) {
        if (granted)
            PNLOG(@"invite.text.request_contact.granted");
        else
            PNLOG(@"invite.text.request_contact.denied");

        potato();
    }];
}

@end
