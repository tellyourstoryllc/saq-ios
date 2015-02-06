//
//  InviteButton.h
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PNButton.h"
#import "Group.h"

typedef enum
{
    InviteMethodNone = 0, // <-- user cancelled
    InviteMethodTextMessage,
    InviteMethodEmail,
    InviteMethodClipboard,
    InviteMethodFacebook,
    InviteMethodTwitter,
    InviteMethodQRCode,
    InviteMethodVoiceMail,
    InviteMethodPostcard,
    InviteMethodSmokeSignal
} InviteMethodType;

@interface InviteButton : PNButton

@property (nonatomic, weak) Group* group;
@property (nonatomic, weak) UIViewController* presentingController;

@property (nonatomic, copy) void(^callback)(InviteMethodType inviteMethod, BOOL success);

@end
