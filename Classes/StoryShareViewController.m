//
//  CameraShareViewController.m
//
//
//  Created by Jim Young on 3/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryShareViewController.h"

#import "Api.h"
#import "App.h"
#import "PNTableCell.h"
#import "SavedApiRequest.h"
#import "NSString+Email.h"
#import "NSString+PhoneNumber.h"
#import "AlertView.h"
#import "StatusView.h"
#import "Directory.h"
#import "UserAvatarView.h"
#import "PNVideoCompressor.h"
#import "PNUserPreferences.h"
#import "PNProgress.h"
#import "PillLabel.h"

#import "CameraShareViewController+MediaInfo.h"
#import "CameraShareViewController+CameraRoll.h"
#import "CameraShareViewController+Facebook.h"
#import "CameraShareViewController+Twitter.h"

@interface StoryShareViewController ()<UITextFieldDelegate, NSFetchedResultsControllerDelegate> {
    SystemSoundID blipSoundID;

    BOOL _tableNeedsReload;
}

@property (nonatomic, strong) Directory* directory;
@property (nonatomic, strong) NSOperationQueue* filterQueue;

@property (nonatomic, strong) NSArray* itemArray;
@property (nonatomic, strong) NSArray* filteredItems;

@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic, strong) NSFetchedResultsController* userFetchController;
@property (nonatomic, strong) NSFetchedResultsController* addressBookFetchController;
@end

// ------------------------------------------------------------------------------

@interface CameraShareTableViewCell : PNTableCell

@property (nonatomic, strong) DirectoryItem* personOrGroup;

@property (nonatomic, strong) PillLabel* nameLabel;
@property (nonatomic, strong) UserAvatarView* avatar;

@property (nonatomic, assign) BOOL added;

@end

@implementation CameraShareTableViewCell

- (void)commonInit {

    self.backgroundColor = COLOR(whiteColor);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.avatar = [[UserAvatarView alloc] initWithFrame:CGRectMake(6,5,40,40)];
    [self addChild:self.avatar];

    self.nameLabel = [[PillLabel alloc] init];
    self.nameLabel.textColor = COLOR(darkGrayColor);
    self.nameLabel.pillColor = COLOR(orangeColor);
    self.nameLabel.insets = UIEdgeInsetsMake(8,10,8,12);
    [self addChild:self.nameLabel];

}

- (void)setPersonOrGroup:(DirectoryItem *)personOrGroup {
    self.nameLabel.text = personOrGroup.name;
    self.nameLabel.frame = CGRectZero;
    self.avatar.user = personOrGroup.user;
    self.avatar.hidden = !self.avatar.user.hasAvatar;

    if (personOrGroup.user) {
        self.nameLabel.font = USERFONT(24);
    }
    else {
        self.nameLabel.font = FONT(14);
    }

    if (!self.avatar.user && personOrGroup.person) {
        RHPerson* person = personOrGroup.person;
        if (person.hasImage)
            self.avatar.image = person.thumbnail;
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetMiddleLeft(0, b.size.height/2, self.nameLabel.frame);

    self.avatar.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.nameLabel.frame)+2, b.size.height/2, self.avatar.frame);
    [super layoutSubviews];
}

- (void)setAdded:(BOOL)added {
    _added = added;
    if (added) {
        self.nameLabel.pillColor = COLOR(greenColor);
        self.nameLabel.textColor = COLOR(blackColor);
        self.avatar.alpha = 1.0;
    }
    else {
        self.nameLabel.pillColor = COLOR(lightGrayColor);
        self.nameLabel.textColor = COLOR(whiteColor);
        self.avatar.alpha = 0.5;
    }
}

@end

// ------------------------------------------------------------------------------

@implementation StoryShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.selectedPeopleArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.info = @{};

        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef soundFileURLRef;
        soundFileURLRef = CFBundleCopyResourceURL(mainBundle,CFSTR("blip"), CFSTR("wav"), NULL);
        AudioServicesCreateSystemSoundID(soundFileURLRef,&blipSoundID);

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(defaultNavigationColor);

        self.titleLabel = [[PNLabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = COLOR(defaultForegroundColor);
        self.titleLabel.text = @"Processing...";
        self.titleLabel.font = FONT_B(18);

        self.backButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
        [self.backButton maskWithImage:[UIImage imageNamed:@"x"] inverted:NO];
        self.backButton.buttonColor = COLOR(blackColor);
        [self.backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];

        self.sendButton = [[PNButton alloc] init];
        [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
        self.sendButton.titleLabel.font = FONT_B(28);
        self.sendButton.buttonColor = COLOR(greenColor);
        self.sendButton.cornerRadius = 5;
        self.sendButton.enabled = NO;
        self.sendButton.disabledColor = [[COLOR(greenColor) darken:30] desaturate:30];
        [self.sendButton setBorderWithColor:COLOR(whiteColor) width:2];
        [self.sendButton addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];

        self.thumbView = [[UIImageView alloc] init];
        self.thumbView.contentMode = UIViewContentModeScaleAspectFill;

        self.textField = [[PNTextField alloc] init];
        self.textField.backgroundColor = [COLOR(defaultBackgroundColor) darken:25];
        self.textField.placeholder = @"Name, phone #, or username" ;
        self.textField.horizontalInset = 12;
        self.textField.font = FONT_B(16);
        self.textField.delegate = self;
        self.textField.returnKeyType = UIReturnKeySearch;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;

        self.addNewUserButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,36,36)];
        self.addNewUserButton.buttonColor = COLOR(greenColor);
        self.addNewUserButton.disabledColor = COLOR(grayColor);
        [self.addNewUserButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [self.addNewUserButton setBorderWithColor:COLOR(whiteColor) width:2];
        self.addNewUserButton.cornerRadius = 18;
        self.addNewUserButton.hidden = YES;
        [self.addNewUserButton addTarget:self action:@selector(onAddButton) forControlEvents:UIControlEventTouchUpInside];

        self.directory = [Directory shared];

        self.filterQueue = [[NSOperationQueue alloc] init];
        self.filterQueue.maxConcurrentOperationCount = 1;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    [self.view addSubview:self.topStrip];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.thumbView];

    [self.view addSubview:self.sendButton];

//    [self.view addSubview:self.textField];
    [self.view addSubview:self.addNewUserButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGRect b = self.view.bounds;
    CGFloat m = 4;
    CGFloat y = 0;

    self.topStrip.frame = CGRectMake(0, y, b.size.width, 65);
    self.backButton.frame = CGRectSetOrigin(m, y+20+m, CGRectMake(0,0,40,30));

    self.thumbView.frame = CGRectSetTopRight(b.size.width-m, y+20+m, CGRectMake(0,0,38,38));
    self.thumbView.clipsToBounds = YES;
    self.thumbView.layer.cornerRadius = 4;

    [self.titleLabel sizeToFitTextWidth:b.size.width-2*m-self.backButton.frame.size.width];
    self.titleLabel.frame = CGRectSetCenter(b.size.width/2, 42, self.titleLabel.frame);

    CGFloat maxY = MAX(CGRectGetMaxY(self.topStrip.frame), CGRectGetMaxY(self.titleLabel.frame));
    maxY = MAX(maxY, y);

//    self.textField.frame = CGRectMake(0,maxY, b.size.width,50);
//    self.addNewUserButton.frame = CGRectSetMiddleRight(b.size.width-m, CGRectGetMidY(self.textField.frame), self.addNewUserButton.frame);

    self.sendButton.frame = CGRectMakeCorners(0,
                                              b.size.height-60,
                                              b.size.width,
                                              b.size.height);

    self.table.frame = CGRectMakeCorners(0,CGRectGetMaxY(self.topStrip.frame),b.size.width, CGRectGetMinY(self.sendButton.frame));

    self.sendButton.enabled = (self.videoURL || self.image);

    if (self.sendButton.enabled)
        [self.sendButton cycleScaleWithPeriod:0.3 startScale:1.01 endScale:0.99];
    else
        [self.sendButton.layer removeAllAnimations];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (_tableNeedsReload) {
        _tableNeedsReload = NO;
        [self calculateItemArrayWithCompletion:^(NSArray *itemArray) {
            self.itemArray = [self sortItems:itemArray];
            [self filterByText:nil];
            on_main(^{
                [self.table reloadData];
            });
            
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self initFetchControllers];
    _tableNeedsReload = YES;
}

- (void) calculateItemArrayWithCompletion:(void (^)(NSArray* itemArray))completion {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDirectoryStartUpdate) name:DirectoryDidStartUpdatingNotification object:nil];
    if (self.directory.status == DirectoryStatusIsPopulating) [self onDirectoryStartUpdate];

    [self.directory populateUsingAddressBook:NO completion:^(NSArray *directoryItems, BOOL authorized) {

        [[NSNotificationCenter defaultCenter] removeObserver:self name:DirectoryDidStartUpdatingNotification object:nil];
        [PNProgress dismiss];

        // This following nasty section of code constructs the list of people to show in the table:

        NSMutableArray* allItems = [NSMutableArray arrayWithArray:directoryItems];

        // Add self
        DirectoryItem* meItem = [DirectoryItem itemForUser:[User me]];
        meItem.rank = @(500);
        [allItems addObject:meItem];

        // Uggggggly...
        // Add explicitly specified items to the top of the list:
        NSArray* highlightedItems =  [self.highlightedGroups mapUsingBlock:^id(id obj) {
            DirectoryItem* item = [DirectoryItem itemForGroup:obj];
            return item;
        }];

        // Add active conversations:
        __block int x = 100;
        NSArray* activeItems = [[Group activeGroups] mapUsingBlock:^id(id obj) {
            DirectoryItem* item = [DirectoryItem itemForGroup:obj];
            item.rank = @(item.rank.intValue+x);
            x = x-1;

            if (item.user.isMe)
                item.rank = @(item.rank.intValue+100);

            return item;
        }];

        for (DirectoryItem* item in activeItems) {
            [allItems removeObject:item];
            [allItems addObject:item];
        }

        for (DirectoryItem* item in highlightedItems) {
            [allItems removeObject:item];
            [allItems addObject:item];
            item.rank = @(item.rank.integerValue + 1000);
        }

        [self.selectedPeopleArray addObjectsFromArray:highlightedItems];

        // Filter out contacts that are not friends
        NSMutableArray* removeItems = [NSMutableArray arrayWithCapacity:4];
        for (DirectoryItem* item in allItems) {
            if (!item.user.is_outgoing_friendValue)
                [removeItems addObject:item];
        }

        [allItems removeObjectsInArray:removeItems];

        if (completion)
            completion(allItems);

    }];
}

- (NSArray*) sortItems:(NSArray*)items {
    return [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DirectoryItem* item1 = (DirectoryItem*) obj1;
        DirectoryItem* item2 = (DirectoryItem*) obj2;
        NSComparisonResult rankSort = [item2.rank compare:item1.rank];
        if (rankSort == NSOrderedSame)
            return [item1.name caseInsensitiveCompare:item2.name];
        else
            return rankSort;
    }];
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.titleLabel.text = @"Send Video to...";

    [self.view setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.thumbView.image = image;
    self.titleLabel.text = @"Send Photo to...";
    [self.view setNeedsLayout];
}

- (void)setPreviewImage:(UIImage *)previewImage {
    _previewImage = previewImage;
    self.thumbView.image = previewImage;
    [self.view setNeedsLayout];
}

- (void)initFetchControllers
{

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND is_outgoing_friend = YES"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.userFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:[App moc]
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    self.userFetchController.delegate = self;

    request = [[NSFetchRequest alloc] initWithEntityName:@"AddressBookPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"deleted = NO"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]];
    self.addressBookFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[App moc]
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
    self.addressBookFetchController.delegate = self;

    [self.userFetchController performFetch:nil];
    [self.addressBookFetchController performFetch:nil];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    _tableNeedsReload = YES;
    [self.view setNeedsLayout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    if (section == 1)
        return 1;
    else
        return self.filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CameraShareTableViewCell* cell = [self.table dequeueReusableCellWithIdentifier:@"directoryCell"];
        if (!cell) {
            cell = [[CameraShareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"directoryCell"];
        }
        cell.personOrGroup = nil;
        cell.nameLabel.text = @"My Story";
        cell.nameLabel.font = HEADFONT(28);
        cell.added = self.storySelected;
        return cell;
    }
    if (indexPath.section == 1) {
        CameraShareTableViewCell* cell = [self.table dequeueReusableCellWithIdentifier:@"directoryCell"];
        if (!cell) {
            cell = [[CameraShareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"directoryCell"];
        }
        cell.personOrGroup = nil;
        cell.nameLabel.text = @"Save to camera roll";
        cell.nameLabel.font = HEADFONT(28);
        cell.added = self.albumSelected;
        return cell;
    }
    else {
        if (self.filteredItems.count > indexPath.row) {
            DirectoryItem* person = [self.filteredItems objectAtIndex:indexPath.row];
            CameraShareTableViewCell* cell = [self.table dequeueReusableCellWithIdentifier:@"directoryCell"];
            if (!cell) {
                cell = [[CameraShareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"directoryCell"];
            }

            cell.personOrGroup = person;
            cell.added = [self.selectedPeopleArray containsObject:person];
            return cell;
        }
    }
    return nil;
}

- (void)toggleSelection:(DirectoryItem*)person inCell:(UITableViewCell*)cell {
    if ([self.selectedPeopleArray containsObject:person]) {
        [self.selectedPeopleArray removeObject:person];
        [(CameraShareTableViewCell*)cell setSelected:YES];
    }
    else {
        [self.selectedPeopleArray addObject:person];
        [(CameraShareTableViewCell*)cell setSelected:NO];
    }

    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.storySelected = !self.storySelected;
    }
    else if (indexPath.section == 1) {
        self.albumSelected = !self.albumSelected;
    }
    else {
        id person = [self.filteredItems objectAtIndex:indexPath.row];
        UITableViewCell* cell = [self.table cellForRowAtIndexPath:indexPath];
        [self toggleSelection:person inCell:cell];
    }
    [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 0) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    [self filterByText:newString];
    return YES;
}

// If return pressed, do a search for username..
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSString *regex = @"^[a-zA-Z0-9\\-]{2,16}$";
    NSString *atLeastOneLetterRegex = @"[a-zA-Z]";
    if ([textField.text isMatchedByRegex:regex] && [textField.text isMatchedByRegex:atLeastOneLetterRegex]) {
        [[Api sharedApi] postPath:@"/users"
                       parameters:@{@"usernames":textField.text}
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             NSArray* users = [[entities setOfClass:[User class]] allObjects];
                             if (users.count) {
                                 for (User* u in users) {
                                     DirectoryItem* item = [DirectoryItem itemForUser:u];
                                     [self addDirectoryItem:item];
                                 }
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.table reloadData];
                                 });
                             }
                             else {
                                 [StatusView showTitle:nil message:[NSString stringWithFormat:@"No search results for \"%@\"", textField.text]
                                            completion:nil
                                              duration:2];
                             }
                         }];
    }
    return NO;
}

- (void)filterByText:(NSString*)text {

    [self.filterQueue cancelAllOperations];

    [self.filterQueue addOperationWithBlock:^{

        if (text.length) {
            self.filteredItems = [self.itemArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
                DirectoryItem* person = (DirectoryItem*) obj;
                if ([person.name isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
                if ([person.email isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
                if ([person.phoneNumber isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
                return NO;
            }];
        }
        else {
            self.filteredItems = self.itemArray;
        }

        // remove excluded users
        if (self.excludedPeopleArray.count) {
            NSMutableArray* a = [self.filteredItems mutableCopy];
            NSArray* exc = [self.excludedPeopleArray mapUsingBlock:^id(id obj) {
                if ([obj isKindOfClass:[User class]])
                    return [DirectoryItem itemForUser:obj];
                return obj;
            }];

            for (id obj in exc) {
                [a removeObject:obj];
            }
            self.filteredItems = a;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
            self.addNewUserButton.enabled = ([text isPhoneNumber] || [text hasEmail]);
            self.addNewUserButton.hidden = (self.filteredItems.count > 0);
        });
    }];
}

- (void)popController {
    if (self.navigationController)
        if ([[self.navigationController viewControllers] objectAtIndex:0] == self)
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onAddButton {
    if (self.textField.text.length) {
        if ([self.textField.text isPhoneNumber]) {

            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add %@", self.textField.text]
                                                             message:@"What is this person's name?"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
            alert.tag = 0;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.placeholder = @"Name";
            [alert show];

        }
        else if ([self.textField.text hasEmail]) {
            DirectoryItem* newItem = [[DirectoryItem alloc] init];
            newItem.email = self.textField.text;
            newItem.name = newItem.email;
            self.textField.text = nil;
            [self addDirectoryItem:newItem];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == alertView.cancelButtonIndex)
        return;

    NSString *text;
    if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        text = textField.text;
    }

    if (alertView.tag == 0) {
        DirectoryItem* newItem = [[DirectoryItem alloc] init];
        newItem.name = text.length ? text : self.textField.text;
        newItem.phoneNumber = self.textField.text;
        self.textField.text = nil;
        [self addDirectoryItem:newItem];
    }
}

- (void)addDirectoryItem:(DirectoryItem*)item {
    self.itemArray = [@[item] arrayByAddingObjectsFromArray:[self.itemArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
        return ![item isEqual:obj];
    }]];
    if (![self.selectedPeopleArray containsObject:item])
        [self.selectedPeopleArray addObject:item];
    [self filterByText:nil];
    [self.view endEditing:YES];
}

# pragma mark actions

- (void)onBack {
    if ([self.delegate respondsToSelector:@selector(shareControllerDidCancel:)])
        [self.delegate shareControllerDidCancel:self];
    else {
        on_main(^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)onSend {
    if (self.selectedPeopleArray.count == 0 && !self.storySelected && !self.albumSelected) {
        [StatusView showTitle:@"No recipients selected" message:@"Tap names to select recipients" completion:nil duration:2.5];
    }
    else {
        [self.sendButton.layer removeAllAnimations];
        self.sendButton.enabled = NO;

        if (self.albumSelected)
            [self saveToCameraRoll];

        if ([self.delegate respondsToSelector:@selector(shareControllerWillSend:)])
            [self.delegate shareControllerWillSend:self];

        if (self.storySelected)
            PNLOG(@"send.story");

        if (self.selectedPeopleArray.count > 0)
            PNLOG(@"send.snap");

        if (self.albumSelected)
            PNLOG(@"send.camera_roll");

        on_default(^{
        });
    }
}

- (void)onSave {

    NSMutableArray* saveOptions = [NSMutableArray arrayWithCapacity:5];

    [saveOptions addObject:@[@"Save to camera roll", ^(){ [self saveToCameraRoll]; }]];

    // [saveOptions addObject:@[@"Facebook", ^(){ [self publishToFacebook]; }]];

//    if (self.image && !self.videoURL)
//        [saveOptions addObject:@[@"Post to Twitter", ^(){ [self publishToTwitter]; }]];
//
//    if (self.isCreator && self.image) {
//        [saveOptions addObject:@[@"Set as profile", ^(){ [self saveAvatar]; }]];
//        [saveOptions addObject:@[@"Use as wallpaper", ^(){ [self saveWallpaper]; }]];
//    }

    NSArray* buttonArray = [saveOptions mapUsingBlock:^id(id obj) {
        return [(NSArray*)obj objectAtIndex:0];
    }];

    if (saveOptions.count) {
        [[[PNActionSheet alloc] initWithTitle:nil
                                   completion:^(NSInteger buttonIndex, BOOL didCancel) {

                                       if (buttonIndex < saveOptions.count) {
                                           void (^block)() = [[saveOptions objectAtIndex:buttonIndex] objectAtIndex:1];
                                           if (block) block();
                                       }
                                   } cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                             otherButtonArray:buttonArray]
         showInView:self.view];
    }
    else {
        [StatusView showTitle:@"This cannot be saved" message:nil completion:nil duration:1.5];
    }
}

#pragma mark actions

- (void)onSendSuccess {
    on_main(^{
        AudioServicesPlaySystemSound(blipSoundID);
    });
}

#pragma mark CreateGroupDelegate method
- (void)didCreateGroup:(Group*)group withUsers:(NSArray*)users {
    //
}

- (void) saveAvatar {
    UIImage* image = self.image ?: self.previewImage;
    NSData* data = UIImageJPEGRepresentation([[image reorientedImage] imageByScalingProportionallyToFit:CGSizeMake(600, 600)], 0.8);

    SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/users/update"
                                                 parameters:nil
                                                       data:data
                                                  dataParam:@"avatar_image_file"
                                               dataMimeType:@"image/jpeg"
                           ];

    AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {
        if (!error) [StatusView showTitle:@"Updated profile photo" message:nil completion:nil duration:1.5];
    }];
    [[Api sharedApi] enqueueOperation:uploadOperation];
}

- (void) saveWallpaper {
    UIImage* image = self.image ?: self.previewImage;
    NSData* data = UIImageJPEGRepresentation([[image reorientedImage] imageByScalingProportionallyToFit:CGSizeMake(1440, 1440)], 0.8);

    SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/accounts/update"
                                                 parameters:nil
                                                       data:data
                                                  dataParam:@"one_to_one_wallpaper_image_file"
                                               dataMimeType:@"image/jpeg"
                           ];

    AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {
        if (!error) [StatusView showTitle:@"Updated wallpaper" message:nil completion:nil duration:1.5];
    }];
    [[Api sharedApi] enqueueOperation:uploadOperation];
}

- (void)onDirectoryStartUpdate {
    [PNProgress show];
}

- (void)dealloc {
    [[NSFileManager defaultManager] removeItemAtURL:self.videoURL error:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
