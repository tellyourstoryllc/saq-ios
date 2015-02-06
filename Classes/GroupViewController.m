//
//  GroupViewController.m
//  chat
//
//  Created by Cragin Godley on 10/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "App.h"
#import "Api.h"
#import "AppViewController.h"
#import "GroupViewController.h"
#import "SkyMessage.h"
#import "User.h"
#import "SkyAccount.h"
#import "Configuration.h"
#import "PNUserPreferences.h"

#import "FayeClient.h"
#import "AppDelegate.h"
#import "DAKeyboardControl.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "MessageTableCell.h"

#import "PNKit.h"
#import "Theme.h"
#import "StatusView.h"

#import "InviteButton.h"
#import "UpdateAvatarButton.h"
#import "UpdateUserWallpaperButton.h"

#import "GraphicsSettingsCell.h"

#import "PhotoCardView.h"
#import "VideoCardView.h"
#import "TextCardView.h"

#import "MessageCameraViewController.h"

#define kMaxTextInputHeight         140.0
#define kMinTextInputHeight         36.0
#define kTextInputVerticalPadding   24.0
#define kMessageShowTimestampThreshold  300;

@interface GroupViewController () <MessageTableCellDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate,
UITableViewDataSource, UITableViewDelegate, CardViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) UITapGestureRecognizer *viewTap;
@property (nonatomic) int cursorIndex;
@property (nonatomic) NSArray *autoCompletions;

@property (nonatomic) NSMutableDictionary *usersByMentionName;
@property (atomic) NSLock *mentionLock;

// Bespoke properties

@property (strong, nonatomic) UIView *toolbar; // The thing above keyboard that contains the text input view, send button, etc.
@property (strong, nonatomic) PNTextView *textView;
@property (strong, nonatomic) UIButton *sendButton;

@property (strong, nonatomic) PNButton *accessoryButton;

@property (strong, nonatomic) UIImageView *wallpaperView;

@property (assign, nonatomic) BOOL isDragging;
@property (assign, nonatomic)CGPoint lastScrollOffset;
@property (nonatomic) NSNumber *oldestRank;

@property (strong, nonatomic) UIView* headerView;
@property (nonatomic, strong) PNLabel* billboard;

// Observing..
@property (weak, nonatomic) Api* api;

@property (strong, nonatomic) User* oneToOneUser;
@property (strong, nonatomic) SkyAccount* oneToOneAccount;

@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@end

@implementation GroupViewController

-(void)viewDidLoad {

    [super viewDidLoad];
    __weak GroupViewController* weakSelf = self;
    self.view.backgroundColor = COLOR(defaultBackgroundColor);
    
    self.cameraController = [AppViewController sharedAppViewController].mainController.cameraController;

    self.billboard = [[PNLabel alloc] initWithFrame:CGRectZero];
    self.billboard.textAlignment = NSTextAlignmentCenter;
    self.billboard.font = HEADFONT(48);
    self.billboard.textColor = COLOR(lightGrayColor);
    [self.view addSubview:self.billboard];

    self.table = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.table];

    self.wallpaperView = [[UIImageView alloc] init];
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.wallpaperView belowSubview:self.table];

    // Table

    self.table.transform = CGAffineTransformMakeScale(1, -1);
    self.table.canCancelContentTouches = NO;

    // Artisanally crafted shit:

    CGRect b = self.view.bounds;
    CGFloat buttonSize = 80;
    CGFloat smallButtonSize = 60;

    // Toolbars
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, b.size.width, 50)];
    self.toolbar.backgroundColor = [[UIColor colorFromHexCode:@"#eef0f1"] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.toolbar];

    CALayer *toolbarBorder = [CALayer layer];
    toolbarBorder.frame = CGRectMake(0.0f, 0.0f, self.toolbar.frame.size.width, 0.5f);
    toolbarBorder.backgroundColor = [UIColor colorFromHexCode:@"#bfc2c7"].CGColor;
    [self.toolbar.layer addSublayer:toolbarBorder];

    self.accessoryButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.accessoryButton.layer.cornerRadius = 4;
    self.accessoryButton.layer.masksToBounds = YES;
    [self.accessoryButton setImage:[UIImage tintedImageNamed:@"input-photo" color:COLOR(blueColor)] forState:UIControlStateNormal];
    [self.accessoryButton setTappedBlock:^{
        weakSelf.lastScrollOffset = CGPointZero;
        [weakSelf.textView resignFirstResponder];
        [weakSelf adjustLayoutWithAnimation:YES];

        // Camera..
        [weakSelf showCamera];
    }];
    [self.toolbar addSubview:self.accessoryButton];

    self.textView = [[PNTextView alloc] initWithFrame:CGRectMake(0,0,200,40)];
    self.textView.delegate = self;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderColor = [UIColor colorFromHexCode:@"#bfc2c7"].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.font = [THEME fontWithSize:16];
    [self.textView setReturnKeyType:UIReturnKeyDefault];
    self.textView.placeholder = @"Write a message";
    self.textView.placeholderColor = COLOR(grayColor);

    [self.toolbar addSubview:self.textView];

    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,50)];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.sendButton];

    UINavigationBar* navBar = self.navigationController.navigationBar;

//    UIButton* leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    leftButton.backgroundColor = COLOR(whiteColor);
//    [leftButton maskWithImage:[UIImage imageNamed:@"left-arrow"] inverted:YES];
//    [leftButton addTarget:self action:@selector(xPressed) forControlEvents:UIControlEventTouchDown];
//    self.navigationItem.leftBarButtonItem.tintColor = COLOR(blackColor);
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(menuPressed)];
    self.navigationItem.rightBarButtonItem.tintColor = COLOR(whiteColor);

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[COLOR(messageColor) colorWithAlphaComponent:0.8]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    [navBar setBarTintColor:COLOR(messageColor)];

//    NSShadow* shadow = [NSShadow new];
//    [shadow setShadowColor:nil];
//    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
//    [titleBarAttributes setValue:[UIFont fontWithName:@"BebasNeueBold" size:22] forKey:NSFontAttributeName];
//    [titleBarAttributes setValue:COLOR(whiteColor) forKey:NSForegroundColorAttributeName];
//    [titleBarAttributes setValue:shadow forKey:NSShadowAttributeName];
//    navBar.titleTextAttributes = titleBarAttributes;

    [_api removeObserver:self forKeyPath:@"fayeConnected"];
    _api = [Api sharedApi];
    [self.api addObserver:self forKeyPath:@"fayeConnected" options:NSKeyValueObservingOptionNew context:nil];

    // Add refresh handlers
    [self.table addInfiniteScrollingWithActionHandler:^{
        NSString *path = [NSString stringWithFormat:@"%@/messages", weakSelf.group.path];
        NSMutableDictionary *params = [ @{ @"limit" : @"40" } mutableCopy];
        if(weakSelf.oldestRank)
            [params setObject:weakSelf.oldestRank forKey:@"below_rank"];

        [[Api sharedApi] postPath: path
                       parameters: params
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             on_main(^{
                                 [weakSelf.table.infiniteScrollingView stopAnimating];
                                 if(!error && [entities count] == 0)
                                     weakSelf.table.showsInfiniteScrolling = NO;
                             });
                         }];
    }];

    [self.table addPullToRefreshWithActionHandler:^{
        [weakSelf.table.pullToRefreshView stopAnimating];
    }];

    self.table.pullToRefreshView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectData) name:kWillClearDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectData) name:kDidClearDataNotification object:nil];

    [self updateGroup:self.group];

    UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    swipe.delegate = self;
    [self.table addGestureRecognizer:swipe];

}

// This allows carousel pan and swipe right gesture recognizers to dismiss to coexist.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.table.hidden = NO;

    [self initFetchedResultsController];

    self.group.last_seen_at = [NSDate date];
    [self.group save];

    [self.sendButton setTitleColor:([[Api sharedApi] fayeConnected] ? COLOR(blueColor) : COLOR(grayColor)) forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow) name:UIKeyboardDidShowNotification object:nil];

    [self setUserInteractionEnabled:[NSNumber numberWithBool:YES]];

    // Interactive keyboard dismissal
    self.view.keyboardTriggerOffset = self.toolbar.frame.size.height;

    self.table.frame = self.view.frameMinusKeyboard;

    __weak typeof(self) weakSelf = self;

    void (^keyboardHandler)(CGRect, BOOL, BOOL) = ^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {

        int yKeyboard = keyboardFrameInView.origin.y;

        CGRect f = weakSelf.toolbar.frame;
        f.origin.y = yKeyboard - f.size.height;
        weakSelf.toolbar.frame = f;

        weakSelf.table.frame = weakSelf.view.frameMinusKeyboard;
    };
    [self.view addKeyboardPanningWithActionHandler:keyboardHandler];

    [self updateGroup:self.group];
    [self updateHeaderView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeKeyboardControl];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillLayoutSubviews {
    [self adjustLayoutWithAnimation:NO];
    [super viewWillLayoutSubviews];
}

- (void) setGroup:(Group *)group {

    if (group != _group) {

        [_group removeObserver:self forKeyPath:@"updated_at"];
        _group = group;

        on_main(^{
            [self updateGroup:group];
        });

        [_group addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];

        if (_group.isOneToOneValue) {
            [self.oneToOneUser removeObserver:self forKeyPath:@"updated_at"];
            self.oneToOneUser = _group.other_user;
            [self.oneToOneUser addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];

            [self.oneToOneAccount removeObserver:self forKeyPath:@"updated_at"];
            self.oneToOneAccount = [SkyAccount forUser:group.other_user];
            [self.oneToOneAccount addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void) updateGroup:(Group*)group {
    if (group.isOneToOneValue) {
        self.navigationItem.title = group.other_user.isMe ? @"YOU" : group.other_user.displayName;
    }
    else {
        self.navigationItem.title = group.displayName;
    }

    UIColor* navBarColor = COLOR(messageColor);
    BOOL showWallpaper = [[PNUserPreferences shared] boolPreference:kShowWallpaperPrefKey orDefault:YES];

    if(group.wallpaper_url && showWallpaper) {
        [self.wallpaperView sd_setImageWithURL:[NSURL URLWithString:group.wallpaper_url]];

    } else if (group.isOneToOneValue) {
        SkyAccount* ac = [SkyAccount forUser:group.other_user];
        NSString* wallpaper= [ac one_to_one_wallpaper_url];
        if (wallpaper && showWallpaper) {
            [self.wallpaperView sd_setImageWithURL:[NSURL URLWithString:wallpaper]];
        }
    }

    [self updateHeaderView];

    UINavigationBar* navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:navBarColor];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([object isKindOfClass:[Group class]]) {
        on_main(^{
            [self updateGroup:object];
        });
    }

    else if ([object isKindOfClass:[User class]]) {
        on_main(^{
            [self updateGroup:self.group];
        });
    }

    else if ([object isKindOfClass:[SkyAccount class]]) {
        on_main(^{
            [self updateGroup:self.group];
        });
    }

    else if ([object isKindOfClass:[Api class]]) {
        BOOL isConnected = [Api sharedApi].fayeConnected;
        if(isConnected)
            [self refreshGroup];
        on_main(^{
            [self.sendButton setTitleColor:(isConnected ? COLOR(blueColor) : COLOR(redColor)) forState:UIControlStateNormal];
        });
    }
}

- (void) onKeyboardHide {
    [self adjustLayoutWithAnimation:NO];
}

- (void) onKeyboardShow {
    [self adjustLayoutWithAnimation:NO];
}

- (void) adjustLayoutWithAnimation:(BOOL)animate {

    void (^voidBlock)() = ^() {

        CGRect b = self.view.frameMinusKeyboard; // "b"ounds
        CGFloat m = 3; // "m"argin
        CGFloat mTop = 7;
        CGFloat sendButtonWidth = 50;
        CGFloat accButtonWidth = 30;
        CGFloat mediaButtonOutset = 6;

        self.wallpaperView.frame = self.view.bounds;

        CGFloat textViewWidth = b.size.width - sendButtonWidth - accButtonWidth - 4*m;

        // Calculate height for multiline text input:
        CGRect boundingRect = [self.textView.text boundingRectWithSize:CGSizeMake(self.textView.bounds.size.width-12, kMaxTextInputHeight)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:self.textView.font}
                                                               context:nil];
        CGSize textSize = boundingRect.size;

        CGFloat textViewHeight = textSize.height >= kMaxTextInputHeight ? kMaxTextInputHeight : textSize.height < kMinTextInputHeight ? kMinTextInputHeight : textSize.height + kTextInputVerticalPadding;

        CGFloat currentHeight = self.textView.frame.size.height;

        CGRect tvFrame = CGRectSetOrigin(accButtonWidth+2*m, mTop,
                                         CGRectMake(0, 0, textViewWidth, textViewHeight));

        CGRect toolFrame = CGRectMake(0, 0, b.size.width, textViewHeight + m + mTop);

        CGFloat navBarHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);

        self.toolbar.frame = CGRectSetBottomLeft(0, b.size.height, toolFrame);

        self.table.contentInset = UIEdgeInsetsMake(0,0,navBarHeight,0);

        self.sendButton.frame = CGRectSetBottomLeft(CGRectGetMaxX(tvFrame)+m, CGRectGetMaxY(tvFrame), CGRectMake(0,0,sendButtonWidth, kMinTextInputHeight));

        CGFloat dim = MIN(accButtonWidth, kMinTextInputHeight);
        self.accessoryButton.frame = CGRectSetBottomLeft(m, CGRectGetMaxY(tvFrame)-(kMinTextInputHeight-dim)/2, CGRectMake(0,0, dim, dim));

        self.table.frame = CGRectMakeCorners(0, 0,
                                             self.view.frame.size.width, CGRectGetMinY(self.toolbar.frame));

        self.billboard.frame = self.table.frame;
        self.billboard.frame = CGRectInset(self.billboard.frame, 8, 0);

        self.textView.frame = tvFrame;

        if (currentHeight != textViewHeight) {
            CGFloat topCorrect = (self.textView.bounds.size.height - self.textView.contentSize.height);
            topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
            self.textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
        }

        self.textView.scrollEnabled = textViewHeight >= kMaxTextInputHeight;

    };

    if (animate) {
        [UIView animateWithDuration:0.2 animations:voidBlock];
    } else {
        voidBlock();
    }
}

-(void) initFetchedResultsController
{

    if (self.fetchedResultsController) return;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SkyMessage"];

    if (self.group.deleted_at) {
        NSLog(@"deleted at: %@", self.group.deleted_at);
        request.predicate = [NSPredicate predicateWithFormat:@"group.id == %@ AND created_at > %@", self.group.id, self.group.deleted_at];
    }
    else {
        request.predicate = [NSPredicate predicateWithFormat:@"group.id == %@", self.group.id];
    }

    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                ];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[App managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController performFetch:nil];
    [self updateHeaderView];
    [self.table reloadData];
    self.fetchedResultsController.delegate = self;
}

-(void) refreshGroup {

    SkyMessage *lastMessage = [self.fetchedResultsController.fetchedObjects firstObject];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(group.id == %@) AND (is_placeholder == YES)",self.group.id];

    // Important: fetch existing placeholders BEFORE the request starts in case someone sends a new message mid-request
    NSArray *placeholders = [SkyMessage findAllUsingPredicate:predicate inContext:[App moc]];
    [[Api sharedApi]
     postPath:self.group.path
     parameters:nil
     callback:^(NSSet *entities, id responseObject, NSError *error) {

         if (error) return;

         // At this point, outstanding message placeholders have failed to transmit
         for(SkyMessage *placeholder in placeholders) {
             BOOL stillExists = [[App managedObjectContext] existingObjectWithID:placeholder.objectID error:NULL] != nil;
             if(stillExists) {
                 [placeholder.managedObjectContext performBlock:^{
                     placeholder.transmission_failedValue = YES;
                     [placeholder save];
                 }];
             }
         }

         if(!entities || !lastMessage)
             return;

         // Detect gaps, delete old messages if necessary
         BOOL gapInMessages = YES;
         int minRank = INT32_MAX;

         for (Base *obj in entities) {
             if([obj isKindOfClass:[SkyMessage class]]) {
                 SkyMessage *m = (SkyMessage*)obj;
                 if (m.rankValue < minRank)
                     minRank = m.rankValue;
                 if(m.rankValue == lastMessage.rankValue) {
                     gapInMessages = NO;
                     break;
                 }

             }
         }

         if(gapInMessages) {
             NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SkyMessage"];

             // Important: don't delete placeholders
             request.predicate = [NSPredicate predicateWithFormat:@"group.id == %@ && rank < %d && is_placeholder == NO", self.group.id, minRank];

             NSError *error;
             NSArray *results = [[App managedObjectContext] executeFetchRequest:request error:&error];
             if(results == nil) {
                 NSLog(@"Error fetching old messages: %@", error);
             }
             else {
                 NSLog(@"Found a gap. Deleting %d cached messages.", results.count);
                 for(Base *obj in results)
                     [obj.managedObjectContext performBlockAndWait:^{
                         [obj destroyAndSave:NO];
                     }];

                 [[App managedObjectContext] save:nil];
             }
         }

     }];
}

- (void)markReadMessages {

    if (!self.view.window) return;

    NSMutableArray* newCells = [[NSMutableArray alloc] initWithCapacity:2];
    NSInteger maxRank = 0;

    for (MessageTableCell* cell in self.table.visibleCells) {
        if (!cell.message.user.isMe && cell.message.rankValue > self.group.last_seen_rankValue) {
            [newCells addObject:cell];
        }
        else {
            [cell.chatBubble.layer removeAllAnimations];
            cell.contentView.backgroundColor = nil;
        }

        SkyMessage* m = cell.message;
        NSInteger rank = m.rankValue;
        maxRank = (rank > maxRank) ? rank : maxRank;
    }

    if (maxRank > self.group.last_seen_rankValue || !self.group.last_seen_rank) {
        [self.group.managedObjectContext performBlock:^{
            self.group.last_seen_rankValue = maxRank;
        }];

        NSString* groupType = self.group.isGroupValue ? @"groups" : @"one_to_ones";
        [[Api sharedApi] postPath:[NSString stringWithFormat:@"/%@/%@/update", groupType, self.group.id]
                       parameters:@{@"last_seen_rank":@(maxRank)}
                         callback:nil];
    }

    if (newCells.count) {
        [self.group.managedObjectContext performBlock:^{
            self.group.last_seen_at = [NSDate date];
        }];

        [UIView animateWithDuration:0.25 delay:0.2
                            options:UIViewAnimationOptionAutoreverse
                         animations:^{
                             for (UITableViewCell* cell in newCells) {
                                 cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.9, -0.9), 0.03);
                             }
                         }
                         completion:^(BOOL finished) {
                             for (UITableViewCell* cell in newCells) {
                                 cell.transform = CGAffineTransformMakeScale(1,-1);
                                 cell.contentView.backgroundColor = nil;
                             }
                         }];
    }
}

-(void) dismissKeyboard {
    [self.textView resignFirstResponder];
}

-(void)keyboardSendPressed {
    [self.textView becomeFirstResponder];
    [self sendPressed:nil];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.table setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendPressed:nil];
    return NO;
}

- (void)sendPressed:(id)sender {
    NSString *text = [[NSString stringWithFormat:@"%@",self.textView.text] stringByTrimmingLeadingWhitespace];
    if(!text || text.length == 0)
        return;

    if ([Api sharedApi].fayeConnected) {
        [self sendMessageToApiWithText:text];
        self.textView.text = @"";
        [self textViewDidChange:self.textView];
        // [self.textView resignFirstResponder];

    } else {
        [StatusView showTitle:@"Please try again" message:@"Error communicating with server" completion:nil duration:2];
    }
}

- (void)menuPressed {
    PNActionSheet* sheet = [[PNActionSheet alloc] initWithTitle:nil
                                                     completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                                         NSLog(@"tapped %d", buttonIndex);

                                                         if (buttonIndex == 0)
                                                             [self performClearMessages];
                                                     }
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Clear messages"
                                               otherButtonArray:nil];

    [sheet showInView:self.view];
}

- (void)showCamera
{
    MessageCameraViewController* vc = [[MessageCameraViewController alloc] init];
    vc.group = self.group;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void) onDismiss {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:NO];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)swipeGesture:(UISwipeGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized)
        [self onDismiss];
}

-(User*) userByMentionName:(NSString*)name {
    [self.mentionLock lock];
    User *user = [self.usersByMentionName objectForKey:[name lowercaseString]];
    [self.mentionLock unlock];

    return user;
}

- (void)xPressed {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendMessageToApiWithText:(NSString*)text {

    NSMutableArray *mentions = [[NSMutableArray alloc] init];
    [[App moc] performBlockAndWait:^{

        // Find mentions
        NSArray *matches = [[Group mentionRegex] matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for(NSTextCheckingResult *match in matches) {
            NSString *mentionName = [text substringWithRange:[match rangeAtIndex:2]];
            if([@"@all" isEqualToString:mentionName])
                [mentions insertObject:[NSNumber numberWithInt:-1] atIndex:0];

            else {
                User *user = [self userByMentionName:mentionName];
                if(user)
                    [mentions insertObject:[NSNumber numberWithInt:[user.id intValue]] atIndex:0];
            }
        }
    }];

    NSString *placeholder_id = [self insertPlaceHolderMessageWithText:text attachment:NO];

    // Send to API
    NSDictionary *ext = self.group.isOneToOneValue ? @{@"action" : @"create_one_to_one_message"} : nil;
    PNLOG(@"group.send_text");

    User* admin = [self.group.admins anyObject];
    NSString* channel = self.group.isOneToOneValue ? self.group.channel : admin.oneToOneGroup.channel;

    NSDictionary* metadata = @{@"placeholder":placeholder_id};
    NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                     encoding:NSUTF8StringEncoding];
    [[Api sharedApi] sendBackgroundMessage:@{
                                             @"text": text,
                                             @"mentioned_user_ids": mentions,
                                             @"client_metadata" : metadataString
                                             }
                                 onChannel:channel
                                   withExt:ext];
}

- (void)viewDidOpen {
    if (self.group.hasUnreadMessages)
        self.table.contentOffset = CGPointMake(0, -1*self.table.contentInset.top);
    [self markReadMessages];
}

-(NSString*)insertPlaceHolderMessageWithText:(NSString*)text attachment:(BOOL)hasAttachment {

    NSString *placeholder_id = [NSString randomStringOfLength:32];
    if(hasAttachment) {
        text = text ?: @"";
        text = [NSString stringWithFormat:@"<attachment> %@", text];
    }

    [[App moc] performBlockAndWait:^{

        SkyMessage *message = [SkyMessage findOrCreateById:placeholder_id inContext:[App moc]];
        message.is_placeholderValue = YES;
        message.text = text;
        message.group = self.group;
        message.user = [User me];
        message.created_at = [NSDate date];
        message.rankValue = [[[self fetchedResultsController].fetchedObjects firstObject] rankValue] ?: 0;

        [message save];
    }];

    return placeholder_id;
}

-(void)setUserInteractionEnabled:(NSNumber*)enabledNumber {
    BOOL enabled = [enabledNumber boolValue];

    if(!enabled)
        [self dismissKeyboard];
    self.table.scrollEnabled = enabled;
    self.textView.userInteractionEnabled = enabled;
    self.sendButton.userInteractionEnabled = enabled;

    self.viewTap.enabled = !enabled;
}

-(void)dealloc {
    [_api removeObserver:self forKeyPath:@"fayeConnected"];
    [_group removeObserver:self forKeyPath:@"updated_at"];
    [_oneToOneUser removeObserver:self forKeyPath:@"updated_at"];
    [_oneToOneAccount removeObserver:self forKeyPath:@"updated_at"];

    self.textView.delegate = nil;
    self.fetchedResultsController.delegate = nil;

    self.table.showsInfiniteScrolling = NO;
    self.table.showsPullToRefresh = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self updateOldestRank];
        [self updateHeaderView];

        BOOL shouldScroll = self.table.contentOffset.y < 20;

        // Update table
        [self.table beginUpdates];
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.table insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]
                                  withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.table deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]
                                  withRowAnimation:UITableViewRowAnimationNone];
                        break;
                }
            }];
        }
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.table insertRowsAtIndexPaths:@[obj] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.table deleteRowsAtIndexPaths:@[obj] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        // Cell should update itself using KVO or other means.
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.table moveRowAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
        [self.table endUpdates];
        _itemChanges = nil;
        _sectionChanges = nil;

//        [self.table reloadData];
        if (shouldScroll) self.table.contentOffset = CGPointMake(0, -1*self.table.contentInset.top);

    });
}

- (void) disconnectData {
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.fetchedResultsController.delegate = nil;
}

- (void) reconnectData {
    self.fetchedResultsController.delegate = self;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"messageCell";
    MessageTableCell* cell = (MessageTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(!cell) {
        cell = [[MessageTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    SkyMessage* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.message = message;
    cell.delegate = self;
    cell.showTimestamp = [self shouldShowTimestampAtIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeScale(1, -1);

    return cell;
}

// Figure out if timestamp should be displayed:
- (BOOL)shouldShowTimestampAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.fetchedResultsController.fetchedObjects.count-1)
        return YES;

    SkyMessage* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SkyMessage* previousMessage = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];

    NSTimeInterval delta = [message.created_at timeIntervalSinceDate:previousMessage.created_at];
    return delta > kMessageShowTimestampThreshold;
}

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SkyMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Hide placeholders that aren't within the rank range of remote Messages
    if(message.is_placeholderValue && self.oldestRank && message.rankValue < self.oldestRank.intValue)
        return 0;

    CGFloat height = [MessageTableCell heightForMessage:message
                                           withMaxWidth:tableView.frame.size.width-kConversationMessageTableAvatarHW
                                    andTimestampEnabled:[self shouldShowTimestampAtIndexPath:indexPath]];
    return height + 4;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Use the section header to guide users when the room is empty

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerView ? self.headerView.bounds.size.height : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* header = self.headerView;
    header.transform = CGAffineTransformMakeScale(1, -1);
    return header;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setEditing:NO animated:NO];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.view.window) {

        if (self.isDragging && self.table.infiniteScrollingView.state == SVInfiniteScrollingStateStopped && self.table.pullToRefreshView.state == SVPullToRefreshStateStopped) {

            if (!CGPointEqualToPoint(self.lastScrollOffset, CGPointZero)) {
                CGFloat delta = scrollView.contentOffset.y - self.lastScrollOffset.y;
                CGFloat hideAccessoryBarThreshold = 20;
                if (scrollView.contentOffset.y > 0 && delta > hideAccessoryBarThreshold) {
                    [self.textView resignFirstResponder];
                    [self adjustLayoutWithAnimation:YES];
                } else if (scrollView.contentSize.height < self.table.frame.size.height) {
                    [self adjustLayoutWithAnimation:YES];
                }
            }
            self.lastScrollOffset = scrollView.contentOffset;
        }

    }

    [self markReadMessages];

}

#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    [self adjustLayoutWithAnimation:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {

    if (!range.length && !range.location && !string.length) {
        [textView resignFirstResponder];
        return NO;
    }

    // Get text leading up to the cursor position
    self.cursorIndex = range.location + string.length;

    return [textView.text length] + [string length] - range.length <= 1000;
}

#pragma mark MessageTableCellDelegate methods

- (void)didSelectAttachmentForCell:(MessageTableCell *)cell {

    [self.view endEditing:YES];

    if (cell.message.hasVideo || cell.message.hasImage) {
        SnapCardView* card = [[SnapCardView alloc] initWithFrame:self.view.bounds];
        card.message = cell.message;
        card.delegate = self;
        card.showDismissButton = YES;

        UITapGestureRecognizer* dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:card action:@selector(onDismiss)];
        [card addGestureRecognizer:dismissGesture];

        [card loadContent];
        [card unhideControls];
        [self.view addSubview:card];
        [card didAppear];
        [card didBecomeFeatured];

        [self.navigationController setNavigationBarHidden:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    }

    //    if (cell.message.hasVideo) {
    //        FullscreenMessageVideoPlayer* player = [[FullscreenMessageVideoPlayer alloc] init];
    //        player.message = cell.message;
    //        player.delegate = self;
    //        [self presentViewController:player animated:NO completion:^{
    //            [player play];
    //            [self markReadMessages];
    //        }];
    //    }
    //    else if (cell.message.hasImage) {
    //        FullscreenMessageImageView* viewer = [[FullscreenMessageImageView alloc] init];
    //        viewer.message = cell.message;
    //        viewer.delegate = self;
    //        [cell.message.group markReadWithCompletion:nil];
    //        [self presentViewController:viewer animated:NO completion:^{
    //            [self markReadMessages];
    //        }];
    //    }
}

-(void)willEnterForeground {
    self.group.last_seen_at = [NSDate date];
    [self.textView resignFirstResponder];
    [self adjustLayoutWithAnimation:NO];
}

- (void)updateOldestRank {
    // Find oldest rank
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SkyMessage"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"group.id == %@ AND is_placeholder == NO", self.group.id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]];

    NSError *error;
    NSArray *results = [self.fetchedResultsController.managedObjectContext executeFetchRequest:request error:&error];
    if(!results)
        NSLog(@"Error: %@", error);

    self.oldestRank = [results.lastObject rank];
}

- (void)updateHeaderView {

    int numSections = 0;

    CGRect bounds = self.table.bounds;

    PNView* v = [[PNView alloc] init];
    v.backgroundColor = [UIColor clearColor];

    NSString* labelText = @"";

    if ([Configuration stringFor:@"new_room_message"] && !self.group.isOneToOneValue) {
        if (self.group.isAdmin && [Configuration stringFor:@"new_room_admin_message"])
            labelText = [Configuration stringFor:@"new_room_admin_message"];
        else
            labelText = [Configuration stringFor:@"new_room_message"];
    }

    PNLabel* label = [PNLabel labelWithText:labelText andFont:FONT(14)];

    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFitTextWidth:bounds.size.width-20];
    [v addChild:label];

    CGFloat midX = label.frame.size.width/2;
    CGFloat curY = CGRectGetMaxY(label.frame);
    CGFloat m = 5;

    if (self.fetchedResultsController.fetchedObjects.count < 1 && !self.group.isMissingMessages) {
        self.billboard.text = [NSString stringWithFormat:@"Send a message!"];
    }
    else {
        self.billboard.text = nil;
    }

    v.paddingY = 5;
    v.centerX = YES;
    [v sizeToFit];

    self.headerView = numSections ? v : nil;
}

#pragma mark CardViewDelegate methods

- (void)card:(SnapCardView *)card didSelectExport:(SkyMessage *)snap {
    if (snap.hasVideo) {
        PNActionSheet* sheet = [[PNActionSheet alloc]
                                initWithTitle:nil
                                completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                    if (buttonIndex == 0) {
                                        [snap fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
                                            [[[ALAssetsLibrary alloc] init]
                                             writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                             completionBlock:^(NSURL *assetURL, NSError *error) {
                                                 if (error) {
                                                     [StatusView showTitle:@"Unable to save video"
                                                                   message:[NSString stringWithFormat:@"You must go to device Settings > Privacy > Photos > Turn on %@.", kAppTitle]
                                                                completion:nil
                                                                  duration:5];
                                                     PNLOG(@"video.save.fail.noauth");
                                                 } else {
                                                     [StatusView showTitle:@"Saved to Camera Roll" message:nil completion:nil duration:2.0];
                                                     PNLOG(@"video.save.success");
                                                 }
                                             }];
                                        }];
                                    }
                                }
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonArray:@[@"Save to camera roll"]];
        [sheet showInView:self.view];
    }

    else if (snap.hasImage) {
        PNActionSheet* sheet = [[PNActionSheet alloc]
                                initWithTitle:nil
                                completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                    if (buttonIndex == 0) {
                                        [snap fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
                                            [[[ALAssetsLibrary alloc] init]
                                             writeImageToSavedPhotosAlbum:photo.CGImage
                                             orientation:ALAssetOrientationUp
                                             completionBlock:^(NSURL *assetURL, NSError *error) {
                                                 if (error) {
                                                     [StatusView showTitle:@"Unable to save photo"
                                                                   message:[NSString stringWithFormat:@"You must go to device Settings > Privacy > Photos > Turn on %@.", kAppTitle]
                                                                completion:nil
                                                                  duration:5];
                                                     PNLOG(@"photo.save.fail.noauth");
                                                 }
                                                 else {
                                                     [StatusView showTitle:@"Saved to Camera Roll" message:nil completion:nil duration:2.0];
                                                     PNLOG(@"photo.save.success");
                                                 }
                                             }];
                                        }];
                                    }
                                }
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonArray:@[@"Save to camera roll"]];
        [sheet showInView:self.view];
    }
}

- (void)card:(SnapCardView *)card didSelectEdit:(SkyMessage *)snap {
    if (snap.hasVideo || snap.hasImage) {
        //
        [card removeFromSuperview];
    }
}

- (void)card:(SnapCardView *)card didSelectDismiss:(SkyMessage *)snap {
    [self.navigationController setNavigationBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [card removeFromSuperview];
    [card didDisappear];
}

- (void)performClearMessages {
    [self.group.managedObjectContext performBlock:^{
        [self disconnectData];
        self.fetchedResultsController = nil;
        self.group.deleted_at = [NSDate date];
        [self.group.managedObjectContext save:nil];
        [self initFetchedResultsController];
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

@end
