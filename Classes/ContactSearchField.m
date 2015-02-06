//
//  ContactSearchField.m
//  FFM
//
//  Created by Jim Young on 4/19/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ContactSearchField.h"
#import "Api.h"
#import "PNTableCell.h"
#import "AlertView.h"
#import "StatusView.h"
#import "UserAvatarView.h"
#import "NSString+Levenshtein.h"
#import "PNView.h"

//=============================================================================================================================================================
#pragma mark Contact search results table cell

@interface ContactSearchTableViewCell : PNTableCell
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) DirectoryItem* directoryItem;
@property (nonatomic, strong) PNLabel* nameLabel;
@property (nonatomic, strong) PNLabel* secondaryLabel;
@property (nonatomic, strong) PNButton* addButton;
@property (nonatomic, strong) UserAvatarView* avatar;
@property (nonatomic, assign) BOOL added;
@end

@implementation ContactSearchTableViewCell

- (void)commonInit {

    self.backgroundColor = COLOR(defaultBackgroundColor);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.avatar = [[UserAvatarView alloc] initWithFrame:CGRectMake(6,5,40,40)];
    [self addChild:self.avatar];

    self.nameLabel = [[PNLabel alloc] init];
    self.nameLabel.font = USERFONT(18);
    self.nameLabel.textColor = COLOR(darkGrayColor);
    [self addChild:self.nameLabel];

    self.secondaryLabel = [[PNLabel alloc] init];
    self.secondaryLabel.font = FONT(12);
    self.secondaryLabel.textColor = COLOR(grayColor);
    [self addChild:self.secondaryLabel];

    self.addButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.addButton.buttonColor = [UIColor clearColor];
    [self.addButton setBorderWithColor:COLOR(whiteColor) width:2];
    self.addButton.cornerRadius = 20;
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self addChild:self.addButton];
    self.addButton.userInteractionEnabled = NO;

}

- (void)setDirectoryItem:(DirectoryItem *)directoryItem {
    self.nameLabel.text = directoryItem.name;
    self.nameLabel.frame = CGRectZero;
    self.avatar.user = directoryItem.user;

    if (directoryItem.person)
        self.secondaryLabel.text = directoryItem.user.username ?: directoryItem.phoneNumber ?: directoryItem.email;
    else
        self.secondaryLabel.text = directoryItem.phoneNumber ?: directoryItem.email;

    if (!self.avatar.user && directoryItem.person) {
        if (directoryItem.person.hasImage)
            self.avatar.image = directoryItem.person.thumbnail;
    }

    self.addButton.hidden = directoryItem.user.is_contactValue || directoryItem.user.isMe;

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.addButton.frame = CGRectSetTopRight(self.frame.size.width-10, 5, self.addButton.frame);

    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.avatar.frame)+5, CGRectGetMidY(self.addButton.frame), self.nameLabel.frame);

    self.secondaryLabel.frame = CGRectMakeCorners(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), CGRectGetMinX(self.addButton.frame), self.bounds.size.height);

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

//=============================================================================================================================================================
#pragma mark Contact search results table

@interface ContactSearchResultsTableController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray* manualItems;
@property (nonatomic, strong) NSArray* apiItems;
@property (nonatomic, strong) NSArray* directoryItems;
@property (nonatomic, strong) UITableView* table;

@end

@implementation ContactSearchResultsTableController

- (id)init
{
    self = [super init];
    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.table.dataSource = self;
    self.table.backgroundColor = COLOR(defaultBackgroundColor);
    self.table.backgroundView = nil;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
    return self;
}

// Sections:
// 0 - phone number / emails
// 1 - username search results
// 2 - directory results

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.manualItems.count;
        case 1:
            return self.apiItems.count;
        default:
            return self.directoryItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactSearchTableViewCell* cell = [self.table dequeueReusableCellWithIdentifier:@"ContactSearchTableViewCell"] ?: [[ContactSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactSearchTableViewCell"];

    if (indexPath.section == 0 && self.manualItems.count > indexPath.row) {
        cell.directoryItem = [self.manualItems objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1 && self.apiItems.count > indexPath.row) {
        cell.directoryItem = [self.apiItems objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2 && self.directoryItems.count > indexPath.row) {
        cell.directoryItem = [self.directoryItems objectAtIndex:indexPath.row];
    }
    return cell;
}

@end

//=============================================================================================================================================================
#pragma mark Contact search text field

@class ContactSearchFieldDelegate;

@interface ContactSearchField()<UITableViewDelegate>

@property (nonatomic, strong) ContactSearchResultsTableController* tableController;

@property (nonatomic, strong) NSOperationQueue* operationQueue;

@property (nonatomic, strong) NSTimer* apiSearchTimer;
@property (nonatomic, strong) NSMutableArray* apiSearchResultItems; // An array of directory items
@property (nonatomic, strong) NSOperation* nextApiSearchOperation;

@property (nonatomic, strong) NSOperation* nextDirSearchOperation;
@property (nonatomic, strong) NSTimer* directorySearchTimer;
@property (nonatomic, strong) NSMutableArray* directorySearchResultItems; // An array of directory items

@property (nonatomic, assign) BOOL showSearchStatus;
@property (nonatomic, assign) Directory* directory;

@property (nonatomic, strong) ContactSearchFieldDelegate* textDelegate;

- (void)scheduleDirectorySearch:(NSString*)name afterDelay:(NSTimeInterval)delay;
- (void)scheduleApiSearch:(NSString*)name showEmptyResult:(BOOL)showEmptyResult afterDelay:(NSTimeInterval)delay;
- (void)clearResults;

@end

//=============================================================================================================================================================
#pragma mark Contact search text field

@interface ContactSearchFieldDelegate : NSObject <UITextFieldDelegate>
@property (nonatomic, assign) ContactSearchField* searchField;
@end

@implementation ContactSearchFieldDelegate

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL possibleUsername = YES;
    NSMutableString* newString = [textField.text mutableCopy];
    [newString replaceCharactersInRange:range
                             withString:string];

    if (string.length == 0) { // Backspace.
    }

    if ([newString isMatchedByRegex:@"[\\s]"]) { // Whitespace
        possibleUsername = NO;
    }

    if (newString.length == 0) {
        [self.searchField clearResults];
    }
    else
        [self.searchField scheduleDirectorySearch:newString afterDelay:0.2];

    if (newString.length ) [self.searchField scheduleApiSearch:newString showEmptyResult:NO afterDelay:0.7];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField scheduleApiSearch:textField.text showEmptyResult:YES afterDelay:0];
    return NO;
}

@end

@implementation ContactSearchField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableController = [[ContactSearchResultsTableController alloc] init];
        self.tableController.table.delegate = self;
        self.textDelegate = [[ContactSearchFieldDelegate alloc] init];
        self.textDelegate.searchField = self;
        self.delegate = self.textDelegate;
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (UITableView*)searchResultsTable {
    return self.tableController.table;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!self.directory)
        self.directory = [Directory shared];
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        id item = [self.tableController.manualItems objectAtIndex:indexPath.row];
        if ([self.searchDelegate respondsToSelector:@selector(contactSearch:didSelect:)])
            [self.searchDelegate contactSearch:self didSelect:item];
    }
    else if (indexPath.section == 1){
        id item = [self.tableController.apiItems objectAtIndex:indexPath.row];
        if ([self.searchDelegate respondsToSelector:@selector(contactSearch:didSelect:)])
            [self.searchDelegate contactSearch:self didSelect:item];
    }
    else if (indexPath.section == 2){
        id item = [self.tableController.directoryItems objectAtIndex:indexPath.row];
        if ([self.searchDelegate respondsToSelector:@selector(contactSearch:didSelect:)])
            [self.searchDelegate contactSearch:self didSelect:item];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.text.length == 0 && section == 0) {
        PNView* view = [[PNView alloc] init];
        view.paddingX = 8;
        view.paddingY = 4;
        NSString* text = [Configuration stringFor:@"add_contact_text"] ?: [NSString stringWithFormat:@"Invite & add friends to %@ by entering their username, phone number, or email address.", kAppTitle];
        PNLabel* label = [PNLabel labelWithText:text andFont:FONT_BI(18)];
        [label sizeToFitTextWidth:tableView.bounds.size.width - 10];
        [view addChild:label];
        [view sizeToFit];
        return view;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 && self.text.length == 0) ? 30 : 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.text.length)
        [self endEditing:YES];
    else if ([self.searchDelegate respondsToSelector:@selector(contactSearchDidCancel:)])
        [self.searchDelegate contactSearchDidCancel:self];
}

- (void)clearResults {
    self.text = nil;
    self.tableController.directoryItems = @[];
    self.tableController.apiItems = @[];
    [self.operationQueue cancelAllOperations];
    on_main(^{
        [self.tableController.table reloadData];
    });
}

//

- (void)scheduleDirectorySearch:(NSString*)name afterDelay:(NSTimeInterval)delay {

    [self.directory populateWithCompletion:^(NSArray *directoryItems, BOOL authorized) {
        [self.operationQueue cancelAllOperations];

        NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithCapacity:100];

        NSOperation* op = [NSBlockOperation blockOperationWithBlock:^{
            for (DirectoryItem* item in directoryItems) {

                float lev = [name.lowercaseString asciiLevenshteinDistanceWithString:[item.name.lowercaseString substringToIndex:MIN(item.name.length-1, name.length+1)]];
                if (lev < 2) {
                    [resultDict setObject:[NSNumber numberWithFloat:lev/item.name.length] forKey:item];
                    continue;
                }

                lev = [name.lowercaseString asciiLevenshteinDistanceWithString:[item.person.lastName.lowercaseString substringToIndex:MIN(item.person.lastName.length-1, name.length+1)]];
                if (lev < 2) {
                    [resultDict setObject:[NSNumber numberWithFloat:lev/item.person.lastName.length] forKey:item];
                    continue;
                }

                if (([item.email isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", name]]) ||
                    ([item.phoneNumber isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", name]])) {
                    [resultDict setObject:[NSNumber numberWithFloat:0.0] forKey:item];
                }
            }

            NSMutableArray* sortedItemArray = [[resultDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [(NSNumber*)obj2 compare:(NSNumber*)obj1];
            }] mutableCopy];

            if ([name hasEmail]) {
                DirectoryItem* item = [[DirectoryItem alloc] init];
                item.name = name;
                item.email = name;
                [sortedItemArray insertObject:item atIndex:0];
            }

            if ([name isPhoneNumber]) {
                DirectoryItem* item = [[DirectoryItem alloc] init];
                item.name = name;
                item.phoneNumber = name;
                [sortedItemArray insertObject:item atIndex:0];
            }

            self.tableController.directoryItems = sortedItemArray;
            on_main(^{
                [self.tableController.table reloadData];
            });
        }];

        [self.operationQueue addOperation:op];
    }];
}

- (void)scheduleApiSearch:(NSString*)name showEmptyResult:(BOOL)showEmptyResult afterDelay:(NSTimeInterval)delay {

    [self.apiSearchTimer invalidate];

    NSString *regex = @"^[a-zA-Z0-9\\-]{2,16}$";
    NSString *atLeastOneLetterRegex = @"[a-zA-Z]";
    if ([name isMatchedByRegex:regex] && [name isMatchedByRegex:atLeastOneLetterRegex]) {
        self.showSearchStatus = showEmptyResult;

        self.nextApiSearchOperation =
        [[Api sharedApi] operationWithHTTPMethod:@"POST"
                                            path:@"/users"
                                      parameters:@{@"usernames":name}
                                     andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {

                                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                                         NSArray* userItems = [users mapUsingBlock:^id(id obj) {
                                             return [DirectoryItem itemForUser:obj];
                                         }];

                                         self.tableController.apiItems = userItems;

                                         if (userItems.count)
                                             [self.tableController.table setContentOffset:CGPointMake(0, 0) animated:YES];

                                         if (self.showSearchStatus) {
                                             self.showSearchStatus = NO;
                                             if (!userItems.count)
                                                 [StatusView showTitle:nil
                                                               message:[NSString stringWithFormat:@"Could not find any users matching “%@”", name]
                                                            completion:nil duration:2.0];
                                             else if (users.count == 1) {
                                                 DirectoryItem* item = [DirectoryItem itemForUser:users.lastObject];
                                                 if ([self.searchDelegate respondsToSelector:@selector(contactSearch:didSelect:)])
                                                     [self.searchDelegate contactSearch:self didSelect:item];
                                             }
                                         }

                                         on_main(^{
                                             [self.tableController.table reloadData];
                                         });
                                     }
         ];
        self.apiSearchTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(executeSearch) userInfo:nil repeats:NO];
    }
}

- (void)executeSearch {
    if (self.nextApiSearchOperation) {
        [self.operationQueue addOperation:self.nextApiSearchOperation];
        self.nextApiSearchOperation = nil;
    }
}

@end
