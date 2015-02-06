//
//  Directory.m
//  groups
//
//  Created by Jim Young on 2/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "Directory.h"
#import "PNUIAlertView.h"
#import "UIImage+Utility.h"
#import "NSString+SHA256.h"
#import "NSString+Email.h"
#import "NSString+PhoneNumber.h"

#import "App.h"
#import "Api.h"

NSString *const DirectoryDidStartUpdatingNotification = @"DirectoryDidStartUpdatingNotification";
NSString *const DirectoryDidUpdateNotification = @"DirectoryDidUpdateNotification";
NSString* const DirectoryDidFinishUpdatingNotification = @"DirectoryDidFinishUpdatingNotification";

@interface DirectoryItem()

+ (instancetype)itemForUser:(User*)user;
+ (instancetype)itemForGroup:(Group*)group;
+ (instancetype)itemforRHPerson:(RHPerson*)person;

- (void) linkToHashedUsersUsingMoc:(NSManagedObjectContext*)moc;

@end

@interface Directory() {
    NSArray* _contactItems;
    NSArray* _addressBookItems;
}

@property (nonatomic, strong) NSManagedObjectContext* moc;
@property (nonatomic, strong) RHAddressBook* addressBook;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, assign) BOOL isAuthorized;
@property (nonatomic, assign) BOOL shouldRetryAuth;

@end

@implementation Directory

@synthesize dirQueue = _dirQueue;

+ (instancetype)shared {
    static id sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearItems) name:kWillClearDataNotification object:nil];
        _dirQueue = dispatch_queue_create("com.perceptualnet.directory", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)prepopulate {
    on_background(^{
        RHAuthorizationStatus rhAuthStatus = [RHAddressBook authorizationStatus];
        if (rhAuthStatus != RHAuthorizationStatusNotDetermined) {
            [self populateUsingAddressBook:NO completion:nil];
        }
    });
}

- (void)authorizeAddressBookWithCompletion:(void (^)(RHAddressBook* addressBook, BOOL authorized))completion {

    void (^completionBlock)(RHAddressBook*, BOOL) = ^(RHAddressBook* ab, BOOL auth) {
        if (completion)
            completion(ab, auth);
    };

    NSString* permissionRequestTitle = @"Find Friends";
    NSString* permissionRequestMessage = @"Allowing contacts will make it easier to find friends.";

    RHAuthorizationStatus rhAuthStatus = [RHAddressBook authorizationStatus];
    if (rhAuthStatus == RHAuthorizationStatusNotDetermined) {
        self.addressBook = [[RHAddressBook alloc] init];

        // Wrap the iOS permission request with our own, since we only get one shot at it.
        if (!self.authWasSkipped) {
            PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:permissionRequestTitle
                                                                message:permissionRequestMessage
                                                         andButtonArray:@[@"Don't allow", @"OK"]];
            [alert showWithCompletion:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self.addressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                        self.isAuthorized = granted;
                        if (granted) {
                            completionBlock(self.addressBook, YES);
                        } else {
                            completionBlock(nil, NO);
                        }
                    }];
                }
                else {
                    self.authWasSkipped = YES;
                    completionBlock(nil, NO);
                }
            }];
        }
        else {
            completionBlock(nil, NO);
        }
    }
    else if (rhAuthStatus == RHAuthorizationStatusAuthorized) {
        self.addressBook = [[RHAddressBook alloc] init];
        self.isAuthorized = YES;
        completionBlock(self.addressBook, YES);
    }
    else if (rhAuthStatus == RHAuthorizationStatusDenied) {
        completionBlock(nil, NO);
    }
    else
        completionBlock(nil, NO);

}

- (void)autoconnectWithCompletion:(void (^)(NSSet* users, NSError* error))completion {
    if (self.addressBook) {
        NSArray* peeps = [self.addressBook people];

        NSMutableArray* emailHashes = [NSMutableArray arrayWithCapacity:peeps.count];
        NSMutableArray* phoneHashes = [NSMutableArray arrayWithCapacity:peeps.count];

        for (RHPerson* person in peeps) {
            for (NSString* email in person.emails.values) {
                if (email.hasEmail) [emailHashes addObject:[email.normalizedEmail sha256]];
            }
            for (NSString* number in person.phoneNumbers.values) {
                if (number.isPhoneNumber) [phoneHashes addObject:[number.normalizedPhoneNumber sha256]];
            }
        }

        [[Api sharedApi] postPath:@"/contacts/autoconnect"
                       parameters:@{@"hashed_emails":[emailHashes componentsJoinedByString:@","],
                                    @"hashed_phone_numbers":[phoneHashes componentsJoinedByString:@","]}
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             NSSet* users = [entities setOfClass:[User class]];
                             if (users.count || !self.items.count) {
                                 [self populateWithCompletion:^(NSArray *directoryItems, BOOL authorized) {
                                     if (completion) completion(users, error);
                                 }];
                             }
                             else {
                                 if (completion) completion(users, error);
                             }
                         }];
    }
    else {
        if (completion) completion(nil, [NSError errorWithDomain:@"peanut" code:401 userInfo:nil]);
    }
}

- (void)__populateItemsOnLocal:(void (^)())localBlock
                     andRemote:(void (^)())remoteBlock {

    self.moc = self.moc ?: [App managedObjectContext];

    self.status = DirectoryStatusIsPopulating;
    [[NSNotificationCenter defaultCenter] postNotificationName:DirectoryDidStartUpdatingNotification
                                                        object:self];

    NSMutableArray* newItems = [NSMutableArray arrayWithCapacity:12];

    if (self.addressBook) {

        NSMutableArray* newABItems = [NSMutableArray arrayWithCapacity:1000];

        int hashedCount = [[HashedEmail findAllUsingPredicate:nil inContext:self.moc] count] +
        [[HashedNumber findAllUsingPredicate:nil inContext:self.moc] count];

        for (RHPerson* person in [self.addressBook peopleOrderedByUsersPreference]) {
            DirectoryItem* item = [DirectoryItem itemforRHPerson:person];
            if (hashedCount) [item linkToHashedUsersUsingMoc:self.moc];

            if (item.name && (item.phoneNumber || item.email)) {
                [newItems addObject:item];
                [newABItems addObject:item];
            }
        }

        _addressBookItems = newABItems;
    }

    NSArray* validUsers;
    if ([User me])
        validUsers = [User findAllUsingPredicate:[NSPredicate predicateWithFormat:@"(is_contact == YES OR has_one_to_one == YES) AND id != %@", [[User me]id]] inContext:self.moc];
    else
        validUsers = @[];

    [newItems addObjectsFromArray:[validUsers mapUsingBlock:^id(id obj) {
        return [DirectoryItem itemForUser:obj];
    }]];

    [_items removeAllObjects];

    // Dedupe. Requires the "hash" method of DirectoryItem to be defined correctly.
    [_items addObjectsFromArray:[[NSSet setWithArray:newItems] allObjects]];

    [self sortItems];

    [[NSNotificationCenter defaultCenter] postNotificationName:DirectoryDidUpdateNotification
                                                        object:self];
    self.status = DirectoryStatusLocalPopulated;
    if (localBlock) localBlock();

    [Contact fetchAllWithCompletion:^(NSArray *contacts, NSError *error) {

        on_background(^{
            NSMutableArray* itemsCopy = [_items mutableCopy];

            // Merge existing items (from address book) to new users via hash
            for (DirectoryItem* item in itemsCopy) {
                [item linkToHashedUsersUsingMoc:self.moc];
            }

            NSMutableArray* newContactItems = [NSMutableArray arrayWithCapacity:contacts.count];
            for (User* user in contacts) {
                DirectoryItem* item = [DirectoryItem itemForUser:user];
                [newContactItems addObject:item];
                if (item && ![itemsCopy containsObject:item]) {
                    [itemsCopy addObject:item];
                }
            }

            _contactItems = newContactItems;

            // Filter out shell users
            NSMutableArray* shellItems = [NSMutableArray arrayWithCapacity:4];
            for (DirectoryItem* item in itemsCopy) {
                if (item.user && !item.user.username) [shellItems addObject:item];
            }

            [itemsCopy removeObjectsInArray:shellItems];
            _items = itemsCopy;
            [self sortItems];

            self.status = DirectoryStatusFullyPopulated;

            [[NSNotificationCenter defaultCenter] postNotificationName:DirectoryDidUpdateNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:DirectoryDidFinishUpdatingNotification object:self];
            if (remoteBlock) remoteBlock();
        });
    }];
}

- (void) sortItems {
    [_items sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DirectoryItem* item1 = (DirectoryItem*) obj1;
        DirectoryItem* item2 = (DirectoryItem*) obj2;
        NSComparisonResult rankSort = [item2.rank compare:item1.rank];
        if (rankSort == NSOrderedSame)
            return [item1.name caseInsensitiveCompare:item2.name];
        else
            return rankSort;
    }];
}

- (void)populateWithCompletion:(void (^)(NSArray* directoryItems, BOOL authorized))completion {
    [self populateUsingAddressBook:YES completion:completion];
}

- (void)populateUsingAddressBook:(BOOL)withAddressBook
                      completion:(void (^)(NSArray* directoryItems, BOOL authorized))completion {

    static dispatch_semaphore_t sema;
    if (!sema) sema = dispatch_semaphore_create(0);

    if (!_items || (withAddressBook && !_addressBookItems) || _shouldRetryAuth) {
        _items = [NSMutableArray arrayWithCapacity:1000];
        _shouldRetryAuth = NO;

        if (withAddressBook) {
            [self authorizeAddressBookWithCompletion:^(RHAddressBook *addressBook, BOOL authorized) {
                dispatch_async(_dirQueue, ^{
                    [self __populateItemsOnLocal:^{
                        dispatch_semaphore_signal(sema);
                        if (completion) completion([_items copy], authorized);
                    } andRemote:^{
                        if (!authorized) _shouldRetryAuth = YES; // <-- reset so we can take another shot at auth again later.
                    }];
                });
            }];
        }
        else {
            dispatch_async(_dirQueue, ^{
                [self __populateItemsOnLocal:^{
                    dispatch_semaphore_signal(sema);
                    if (completion) completion([_items copy], YES);
                } andRemote:nil];
            });
        }

    }
    else if (completion) {
        if (self.status == DirectoryStatusLocalPopulated || self.status == DirectoryStatusFullyPopulated) {
            RHAuthorizationStatus rhAuthStatus = [RHAddressBook authorizationStatus];
            BOOL authd = (rhAuthStatus == RHAuthorizationStatusAuthorized) || !withAddressBook;
            completion([_items copy],authd);
        }
        else {  // still populating. wait before calling completion
            dispatch_async(_dirQueue, ^{
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                RHAuthorizationStatus rhAuthStatus = [RHAddressBook authorizationStatus];
                BOOL authd = (rhAuthStatus == RHAuthorizationStatusAuthorized) || !withAddressBook;
                completion([_items copy],authd);
                dispatch_semaphore_signal(sema);
            });
        }
    }
}

- (void) updateContactsWithCompletion:(void (^)(NSArray* directoryItems, NSArray* contactItems))completion {
    dispatch_async(_dirQueue, ^{

        if (!_items) {
            if (completion) completion(nil,nil);
            return;
        }

        [Contact fetchAllWithTtl:5 andCompletion:^(NSArray *contacts, NSError *error) {
            on_background(^{
                NSManagedObjectContext* moc = [App privateManagedObjectContext];
                [_items removeObjectsInArray:_contactItems];
                NSMutableArray* itemsCopy = [_items mutableCopy];
                for (DirectoryItem* item in itemsCopy) {
                    [item linkToHashedUsersUsingMoc:moc];
                }

                NSMutableArray* newContactItems = [NSMutableArray arrayWithCapacity:contacts.count];
                for (User* user in contacts) {
                    DirectoryItem* item = [DirectoryItem itemForUser:user];
                    [newContactItems addObject:item];
                    if (item && ![itemsCopy containsObject:item]) {
                        [itemsCopy addObject:item];
                    }
                }

                _contactItems = newContactItems;

                // Filter out shell users
                NSMutableArray* shellItems = [NSMutableArray arrayWithCapacity:4];
                for (DirectoryItem* item in itemsCopy) {
                    if (item.user && !item.user.username) [shellItems addObject:item];
                }

                [itemsCopy removeObjectsInArray:shellItems];
                _items = itemsCopy;
                [self sortItems];

                if (completion) completion(_items, _contactItems);
            });
        }];
    });
}

- (void)addItem:(DirectoryItem*)item {
    if (![_items containsObject:item]) {
        [_items addObject:item];
        [self sortItems];
    }
}

- (void)removeItem:(DirectoryItem*)item {
    [_items removeObject:item];
}

- (void)clearItems {
    _items = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation DirectoryItem

+ (instancetype)itemforRHPerson:(RHPerson*)person {
    DirectoryItem* item = [[DirectoryItem alloc] init];

    item.person = person;
    item.email = [person.emails valueAtIndex:0];
    item.phoneNumber = [person.phoneNumbers valueAtIndex:0];

    item.name = person.compositeName;
    item.name = item.name ?: person.emails.values.firstObject;
    item.name = item.name ?: person.phoneNumbers.values.firstObject;

    return item;
}

+ (instancetype)itemForUser:(User*)user {
    DirectoryItem* item = [[DirectoryItem alloc] init];
    item.user = user;
    return item;
}

+ (instancetype)itemForGroup:(Group*)group {
    if ([group isOneToOneValue]) {
        return [self itemForUser:group.other_user];
    }
    else {
        DirectoryItem* item = [[DirectoryItem alloc] init];
        item.group = group;
        return item;
    }
}

- (BOOL)hasImage {
    if (self.person.hasImage) return YES;
    if (self.user.avatar_url) return YES;
    if (self.group.avatar_url) return YES;
    return NO;
}

- (NSNumber*)rank {
    return _rank ?: @(0);
}

- (void)setUser:(User *)user {
    _user = user;
    int rank = 0;
    if (self.user.is_communicatingValue) rank++;
    if (user.isMe) rank++;
    if ([user is_contactValue]) rank++;
    rank = rank + user.priorityValue;
    self.rank = @(rank);
    self.name = user.displayName;
    self.altName = user.alternateName;
}

- (void)setGroup:(Group *)group {
    _group = group;
    int rank = 0;
    self.rank = @(rank);
    self.name = group.displayName;
    if (group.isOneToOneValue)
        self.user = group.other_user;
}

- (void)setPerson:(RHPerson *)person {
    _person = person;
    self.rank = @(0);
}

- (void)fetchImageWithCompletion:(void (^)(UIImage* image))completion {
    if (self.person.thumbnail) {
        completion(self.person.thumbnail);
        return;
    }

    if (self.user.avatar_url) {
        [UIImage fetchFromUrlString:self.user.avatar_url withCompletion:^(UIImage *image) {
            completion(image);
        }];
    }
}

- (BOOL) isEqual:(id)object {
    if ([object isKindOfClass:[DirectoryItem class]]) {
        DirectoryItem* otherItem = (DirectoryItem*)object;
        if (self.user && self.user == otherItem.user) return YES;
        if (self.user.id && [otherItem.user.id isEqualToString:self.user.id]) return YES;
    }
    return [super isEqual:object];
}

- (NSUInteger) hash {
    return self.user ? self.user.username.hash : [super hash];
}

- (void) linkToHashedUsersUsingMoc:(NSManagedObjectContext*)moc {

    if (self.person) {

        // Use hashed phone numbers and emails to link to User.
        NSArray* hashedEmails = [self.person.emails.values mapUsingBlock:^id(id obj) {
            return [[(NSString*)obj normalizedEmail] sha256];
        }];

        for (id hash in hashedEmails) {
            if ([NSNull null] == hash) continue;
            HashedEmail* target = [[HashedEmail findByIds:@[hash] inContext:moc] firstObject];
            if (target) {
                target.user.address_book_name = self.person.compositeName;
                self.user = target.user;
                [target.user save];
                return;
            }
        }

        NSArray* hashedNumbers = [self.person.phoneNumbers.values mapUsingBlock:^id(id obj) {
            return [[(NSString*)obj normalizedPhoneNumber] sha256];
        }];

        for (id hash in hashedNumbers) {
            if ([NSNull null] == hash) continue;
            HashedNumber* target = [[HashedNumber findByIds:@[hash] inContext:moc] firstObject];
            if (target) {
                target.user.address_book_name = self.person.compositeName;
                self.user = target.user;
                [target.user save];
                return;
            }
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    DirectoryItem* copy = [[[self class] alloc] init];

    if (copy) {
        [copy setUser:self.user];
        [copy setGroup:self.group];
        [copy setPerson:self.person];
        [copy setName:self.name];
        [copy setAltName:self.altName];
        [copy setEmail:self.email];
        [copy setPhoneNumber:self.phoneNumber];
        [copy setRank:self.rank];
    }

    return copy;
}

@end
