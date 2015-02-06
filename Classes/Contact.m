//
//  Contact.m
//  groups
//
//  Created by Jim Young on 1/30/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "Contact.h"
#import "Api.h"
#import "App.h"
#import "Directory.h"

NSString *const kContactsDidRefreshNotification = @"ContactsDidRefreshNotification";

@implementation Contact

+ (void)fetchOffset:(NSUInteger)offset
              limit:(NSUInteger)limit
      andCompletion:(void (^)(NSArray* contacts, NSError *error))completion {
    [[Api sharedApi] postPath:@"/contacts"
                   parameters:@{@"limit":@(limit), @"offset":@(offset)}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                         for (User* user in users) {
                             [user.managedObjectContext performBlockAndWait:^{
                                 user.is_contactValue = YES;
                                 [user save];
                             }];
                         }
                         if (completion) completion(users,error);
                     }];
}

+ (void)__fetchintoArray:(NSMutableArray*)accumulator
              fromOffset:(NSUInteger) offset
           andCompletion:(void (^)(NSArray* contacts, NSError* error))completion {
    [self fetchOffset:offset limit:50 andCompletion:^(NSArray *contacts, NSError *error) {
        [accumulator addObjectsFromArray:contacts];
        if (!error && contacts.count >= 50) {
            [self __fetchintoArray:accumulator fromOffset:offset+50 andCompletion:completion];
        }
        else {
            if (completion) completion(accumulator, error);
        }
    }];
}

+ (void)fetchAllWithTtl:(NSTimeInterval)ttl andCompletion:(void (^)(NSArray* contacts, NSError* error))completion {
    static NSDate* lastRefresh;
    NSDate* storedRefresh = lastRefresh;

    if ([User me]) {
        void (^myCompletion)(NSArray*, NSError*) = ^void(NSArray* contacts, NSError* error) {
            if (completion) completion(contacts, error);
            if (error) lastRefresh = storedRefresh;
            [[NSNotificationCenter defaultCenter] postNotificationName:kContactsDidRefreshNotification object:nil];
        };

        if (!lastRefresh || [lastRefresh timeIntervalSinceNow] < -1*ttl) {
            lastRefresh = [NSDate date];
            NSMutableArray* allContacts = [NSMutableArray arrayWithCapacity:10];

            [self __fetchintoArray:allContacts fromOffset:0 andCompletion:myCompletion];
        }
        else if (completion) {
            NSArray* contacts = [User findAllUsingPredicate:[NSPredicate predicateWithFormat:@"is_contact == YES"] sortedBy:nil];
            completion(contacts, nil);
        }
    }
    else if (completion) {
        completion(nil, [NSError errorWithDomain:@"peanut" code:404 userInfo:nil]);
    }
}

+ (void)fetchAllWithCompletion:(void (^)(NSArray* contacts, NSError* error))completion {
    [self fetchAllWithTtl:kDefaultContactRefreshInterval andCompletion:completion];
}

+ (NSArray*)sortedLocalContacts {
    return [User findAllUsingPredicate:[NSPredicate predicateWithFormat:@"is_contact == YES AND (username != NULL OR address_book_name != NULL)"]
                              sortedBy:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
}

+ (void)addUsers:(NSArray*)userArray
  withCompletion:(void (^)(NSArray* contacts, NSError* error))completion {

    NSArray* userIds = [userArray mapUsingBlock:^id(id obj) { return [(User*)obj id]; }];

    [[Api sharedApi] postPath:@"/contacts/add"
                   parameters:@{@"user_ids":[userIds componentsJoinedByString:@","]}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {

                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                         for (User* user in users) {
                             user.is_contactValue = YES;
                             [user save];
                             [[Directory shared] addItem:[DirectoryItem itemForUser:user]];
                         }

                         // update original user params, just in case..
                         for (User* user in userArray) {
                             user.is_contactValue = YES;
                         }

                         if (completion) completion(users, error);
                     }];
}

+ (void)removeUsers:(NSArray*)userArray
  withCompletion:(void (^)(NSArray* contacts, NSError* error))completion {

    NSArray* userIds = [userArray mapUsingBlock:^id(id obj) { return [(User*)obj id]; }];

    [[Api sharedApi] postPath:@"/contacts/remove"
                   parameters:@{@"user_ids":[userIds componentsJoinedByString:@","]}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSArray* users = [User findByIds:[userArray valueForKey:@"id"] inContext:[App moc]];
                         for (User* user in users) {
                             user.is_contactValue = NO;
                             [user save];
                             [[Directory shared] removeItem:[DirectoryItem itemForUser:user]];
                         }
                         if (completion) completion(userArray, error);
                     }];
}

+ (void)addEmails:(NSArray*)emailArray
   withCompletion:(void (^)(NSArray* contacts, NSError* error))completion {
    [[Api sharedApi] postPath:@"/contacts/add"
                   parameters:@{@"emails":[emailArray componentsJoinedByString:@","]}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                         for (User* user in users) {
                             user.is_contactValue = YES;
                             [user save];
                             [[Directory shared] addItem:[DirectoryItem itemForUser:user]];
                         }
                         if (completion) completion(users, error);
                     }];
}

// phoneDict is a dictionary of number:name
+ (void)addPhones:(NSDictionary*)phoneDict
   withCompletion:(void (^)(NSArray* contacts, NSError* error))completion {
    NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:phoneDict.count];
    NSMutableArray* names = [NSMutableArray arrayWithCapacity:phoneDict.count];

    [phoneDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [numbers addObject:key];
        [names addObject:obj];
    }];

    [[Api sharedApi] postPath:@"/contacts/add"
                   parameters:@{@"phone_numbers":[numbers componentsJoinedByString:@","],
                                @"phone_names":[names componentsJoinedByString:@","]}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSArray* users = [[entities setOfClass:[User class]] allObjects];
                         for (User* user in users) {
                             user.is_contactValue = YES;
                             [user save];
                             [[Directory shared] addItem:[DirectoryItem itemForUser:user]];
                         }
                         if (completion) completion(users, error);
                     }];
}

+ (void)addUser:(User*)user {
    [self addUsers:@[user] withCompletion:nil];
}

+ (void)removeUser:(User*)user {
    [self removeUsers:@[user] withCompletion:nil];
}

@end
