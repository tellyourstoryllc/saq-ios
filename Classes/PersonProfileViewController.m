//
//  PersonProfileViewController.m
//  NoMe
//
//  Created by Jim Young on 1/20/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PersonProfileViewController.h"
#import "Api.h"

@interface PersonProfileViewController ()
@property (nonatomic,strong) PNButton* friendButton;
@property (nonatomic,strong) PNButton* ignoreButton;
@property (nonatomic,strong) PNButton* messageButton;
@end

@implementation PersonProfileViewController

- (id)init {
    self = [super init];

    self.friendButton = [PNButton new];
    self.friendButton.titleLabel.font = HEADFONT(24);
    [self.friendButton addTarget:self action:@selector(onFriend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.friendButton];

    self.messageButton = [PNButton new];
    self.messageButton.titleLabel.font = HEADFONT(24);
    [self.messageButton addTarget:self action:@selector(onMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];

    self.ignoreButton = [PNButton new];
    self.ignoreButton.titleLabel.font = HEADFONT(24);
    [self.ignoreButton addTarget:self action:@selector(onIgnore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.ignoreButton];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    CGRect b = self.view.bounds;
    if ([self hasIncomingRequest]) {
        self.friendButton.frame = CGRectInset(CGRectMake(0,0,b.size.width/3, 60),4,4);
        self.messageButton.frame = CGRectInset(CGRectMake(b.size.width/3,0,b.size.width/3, 60),4,4);
        self.ignoreButton.frame = CGRectInset(CGRectMake(2*b.size.width/3,0,b.size.width/3,60),4,4);
    }
    else {
        self.friendButton.frame = CGRectInset(CGRectMake(0,0,b.size.width/2, 60),4,4);
        self.messageButton.frame = CGRectInset(CGRectMake(b.size.width/2,0,b.size.width/2,60),4,4);
        self.ignoreButton.frame = CGRectZero;
    }
}

- (void)setUser:(User *)user {
    if (user == _user) return;
    [self.KVOController unobserve:_user];
    _user = user;
    [self update];
    [self.KVOController observe:_user
                        keyPath:@"updated_at"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [self update];
                          }];
}

- (BOOL)hasIncomingRequest {
    return (self.user.is_incoming_friendValue && !self.user.is_outgoing_friendValue && !self.user.is_incoming_ignoredValue);
}

- (void)update {
    if (_user.is_outgoing_friendValue) {
        self.friendButton.buttonColor = COLOR(friendColor);
        [self.friendButton setTitle:@"FRIEND" forState:UIControlStateNormal];
    }
    else {
        self.friendButton.buttonColor = COLOR(publicColor);
        if ([self hasIncomingRequest]) {
            [self.friendButton setTitle:@"ADD" forState:UIControlStateNormal];
        }
        else {
            [self.friendButton setTitle:@"ADD TO FRIENDS" forState:UIControlStateNormal];
        }
    }

    self.messageButton.buttonColor = COLOR(purpleColor);
    [self.messageButton setTitle:@"CHAT" forState:UIControlStateNormal];

    self.ignoreButton.buttonColor = COLOR(redColor);
    [self.ignoreButton setTitle:@"IGNORE" forState:UIControlStateNormal];
}

- (void)onFriend {
    NSString* path;
    if (self.user.is_outgoing_friendValue) {
        path = @"/friends/remove";
        self.user.is_outgoing_friendValue = NO;
    }
    else {
        path = @"/friends/add";
        self.user.is_outgoing_friendValue = YES;
    }

    self.user.updated_at = [NSDate date];
    [self.user save];

    [[Api sharedApi] postPath:path
                   parameters:@{@"friend_codes":self.user.friend_code}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSLog(@"add friend? %@", responseObject);
                     }];
}

- (void)onMessage {
    if ([self.delegate respondsToSelector:@selector(profileDidSelectMessage:)]) {
        [self.delegate profileDidSelectMessage:self.user];
    }
}

- (void)onIgnore {

}

@end
