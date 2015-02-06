//
//  OneToOneDetailViewController.m
//  groups
//
//  Created by Jim Young on 12/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "OneToOneDetailViewController.h"
#import "App.h"
#import "Api.h"
#import "AppViewController.h"
#import "User.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "SkyAccount.h"
#import "AlertView.h"
#import "StatusView.h"
#import "UserAvatarView.h"

#define kDetailToolbarHeight 44
#define kDetailHeaderHeight 30

@interface OneToOneDetailViewController()

@property (nonatomic, strong) User* user;
@property (strong, nonatomic) SkyAccount* account;

@property (nonatomic) UIImageView* wallView;
@property (nonatomic) PNLabel* altNameLabel;
@property (nonatomic) UserAvatarView* avatarView;
@property (nonatomic) PNLabel* statusTextLabel;
@property (nonatomic) PNLabel* statusLabel;

@property (nonatomic, strong) PNButton* deleteButton;
@property (nonatomic, strong) PNButton* blockButton;
@property (nonatomic, strong) PNButton* contactButton;

@end

@implementation OneToOneDetailViewController

- (id)init {

    self = [super init];
    self.view.backgroundColor = COLOR(lightGrayColor);

    self.wallView = [[UIImageView alloc] init];
    self.wallView.contentMode = UIViewContentModeScaleAspectFill;
    self.table.backgroundView = self.wallView;

    self.avatarView = [[UserAvatarView alloc] initWithFrame:CGRectMake(50,0,100,100)];
    self.avatarView.userInteractionEnabled = YES;

    self.altNameLabel = [[PNLabel alloc] initWithFrame:CGRectMake(0,100,200,30)];
    self.altNameLabel.textAlignment = NSTextAlignmentCenter;
    self.altNameLabel.font = USERFONT(16);

    PNTableCell* avatarCell = [[PNTableCell alloc] init];
    [avatarCell addChild:self.altNameLabel];
    [avatarCell addChild:self.avatarView];
    avatarCell.centerX = YES;
    avatarCell.paddingY = 10;
    [avatarCell sizeToFit];

    self.deleteButton = [[PNButton alloc] initWithFrame:CGRectMake(10,0,200,50)];
    self.deleteButton.cornerRadius = 5;
    [self.deleteButton setTitle:@"Clear messages" forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = FONT_B(14);
    self.deleteButton.buttonColor = COLOR(redColor);
    [self.deleteButton addTarget:self action:@selector(onDelete) forControlEvents:UIControlEventTouchUpInside];
    PNTableCell* deleteCell = [[PNTableCell alloc] init];
    [deleteCell addChild:self.deleteButton];
    deleteCell.paddingY = 10;
    [deleteCell sizeToFit];

    // Blocking

    self.blockButton = [[PNButton alloc] initWithFrame:CGRectMake(10,0,200,50)];
    self.blockButton.cornerRadius = 5;
    self.blockButton.hidden = YES;
    self.blockButton.titleLabel.font = FONT_B(14);
    [self.blockButton addTarget:self action:@selector(onBlock) forControlEvents:UIControlEventTouchUpInside];
    PNTableCell* blockCell = [[PNTableCell alloc] init];
    [blockCell addChild:self.blockButton];
    blockCell.paddingY = 10;
    [blockCell sizeToFit];

    // Unfriending

    self.contactButton = [[PNButton alloc] initWithFrame:CGRectMake(10,0,200,50)];
    self.contactButton.cornerRadius = 5;
    self.contactButton.hidden = YES;
    self.contactButton.titleLabel.font = FONT_B(14);
    [self.contactButton addTarget:self action:@selector(onContact) forControlEvents:UIControlEventTouchUpInside];
    PNTableCell* contactCell = [[PNTableCell alloc] init];
    [contactCell addChild:self.contactButton];
    contactCell.paddingY = 10;
    [contactCell sizeToFit];

    self.cells = [@[
                    avatarCell,
                    deleteCell,
                    blockCell,
                    contactCell
                    ] mutableCopy];

    self.table.canCancelContentTouches = NO;
    return self;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.wallView.frame = self.table.bounds;

    //    SkyAccount* ac = [SkyAccount forUser:self.user];
    //    NSString* wallpaper= [ac one_to_one_wallpaper_url];
    //    if (wallpaper) [self.wallView setImageWithURL:[NSURL URLWithString:wallpaper]];

    // ===== Toolbar =====
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;
    [navBar setBarTintColor:COLOR(grayColor)];
}

-(void)setGroup:(Group *)group {

    if (group != _group) {
        _group = group;
        if (_group.other_user != self.user) {
            [self.user removeObserver:self forKeyPath:@"updated_at"];
            [self updateUser:_group.other_user ];
            [_group.other_user addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];
            _user = _group.other_user;
            self.avatarView.user = _user;
            self.altNameLabel.text = _user.alternateName;

            [self.account removeObserver:self forKeyPath:@"updated_at"];
            self.account = [SkyAccount forUser:group.other_user];
            [self.account addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void) updateUser:(User*)user {
    self.navigationItem.title = user.displayName;
    [self updateButtons:user];
    self.altNameLabel.text = user.alternateName;

    [self.view setNeedsLayout];
}

- (void) updateButtons:(User*)user {

    BOOL hasLastMessage = user.oneToOneGroup.last_message != nil;
    self.blockButton.hidden = user.isMe;

    self.deleteButton.enabled = hasLastMessage;

    if (user.is_blockedValue) {
        [self.blockButton setTitle:@"Unblock" forState:UIControlStateNormal];
        self.blockButton.buttonColor = COLOR(greenColor);
    }
    else {
        [self.blockButton setTitle:@"Block" forState:UIControlStateNormal];
        self.blockButton.buttonColor = COLOR(grayColor);
    }

    if (user.is_contactValue && !hasLastMessage) {
        self.contactButton.buttonColor = COLOR(grayColor);
        [self.contactButton setTitle:@"Remove" forState:UIControlStateNormal];
        self.contactButton.hidden = NO;
    }
}

#pragma mark actions

- (void) onDelete {
    AlertView* alert = [[AlertView alloc] initWithTitle:@"Clear messages?"
                                                message:nil
                                         andButtonArray:@[@"Confirm", @"Cancel"]];
    [alert showWithCompletion:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            self.group.deleted_at = [NSDate date];
            self.group.updated_at = self.group.deleted_at;
            [self.group save];

            self.group.other_user.is_communicatingValue = NO;
            self.group.other_user.has_one_to_one = NO;
            [self.group.other_user save];

            [self.deckController openInbox];

            [self.group markDeletedWithCompletion:nil]; // Mark deleted on server..
        }
    }];
}

- (void) onBlock {
    if (self.user.is_blockedValue) {
        AlertView* alert = [[AlertView alloc] initWithTitle:@"Confirm unblock"
                                                    message:@"Allow this person to send you messages?"
                                             andButtonArray:@[@"Confirm", @"Cancel"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [[Api sharedApi] postPath:[NSString stringWithFormat:@"/users/%@/unblock", self.user.id]
                               parameters:nil
                                 callback:^(NSSet *entities, id responseObject, NSError *error) {
                                     if (!error) {
                                         self.user.is_blockedValue = NO;
                                         self.user.updated_at = [NSDate date];
                                         [StatusView showTitle:@"Block removed!" message:nil completion:nil duration:2.0];
                                     }
                                 }];
            }
        }];
    }
    else {
        AlertView* alert = [[AlertView alloc] initWithTitle:@"Confirm block"
                                                    message:@"This person will no longer be able to send you messages."
                                             andButtonArray:@[@"Confirm", @"Cancel"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [[Api sharedApi] postPath:[NSString stringWithFormat:@"/users/%@/block", self.user.id]
                               parameters:nil
                                 callback:^(NSSet *entities, id responseObject, NSError *error) {
                                     if (!error) {
                                         self.user.is_blockedValue = YES;
                                         self.user.updated_at = [NSDate date];
                                         [StatusView showTitle:@"Blocked!" message:nil completion:nil duration:2.0];
                                     }
                                 }];
            }
        }];

    }
}


- (void) onContact {
    if (self.user.is_contactValue) {
        AlertView* alert = [[AlertView alloc] initWithTitle:[NSString stringWithFormat:@"Remove %@?", self.user.displayName]
                                                    message:nil
                                             andButtonArray:@[@"Confirm", @"Cancel"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [Contact removeUsers:@[self.user] withCompletion:^(NSArray *contacts, NSError *error) {
                    [StatusView showTitle:@"Removed" message:nil completion:nil duration:1.0];
                    [self.deckController openInbox];
                }];
            }
        }];
    }
}

#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[User class]])
        [self updateUser:object];

    else if ([object isKindOfClass:[User class]])
        [self updateUser:self.user];

    else if ([object isKindOfClass:[SkyAccount class]])
        [self updateUser:self.user];
}

-(void)dealloc {
    [_user removeObserver:self forKeyPath:@"updated_at"];
    [_account removeObserver:self forKeyPath:@"updated_at"];
}

@end
