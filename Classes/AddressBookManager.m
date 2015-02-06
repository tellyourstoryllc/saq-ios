//
//  AddressBookManager.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "AddressBookManager.h"

#import "PNUIAlertView.h"
#import "App.h"

@interface AddressBookManager()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, assign) NSUInteger itemCount;

@property (nonatomic, assign) BOOL authWasSkipped;
@property (nonatomic, assign) BOOL isAuthorized;

@property (nonatomic, strong) NSMutableArray* authCompletions;
@property (nonatomic, strong) NSMutableArray* syncCompletions;

@end

@implementation AddressBookManager

+(AddressBookManager*)manager {

    static AddressBookManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AddressBookManager new];
    });

    return manager;
}

-(id)init {
    self = [super init];
    if (self) {
        [self initializeFetchController];
    }
    return self;
}

-(void)initializeFetchController {
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"AddressBookPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"deleted = NO"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]];
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[App moc]
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
    self.fetchController.delegate = self;
    if(![self.fetchController performFetch:&error])
        NSLog(@"%@",error);

    NSLog(@"initailzed addess book fetch controller! %d", self.fetchController.fetchedObjects.count);
}

- (RHAddressBook*)rhAddressBook {
    _rhAddressBook = _rhAddressBook ?: [RHAddressBook new];
    return _rhAddressBook;
}

- (void)authorizeWithCompletion:(void (^)(BOOL authorized))completion {

    void (^completionBlock)(BOOL) = ^(BOOL auth) {
        if (completion)
            completion(auth);
    };

    NSString* permissionRequestTitle = @"Find Friends";
    NSString* permissionRequestMessage = @"Allowing contacts will make it easier to find friends.";

    RHAuthorizationStatus rhAuthStatus = [RHAddressBook authorizationStatus];
    if (rhAuthStatus == RHAuthorizationStatusNotDetermined) {

        // Wrap the iOS permission request with our own, since we only get one shot at it.
        if (!self.authWasSkipped) {
            PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:permissionRequestTitle
                                                                message:permissionRequestMessage
                                                         andButtonArray:@[@"Don't allow", @"OK"]];
            [alert showWithCompletion:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self.rhAddressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                        self.isAuthorized = granted;
                        if (granted) {
                            completionBlock(YES);
                        } else {
                            completionBlock(NO);
                        }
                    }];
                }
                else {
                    self.authWasSkipped = YES;
                    completionBlock(NO);
                }
            }];
        }
        else {
            completionBlock(NO);
        }
    }
    else if (rhAuthStatus == RHAuthorizationStatusAuthorized) {
        self.isAuthorized = YES;
        completionBlock(YES);
    }
    else if (rhAuthStatus == RHAuthorizationStatusDenied) {
        completionBlock(NO);
    }
    else
        completionBlock(NO);

}

- (void)clearCache {
    [AddressBookPerson deleteAll];
}

- (void)syncCacheWithCompletion:(void (^)(BOOL success))completion {

    __block NSSet* existingRecordIds = [NSSet setWithArray:[self.items valueForKey:@"id"]];

    [self authorizeWithCompletion:^(BOOL authorized) {

        void (^completionBlock)(BOOL) = ^(BOOL auth) {
            if (completion)
                completion(auth);
        };

        if (!authorized) {
            completionBlock(NO);
            return;
        }

        NSManagedObjectContext* moc = [App privateManagedObjectContext];

        NSArray* people = [[self.rhAddressBook peopleOrderedByUsersPreference] filteredArrayUsingBlock:^BOOL(RHPerson* person, NSDictionary *bindings) {
            return person.isPerson;
        }];

        NSArray* recordIdsAsNumbers = [people valueForKey:@"recordID"];
        NSArray* recordIdsAsStrings = [recordIdsAsNumbers mapUsingBlock:^id(id obj) {
            return [obj stringValue];
        }];

        NSSet* recordIds = [NSSet setWithArray:recordIdsAsStrings];

        // which records are no longer in address book?
        NSMutableSet* deletedRecordIds = [existingRecordIds mutableCopy];
        [deletedRecordIds minusSet:recordIds];

        NSArray* existingRecords = [AddressBookPerson findByIds:existingRecordIds.allObjects inContext:moc];
        NSMutableDictionary* existingRecordDict = [NSMutableDictionary dictionaryWithCapacity:existingRecordIds.count];
        for (AddressBookPerson* person in existingRecords) {
            existingRecordDict[person.id] = person;
        }

        NSDate* now = [NSDate date];
        for (RHPerson* rhPerson in people) {
            NSString* objId = [NSString stringWithFormat:@"%d", rhPerson.recordID];
            AddressBookPerson* local = existingRecordDict[objId] ?: [AddressBookPerson createWithId:objId inContext:moc];
            [local updateWithRHPerson:rhPerson];
            local.updated_at = now;
            local.deletedValue = NO;
        }

        NSArray* deletedRecords = [AddressBookPerson findByIds:[deletedRecordIds allObjects] inContext:moc];
        for (AddressBookPerson* deletedPerson in deletedRecords) {
            [deletedPerson delete];
        }

        [moc saveToRootWithCompletion:^(BOOL success, NSError *err) {
            completionBlock(success);
        }];
    }];
}

- (NSArray*)items {
    return self.fetchController.fetchedObjects;
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    self.itemCount = self.fetchController.fetchedObjects.count;
}

- (NSDictionary*)paramsForAutoconnect {
    NSMutableArray* hashedNumbers = [NSMutableArray new];
    NSMutableArray* hashedEmails = [NSMutableArray new];

    for (AddressBookPerson* person in self.fetchController.fetchedObjects) {
        NSArray* emails = [person.emails valueForKey:@"id"];
        [hashedEmails addObjectsFromArray:emails];

        NSArray* numbers = [person.phone_numbers valueForKey:@"id"];
        [hashedNumbers addObjectsFromArray:numbers];
    }

    return @{@"hashed_emails":[hashedEmails componentsJoinedByString:@","],
             @"hashed_phone_numbers":[hashedNumbers componentsJoinedByString:@","]};
}

@end
