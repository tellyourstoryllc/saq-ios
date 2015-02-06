//
//  AddressBookManager.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/10/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHAddressBook.h"
#import "RHPerson.h"
#import "AddressBookPerson.h"

@interface AddressBookManager : NSObject

@property (nonatomic, readonly) NSUInteger itemCount;
@property (nonatomic, readonly) NSArray* items;  // An array of AddressBookPerson
@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, strong) RHAddressBook* rhAddressBook;

+ (AddressBookManager*) manager;

- (void)authorizeWithCompletion:(void (^)(BOOL authorized))completion;

// Loads entries from address book into app's CoreData model
- (void)syncCacheWithCompletion:(void (^)(BOOL success))completion;

- (void)clearCache;

- (NSDictionary*)paramsForAutoconnect;

@end
