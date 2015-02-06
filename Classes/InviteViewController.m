//
//  DirectoryViewController.m
//  groups
//
//  Created by Jim Young on 2/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "InviteViewController.h"
#import "PNTableCell.h"
#import "AlertView.h"
#import "StatusView.h"
#import "UserAvatarView.h"
#import "NSString+Email.h"
#import "NSString+PhoneNumber.h"
#import "PNProgress.h"
#import "Api.h"
#import "App.h"
#import "AppViewController.h"
#import "PNMessageComposeViewController.h"

@interface DirectoryTableViewCell : PNTableCell
@property (nonatomic, strong) DirectoryItem* person;
@property (nonatomic, strong) PNLabel* nameLabel;
@property (nonatomic, strong) PNButton* addButton;

@property (nonatomic, strong) UserAvatarView* avatar;

@property (nonatomic, assign) BOOL added;

@end

@implementation DirectoryTableViewCell

- (void)commonInit {

    self.backgroundColor = COLOR(defaultBackgroundColor);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.avatar = [[UserAvatarView alloc] initWithFrame:CGRectMake(6,5,40,40)];
    [self addChild:self.avatar];

    self.nameLabel = [[PNLabel alloc] init];
    self.nameLabel.font = USERFONT(18);
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
    self.addButton.frame = CGRectSetTopRight(self.frame.size.width-10, 5, self.addButton.frame);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.avatar.frame)+5, CGRectGetMidY(self.addButton.frame), self.nameLabel.frame);
    [super layoutSubviews];
}

- (void)setAdded:(BOOL)added {
    _added = added;
    if (added) {
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

@interface InviteViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) Directory* directory;

@property (nonatomic, strong) NSArray* peopleArray;
@property (nonatomic, strong) NSArray* filteredPeopleArray;

@end

@implementation InviteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedPeopleArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Invite Friends";

    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;
    NSDictionary* barTextAttributes = @{UITextAttributeFont:FONT_B(18),
                                        UITextAttributeTextColor:COLOR(whiteColor),
                                        UITextAttributeTextShadowColor:[UIColor clearColor]};
    [navBar setTitleTextAttributes:barTextAttributes];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onExit)];
    self.navigationItem.leftBarButtonItem.tintColor = COLOR(whiteColor);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(onInviteDone)];
    [navBar setBarTintColor:COLOR(defaultNavigationColor)];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.titleLabel = [[PNLabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = COLOR(whiteColor);
    self.titleLabel.font = FONT_B(18);
    [self.view addSubview:self.titleLabel];

    self.textField = [[PNTextField alloc] init];
    self.textField.backgroundColor = [COLOR(defaultBackgroundColor) darken:25];
    self.textField.textColor = COLOR(whiteColor);
    NSAttributedString* placeholder = [[NSAttributedString alloc] initWithString:@"Name, phone #, or email" attributes:@{NSForegroundColorAttributeName:COLOR(grayColor)}];
    self.textField.attributedPlaceholder = placeholder;
    self.textField.horizontalInset = 5;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];

    self.addNewUserButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,36,36)];
    self.addNewUserButton.buttonColor = COLOR(greenColor);
    self.addNewUserButton.disabledColor = COLOR(grayColor);
    [self.addNewUserButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self.addNewUserButton setBorderWithColor:COLOR(whiteColor) width:2];
    self.addNewUserButton.cornerRadius = 18;
    self.addNewUserButton.hidden = YES;
    [self.addNewUserButton addTarget:self action:@selector(onAddButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addNewUserButton];

    self.doneButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    [self.doneButton setBorderWithColor:COLOR(whiteColor) width:2];
    self.doneButton.cornerRadius = 20.0;
    [self.doneButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    __weak InviteViewController* weakSelf = self;
    [self.doneButton setTappedBlock:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        if ([weakSelf.delegate respondsToSelector:@selector(inviteController:finishedSelectingWithPeople:)])
            [weakSelf.delegate inviteController:weakSelf finishedSelectingWithPeople:weakSelf.selectedPeopleArray];
    }];

    [self.view addSubview:self.doneButton];

    self.directory = [Directory shared];
    self.directory.authWasSkipped = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect b = self.view.bounds;
    CGFloat m = 5;
    CGFloat y = 0;

    self.titleLabel.text = self.title ?: @"Contacts";

    if (self.navigationController) {
        y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        self.doneButton.frame = CGRectZero;
        self.titleLabel.frame = CGRectZero;
        self.navigationItem.title = self.titleLabel.text;
    }
    else {
        y = 25;
        self.doneButton.frame = CGRectSetOrigin(m,y,self.doneButton.frame);
        [self.titleLabel sizeToFitTextWidth:b.size.width-2*m-self.doneButton.frame.size.width];
        self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, CGRectGetMaxY(self.doneButton.frame), self.titleLabel.frame);
    }

    CGFloat maxY = MAX(CGRectGetMaxY(self.doneButton.frame), CGRectGetMaxY(self.titleLabel.frame));
    maxY = MAX(maxY, y);

    self.textField.frame = CGRectMake(0,maxY, b.size.width,44);
    self.addNewUserButton.frame = CGRectSetMiddleRight(b.size.width-m, CGRectGetMidY(self.textField.frame), self.addNewUserButton.frame);

    self.table.frame = CGRectMake(0,CGRectGetMaxY(self.textField.frame)+2,b.size.width, b.size.height);
    self.table.frame = CGRectIntersection(self.table.frame, b);

    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)onDirectoryStartUpdate {
    [PNProgress show];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDirectoryStartUpdate) name:DirectoryDidStartUpdatingNotification object:nil];
    if (self.directory.status == DirectoryStatusIsPopulating) [self onDirectoryStartUpdate];

    [self.directory populateWithCompletion:^(NSArray *directoryItems, BOOL authorized) {

        [[NSNotificationCenter defaultCenter] removeObserver:self name:DirectoryDidStartUpdatingNotification object:nil];
        [PNProgress dismiss];

        self.peopleArray = directoryItems;
        [self filterByText:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });

        if (!authorized && !self.directory.authWasSkipped) {
            [StatusView showTitle:@"Unable to access contacts"
                          message:[NSString stringWithFormat:@"To enable, go to device Settings > Privacy > Contacts > Turn on %@.", kAppTitle]
                       completion:nil
                         duration:3];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPeopleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.filteredPeopleArray.count > indexPath.row) {
        DirectoryItem* person = [self.filteredPeopleArray objectAtIndex:indexPath.row];
        DirectoryTableViewCell* cell;
        cell = [self.table dequeueReusableCellWithIdentifier:@"directoryCell"];
        if (!cell) {
            cell = [[DirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"directoryCell"];
        }

        cell.person = person;
        cell.added = [self.selectedPeopleArray containsObject:person];
        return cell;
    }

    return nil;
}

- (void)toggleSelection:(DirectoryItem*)person inCell:(UITableViewCell*)cell {
    if ([self.selectedPeopleArray containsObject:person]) {
        [self.selectedPeopleArray removeObject:person];
        if ([self.delegate respondsToSelector:@selector(inviteController:didDeselectPerson:)]) {
            [self.delegate inviteController:self didDeselectPerson:person];
        }
        [(DirectoryTableViewCell*)cell setSelected:YES];
    }
    else {
        [self.selectedPeopleArray addObject:person];
        if ([self.delegate respondsToSelector:@selector(inviteController:didSelectPerson:)]) {
            [self.delegate inviteController:self didSelectPerson:person];
        }
        [(DirectoryTableViewCell*)cell setSelected:NO];
    }

    self.textField.text = nil;
    [self.view endEditing:YES];
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

- (void)filterByText:(NSString*)text {
    if (text.length) {
        self.filteredPeopleArray = [self.peopleArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
            DirectoryItem* person = (DirectoryItem*) obj;
            if (person.user != nil) return NO;
            if ([person.name isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            if ([person.email isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            if ([person.phoneNumber isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
            return NO;
        }];
    }
    else {
        self.filteredPeopleArray = [self.peopleArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
            DirectoryItem* person = (DirectoryItem*) obj;
            return person.user == nil;
        }];
    }

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

    [self.table reloadData];
    self.addNewUserButton.enabled = ([text isPhoneNumber] || [text hasEmail]);
    self.addNewUserButton.hidden = (self.filteredPeopleArray.count > 0);
}

- (void)onExit {
    if (self.selectedPeopleArray.count) {
        PNAlertView* alert = [[AlertView alloc] initWithTitle:nil message:@"Send invitations to the selected people?" andButtonArray:@[@"Yes", @"No"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self onInviteDone];
            }
            else {
                [self popController];
            }
        }];
    }
    else {
        [self popController];
    }
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

- (void)onAddButtonPressed {
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
    self.peopleArray = [@[item] arrayByAddingObjectsFromArray:self.peopleArray];
    [self.selectedPeopleArray addObject:item];
    [self filterByText:nil];
    [self.view endEditing:YES];

    if (item.email && [self.delegate respondsToSelector:@selector(inviteController:didAddEmailPerson:)]) {
        [self.delegate inviteController:self didAddEmailPerson:item];
    }
    else if (item.phoneNumber && [self.delegate respondsToSelector:@selector(inviteController:didAddPhoneNumberPerson:)]) {
        [self.delegate inviteController:self didAddPhoneNumberPerson:item];
    }
}

- (void)onInviteDone {
    __block NSArray* selectedPeople = self.selectedPeopleArray;

    if (selectedPeople.count) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([Configuration boolFor:@"native_sms_invite"])
                [self doInviteViaNativeSMS:selectedPeople];
            else
                [self doInviteViaAPI:selectedPeople];
        }];
    }
    else {
        [StatusView showTitle:@"No friends selected"
                      message:[NSString stringWithFormat:@"Please select friends you want to use %@ with", kAppTitle]
                   completion:nil duration:3];
    }

}

- (void)doInviteViaAPI:(NSArray*)people {

    NSMutableArray* userIds = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* emails = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc] initWithCapacity:4];

    for (DirectoryItem* person in people) {
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
                         [StatusView showTitle:nil
                                       message:@"Invitations will be sent to the friends you selected."
                                    completion:nil
                                      duration:3];
                     }];
}

- (void)doInviteViaNativeSMS:(NSArray*)people {

    NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc] initWithCapacity:4];

    for (DirectoryItem* person in people) {
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
                            if (success) {
                                [[Api sharedApi] postPath:@"/contacts/add"
                                               parameters:@{@"omit_sms_invite":@(YES),
                                                            @"phone_numbers":[phoneNumbers componentsJoinedByString:@","]}
                                                 callback:nil];
                            }
                            else {
                                [StatusView showTitle:@"Cancelled" message:@"Your invitation was not sent." completion:nil duration:2.5];
                            }
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

    PNLOG(@"invite.sms.compose");
    NSString* logNumberOfRecipients = [NSString stringWithFormat:@"invite.sms.compose.%d_recipients", phoneNumbers.count];
    PNLOG(logNumberOfRecipients);

    NSString* bodyFormat = [Configuration stringFor:@"sms_invite_body"] ?: [NSString stringWithFormat:@"I just got %@: %@", kAppTitle, kWebrootURL];
    NSString* body = [NSString stringWithFormat:bodyFormat, [App username]];
    [messageController setBody:body];
    [messageController setCompletion:^(MessageComposeResult result) {
        switch (result) {
            case MessageComposeResultCancelled:
                if (completion) completion(NO);
                PNLOG(@"invite.sms.cancelled");
                [[Api sharedApi] postPath:@"/logs/event"
                               parameters:@{@"event_name":@"cancelled_invite",
                                            @"invite_method":@"native",
                                            @"invite_channel":@"sms",
                                            @"source":@"home",
                                            @"recipients":[NSString stringWithFormat:@"%d",phoneNumbers.count]}
                                 callback:nil];
                break;

            case MessageComposeResultSent:
                if (completion) completion(YES);
                PNLOG(@"invite.sms.sent");
                [[Api sharedApi] postPath:@"/logs/event"
                               parameters:@{@"event_name":@"sent_invite",
                                            @"invite_method":@"native",
                                            @"invite_channel":@"sms",
                                            @"source":@"home",
                                            @"recipients":[NSString stringWithFormat:@"%d",phoneNumbers.count]}
                                 callback:nil];
                break;

            case MessageComposeResultFailed:
                PNLOG(@"invite.sms.failed");
                if (completion) completion(NO);
                break;
        }
    }];

    [[AppViewController sharedAppViewController] presentViewController:messageController
                                                              animated:YES
                                                            completion:nil];
}

@end
