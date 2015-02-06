//
//  Contact.h
//  groups
//
//  Created by Jim Young on 1/30/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

//  Not a "real" model. Just some stuff to manage contacts (which are just Users)

#import <Foundation/Foundation.h>
#import "User.h"

#define kDefaultContactRefreshInterval  3600
extern NSString *const kContactsDidRefreshNotification;

@interface Contact : User

+ (void)fetchOffset:(NSUInteger)offset
              limit:(NSUInteger)limit
      andCompletion:(void (^)(NSArray* contacts, NSError *error))completion;

+ (void)fetchAllWithTtl:(NSTimeInterval)ttl andCompletion:(void (^)(NSArray* contacts, NSError* error))completion;
+ (void)fetchAllWithCompletion:(void (^)(NSArray* contacts, NSError* error))completion;

+ (void)addUsers:(NSArray*)userArray withCompletion:(void (^)(NSArray* contacts, NSError* error))completion ;
+ (void)removeUsers:(NSArray*)userArray withCompletion:(void (^)(NSArray* contacts, NSError* error))completion ;
+ (void)addEmails:(NSArray*)emailArray withCompletion:(void (^)(NSArray* contacts, NSError* error))completion ;

// phoneDict is a dictionary of number:name
+ (void)addPhones:(NSDictionary*)phoneDict withCompletion:(void (^)(NSArray* contacts, NSError* error))completion ;

+ (void)addUser:(User*)user;
+ (void)removeUser:(User*)user;

+ (NSArray*)sortedLocalContacts;

@end
