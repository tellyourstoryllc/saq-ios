//
//  Directory.h
//  groups
//
//  Created by Jim Young on 2/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

// The Directory is a combination of a users contacts (stored on the API), people in the same room, and people stored in
// the device's address book.

#import <Foundation/Foundation.h>
#import "User.h"
#import "Contact.h"
#import "RHAddressBook.h"
#import "RHPerson.h"

@class Directory;

extern NSString *const DirectoryDidStartUpdatingNotification;
extern NSString *const DirectoryDidUpdateNotification;
extern NSString *const DirectoryDidFinishUpdatingNotification;

@interface DirectoryItem : NSObject<NSCopying>

@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Group* group;
@property (nonatomic, strong) RHPerson* person;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* altName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* phoneNumber;

@property (nonatomic, strong) NSNumber* rank;

+ (instancetype)itemForUser:(User*)user;
+ (instancetype)itemForGroup:(Group*)group;
+ (instancetype)itemforRHPerson:(RHPerson*)person;

- (BOOL)hasImage;
- (void)fetchImageWithCompletion:(void (^)(UIImage* image))completion;

@end

typedef enum {
    DirectoryStatusUnpopulated = 0,
    DirectoryStatusIsPopulating,
    DirectoryStatusLocalPopulated,
    DirectoryStatusFullyPopulated,
} DirectoryStatus;

@interface Directory : NSObject

@property (nonatomic, readonly) NSMutableArray* items;
@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, assign) DirectoryStatus status;
@property (nonatomic, assign) BOOL authWasSkipped;
@property dispatch_queue_t dirQueue;

+ (instancetype)shared;

- (void)authorizeAddressBookWithCompletion:(void (^)(RHAddressBook* addressBook, BOOL authorized))completion;

- (void)populateUsingAddressBook:(BOOL)withAddressBook
                      completion:(void (^)(NSArray* directoryItems, BOOL authorized))completion;
- (void)populateWithCompletion:(void (^)(NSArray* directoryItems, BOOL authorized))completion;
- (void)prepopulate;

- (void)updateContactsWithCompletion:(void (^)(NSArray* directoryItems, NSArray* contactItems))completion;
- (void)autoconnectWithCompletion:(void (^)(NSSet* users, NSError* error))completion;

- (void)addItem:(DirectoryItem*)item;
- (void)removeItem:(DirectoryItem*)item;
@end
