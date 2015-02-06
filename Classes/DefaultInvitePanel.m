//
//  DefaultInvitePanel.m
//
//
//  Created by Jim Young on 3/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "DefaultInvitePanel.h"

#import "NSString+Email.h"
#import "NSString+PhoneNumber.h"
#import "PNTableCell.h"
#import "PNMessageComposeViewController.h"
#import "PNVideoCompressor.h"

#import "Api.h"
#import "Group.h"
#import "Directory.h"
#import "AlertView.h"
#import "StatusView.h"
#import "UserAvatarView.h"
#import "AppViewController.h"
#import "PNProgress.h"

@interface DefaultInviteTableViewCell : PNTableCell

@property (nonatomic, strong) DirectoryItem* person;
@property (nonatomic, strong) PNLabel* nameLabel;
@property (nonatomic, strong) PNButton* addButton;
@property (nonatomic, strong) UserAvatarView* avatar;

@property (nonatomic, assign) BOOL personSelected;

@end

@implementation DefaultInviteTableViewCell

- (void)commonInit {

    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.avatar = [[UserAvatarView alloc] initWithFrame:CGRectMake(8,5,50,50)];
    [self addChild:self.avatar];

    self.nameLabel = [[PNLabel alloc] init];
    self.nameLabel.font = FONT_B(14);
    self.nameLabel.textColor = COLOR(darkGrayColor);
    [self addChild:self.nameLabel];

    self.addButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.addButton.buttonColor = [UIColor clearColor];
    [self.addButton setBorderWithColor:COLOR(whiteColor) width:2];
    self.addButton.cornerRadius = 20;
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self addChild:self.addButton];
    self.addButton.userInteractionEnabled = NO;
}

- (void)setPerson:(DirectoryItem *)person {
    self.nameLabel.text = person.name;
    self.nameLabel.frame = CGRectZero;
    self.avatar.user = person.user;

    if (!self.avatar.user && person.person) {
        if (person.person.hasImage)
            self.avatar.image = person.person.thumbnail;
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.addButton.frame = CGRectSetMiddleRight(self.frame.size.width-5, self.frame.size.height/2, self.addButton.frame);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.avatar.frame)+10, self.frame.size.height/2, self.nameLabel.frame);
    [super layoutSubviews];
}

- (void)setPersonSelected:(BOOL)personSelected {
    if (_personSelected == personSelected) return;
    _personSelected = personSelected;
    if (_personSelected ) {
        [self.addButton setImage:[UIImage imageNamed:@"check-fat"] forState:UIControlStateNormal];
        self.addButton.buttonColor = COLOR(greenColor);
    }
    else {
        [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        self.addButton.buttonColor = [UIColor clearColor];
    }
}

@end

//

@interface DefaultInvitePanel() <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Directory* directory;

@property (nonatomic, strong) UIView* withAddressBookView;

@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) UIImageView* imagePreview;

@property (nonatomic, strong) PNTextField* textField;
@property (nonatomic, strong) PNButton* addNewUserButton;

@property (nonatomic, strong) PNLabel* memberLabel;

@property (nonatomic, strong) PNButton* doneButton;
@property (nonatomic, strong) PNButton* cancelButton;
@property (strong, nonatomic) UIView *topStrip;

@property (nonatomic, strong) NSArray* peopleArray;
@property (nonatomic, strong) NSArray* filteredPeopleArray;

@property (nonatomic, strong) NSMutableArray* selectedPeopleArray;
@property (nonatomic, strong) NSMutableArray* excludedPeopleArray;

@property (nonatomic, strong) UITableView* table;

@end

@implementation DefaultInvitePanel

- (BOOL)isNeeded {
    return [self.controller valueForKey:@"videoFileURL"] == nil;
}

- (void)didAppear {

    if ([Configuration boolFor:@"signup_skip_invite"]) {
        [self exitRegistration];
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDirectoryStartUpdate) name:DirectoryDidStartUpdatingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDirectoryUpdate) name:DirectoryDidUpdateNotification object:nil];

    if (self.directory.status == DirectoryStatusIsPopulating)
        [self onDirectoryStartUpdate];
    else if (self.directory.status == DirectoryStatusLocalPopulated)
        [self onDirectoryUpdate];
    else if (self.directory.status == DirectoryStatusFullyPopulated)
        [self onDirectoryUpdate];

    [self.directory populateWithCompletion:^(NSArray *directoryItems, BOOL authorized) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DirectoryDidStartUpdatingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DirectoryDidUpdateNotification object:nil];

        if (!authorized) {
            [self exitRegistration];
        }
        else {
            [self onDirectoryUpdate];
        }
    }];
}

- (void)onDirectoryStartUpdate {
    [PNProgress show];
}

- (void)onDirectoryUpdate {

    [PNProgress dismiss];

    BOOL omitEmails = [Configuration boolFor:@"native_sms_signup_invite"];

    self.peopleArray = [self.directory.items filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
        DirectoryItem* person = (DirectoryItem*)obj;
        if (omitEmails)
            return (person.name && [person.phoneNumber isPhoneNumber]);
        else
            return (person.name && ([person.phoneNumber isPhoneNumber] || [person.email hasEmail]));
    }];

    [self filterByText:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* titleText = [Configuration stringFor:@"signup_invite_title"] ?: @"Select friends that you want to exchange photos and videos with.";
        self.titleLabel.text = titleText;
        [self.titleLabel sizeToFitTextWidth:300];
        
        self.withAddressBookView.alpha = 1.0f;
    });
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = COLOR(lightGrayColor);

        self.selectedPeopleArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.excludedPeopleArray = [[NSMutableArray alloc] initWithCapacity:4];

        self.withAddressBookView = [[UIView alloc] init];
        self.withAddressBookView.alpha = 0.0f;
        [self addSubview:self.withAddressBookView];

        self.topStrip = [[UIView alloc] init];
        self.topStrip.backgroundColor = COLOR(redColor);
        [self addSubview:self.topStrip];

        [self bringSubviewToFront:self.leftButton];
        [self bringSubviewToFront:self.rightButton];

        self.titleLabel = [[PNLabel alloc] init];
        self.titleLabel.font = FONT_B(16);
        self.titleLabel.textColor = COLOR(whiteColor);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];

        self.imagePreview = [[UIImageView alloc] init];
        self.imagePreview.contentMode = UIViewContentModeScaleAspectFill;
        self.imagePreview.clipsToBounds = YES;
        self.imagePreview.layer.cornerRadius = 5;
        [self addSubview:self.imagePreview];

        self.textField = [[PNTextField alloc] init];
        self.textField.font = FONT(16);
        self.textField.textColor = COLOR(defaultForegroundColor);
        self.textField.backgroundColor = [COLOR(defaultBackgroundColor) darken:10];
        NSAttributedString* placeholder = [[NSAttributedString alloc] initWithString:@"Name or phone #"
                                                                          attributes:@{NSForegroundColorAttributeName:COLOR(grayColor)}];
        self.textField.attributedPlaceholder = placeholder;
        self.textField.horizontalInset = 8;
        self.textField.layer.cornerRadius = 5;
        self.textField.delegate = self;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [self.withAddressBookView  addSubview:self.textField];

        self.addNewUserButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
        self.addNewUserButton.buttonColor = COLOR(greenColor);
        self.addNewUserButton.disabledColor = COLOR(grayColor);
        [self.addNewUserButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [self.addNewUserButton setBorderWithColor:COLOR(whiteColor) width:2];
        self.addNewUserButton.cornerRadius = 20;
        self.addNewUserButton.hidden = NO;
        [self.addNewUserButton addTarget:self action:@selector(onAddButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.withAddressBookView addSubview:self.addNewUserButton];

        self.doneButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,55)];
        self.doneButton.buttonColor = COLOR(greenColor);
        self.doneButton.cornerRadius = 5.0;
        self.doneButton.titleLabel.font = FONT_B(21);
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(onDoneButton) forControlEvents:UIControlEventTouchUpInside];
        [self.withAddressBookView addSubview:self.doneButton];

        self.cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,35)];
        self.cancelButton.buttonColor = [UIColor lightGrayColor];
        self.cancelButton.cornerRadius = 5.0;
        self.cancelButton.titleLabel.font = FONT_B(14);
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(onCancelButton) forControlEvents:UIControlEventTouchUpInside];
        [self.withAddressBookView addSubview:self.cancelButton];

        self.table = [[UITableView alloc] init];
        self.table.backgroundColor = [UIColor clearColor];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.withAddressBookView addSubview:self.table];

        self.directory = [Directory shared];
    }
    return self;
}

- (void)layoutSubviews {

    CGRect b = self.bounds;
    CGFloat w = b.size.width;
    CGFloat m = 4;
    CGFloat y = 25;

    self.withAddressBookView.frame = b;

    self.topStrip.frame = CGRectMake(0, 0, b.size.width, 65);
    self.imagePreview.frame = CGRectInset(CGRectMake(0,0,65,65), 4, 4);

    self.titleLabel.frame = CGRectSetCenter(w/2, CGRectGetMidY(self.topStrip.frame), self.titleLabel.frame);

    y = CGRectGetMaxY(self.topStrip.frame)+m;

    self.textField.frame = CGRectSetOrigin(m, y, CGRectMake(0,0,b.size.width-2*m,44));
    self.addNewUserButton.frame = CGRectSetMiddleRight(b.size.width-m, CGRectGetMidY(self.textField.frame), self.addNewUserButton.frame);

    self.table.frame = CGRectMakeCorners(0,CGRectGetMaxY(self.textField.frame)+2,b.size.width, b.size.height-100);
    self.doneButton.frame = CGRectMakeCorners(0, CGRectGetMaxY(self.table.frame), b.size.width, CGRectGetMaxY(self.table.frame)+60);
    self.cancelButton.frame = CGRectMakeCorners(0, CGRectGetMaxY(self.doneButton.frame), b.size.width, b.size.height);

    self.doneButton.frame = CGRectInset(self.doneButton.frame, 8, 4);
    self.cancelButton.frame = CGRectInset(self.cancelButton.frame, 8, 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPeopleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.filteredPeopleArray.count > indexPath.row) {
        DirectoryItem* person = [self.filteredPeopleArray objectAtIndex:indexPath.row];
        DefaultInviteTableViewCell* cell;
        cell = [self.table dequeueReusableCellWithIdentifier:@"contactCell"];
        if (!cell) {
            cell = [[DefaultInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
        }

        cell.person = person;
        cell.personSelected = [self.selectedPeopleArray containsObject:person];
        return cell;
    }
    return nil;
}

- (void)toggleSelection:(DirectoryItem*)person inCell:(UITableViewCell*)cell {
    if ([self.selectedPeopleArray containsObject:person]) {
        [self.selectedPeopleArray removeObject:person];
    }
    else {
        [self.selectedPeopleArray addObject:person];
    }

    self.textField.text = nil;
    [self endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id person = [self.filteredPeopleArray objectAtIndex:indexPath.row];
    UITableViewCell* cell = [self.table cellForRowAtIndexPath:indexPath];
    [self toggleSelection:person inCell:cell];
    [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 0) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }

    [self filterByText:newString];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return NO;
}

- (void)filterByText:(NSString*)text {
    if (text.length) {
        self.filteredPeopleArray = [self.peopleArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
            DirectoryItem* person = (DirectoryItem*) obj;
            if ([self.selectedPeopleArray containsObject:person]) return NO;
            if ([person.name isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            if ([person.user.username isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            if ([person.email isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            if ([person.phoneNumber isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            return NO;
        }];

        // remove excluded users
        if (self.excludedPeopleArray.count) {
            NSMutableArray* a = [self.filteredPeopleArray mutableCopy];
            NSArray* exc = [self.excludedPeopleArray mapUsingBlock:^id(id obj) {
                if ([obj isKindOfClass:[User class]])
                    return [DirectoryItem itemForUser:obj];
                return obj;
            }];

            for (id obj in exc) {
                [a removeObject:obj];
            }
            self.filteredPeopleArray = a;
        }

        if (!self.filteredPeopleArray.count) {
            self.addNewUserButton.enabled = ([text isPhoneNumber] || [text hasEmail]);
        }
    }
    else {
        self.filteredPeopleArray = self.peopleArray;
        self.addNewUserButton.enabled = NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });

    self.addNewUserButton.hidden = (self.filteredPeopleArray.count > 0);
}

- (void)onAddButtonPressed {
    [self endEditing:YES];

    if (self.textField.text.length) {
        if ([self.textField.text isPhoneNumber]) {

            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add %@", self.textField.text]
                                                             message:@"What is your friend's name?"
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
            [self addAndSelectDirectoryItem:newItem];
            self.textField.text = nil;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
        [self addAndSelectDirectoryItem:newItem];
        self.textField.text = nil;
    }
}

- (void)addAndSelectDirectoryItem:(DirectoryItem*)item {
    self.peopleArray = [@[item] arrayByAddingObjectsFromArray:self.peopleArray];
    [self.selectedPeopleArray addObject:item];
    [self filterByText:nil];
}

- (void)onDoneButton {
    if (self.selectedPeopleArray.count) {
        if ([Configuration boolFor:@"native_sms_signup_invite"])
            [self doInviteViaNativeSMS];
        else
            [self doInviteViaAPI];
    }
    else {
        [AlertView showWithTitle:@"No friends selected" andMessage:@"Select some friends to share this with!"];
    }
}

- (void)onCancelButton {
    [self exitRegistration];
}

- (void)doInviteViaAPI {

    NSMutableArray* userIds = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* emails = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc] initWithCapacity:4];

    for (DirectoryItem* person in self.selectedPeopleArray) {
        if (person.user)
            [userIds addObject:person.user.id];
        else if (person.email)
            [emails addObject:person.email];
        else if (person.phoneNumber)
            [phoneNumbers addObject:person.phoneNumber];
    }

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:6];
    if (userIds.count) [params setObject:[userIds componentsJoinedByString:@","] forKey:@"user_ids"];
    if (emails.count) [params setObject:[emails componentsJoinedByString:@","] forKey:@"emails"];
    if (phoneNumbers.count) [params setObject:[phoneNumbers componentsJoinedByString:@","] forKey:@"phone_numbers"];

    [[Api sharedApi] postPath:@"/contacts/add"
                   parameters:params
                     callback:^(NSSet *entities, id responseObject, NSError *error) {

                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                         self.excludedPeopleArray = [users mutableCopy];
                         [self exitRegistration];
                     }];
}

- (void)doInviteViaNativeSMS {

    NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc] initWithCapacity:4];

    for (DirectoryItem* person in self.selectedPeopleArray) {
        if (person.user)
            [users addObject:person.user];
        else if (person.phoneNumber)
            [phoneNumbers addObject:person.phoneNumber];
    }

    NSMutableArray* groups = [users valueForKey:@"oneToOneGroup"];

    if (phoneNumbers.count) {
        [self sendNativeToPhoneNumbers:phoneNumbers
                             andGroups:groups
                        withCompletion:^(BOOL success) {
                            on_main(^{
                                if (success) {

                                    [self.excludedPeopleArray addObjectsFromArray:self.selectedPeopleArray];
                                    [self.selectedPeopleArray removeAllObjects];
                                    [self.table reloadData];
                                    [[Api sharedApi] postPath:@"/contacts/add"
                                                   parameters:@{@"omit_sms_invite":@(YES),
                                                                @"phone_numbers":[phoneNumbers componentsJoinedByString:@","]}
                                                     callback:nil];
                                    [self exitRegistration];
                                }
                                else {
                                    [self filterByText:nil];
                                    [StatusView showTitle:@"Cancelled" message:@"Your message was not sent." completion:nil duration:2.5];
                                }
                            });
                        }];
    }
    else {
        // If all selected people are already users.. very unlikely.
    }
}

- (void) sendNativeToPhoneNumbers:(NSArray*)phoneNumbers
                        andGroups:(NSArray*)groups
                   withCompletion:(void (^)(BOOL success))completion
{
    PNMessageComposeViewController* messageController = [[PNMessageComposeViewController alloc] init];
    messageController.recipients = phoneNumbers;

    PCLOG(@"noob.invite.sms.compose");
    NSString* logNumberOfRecipients = [NSString stringWithFormat:@"noob.invite.sms.compose.%d_recipients", phoneNumbers.count];
    PCLOG(logNumberOfRecipients);

    NSString* bodyFormat = [Configuration stringFor:@"sms_invite_body"] ?: [NSString stringWithFormat:@"I just got %@: %@", kAppTitle, kWebrootURL];
    NSString* body = [NSString stringWithFormat:bodyFormat, [[User me] username]];
    [messageController setBody:body];
    [messageController setCompletion:^(MessageComposeResult result) {
        switch (result) {
            case MessageComposeResultCancelled:
                if (completion) completion(NO);
                PCLOG(@"noob.invite.sms.cancelled");
                [[Api sharedApi] postPath:@"/logs/event"
                               parameters:@{@"event_name":@"cancelled_invite",
                                            @"invite_method":@"native",
                                            @"invite_channel":@"sms",
                                            @"source":@"signup",
                                            @"recipients":[NSString stringWithFormat:@"%d",phoneNumbers.count]}
                                 callback:nil];
                break;

            case MessageComposeResultSent:
                if (completion) completion(YES);
                PCLOG(@"noob.invite.sms.sent");
                [[Api sharedApi] postPath:@"/logs/event"
                               parameters:@{@"event_name":@"sent_invite",
                                            @"invite_method":@"native",
                                            @"invite_channel":@"sms",
                                            @"source":@"signup",
                                            @"recipients":[NSString stringWithFormat:@"%d",phoneNumbers.count]}
                                 callback:nil];
                break;

            case MessageComposeResultFailed:
                PCLOG(@"noob.invite.sms.failed");
                if (completion) completion(NO);
                break;
        }
    }];

    [[AppViewController sharedAppViewController] presentViewController:messageController
                                                              animated:YES
                                                            completion:nil];
}

@end
