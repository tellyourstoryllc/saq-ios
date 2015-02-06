#import "AddressBookPerson.h"
#import "SDImageCache.h"
#import "HashedEmail.h"
#import "HashedNumber.h"

@interface AddressBookPerson ()
@property (nonatomic, strong) RHPerson* rhPerson;
@end

@implementation AddressBookPerson

@synthesize rhPerson = _rhPerson;

- (void)updateWithRHPerson:(RHPerson*)person {
    self.rhPerson = person;

    self.id = [NSString stringWithFormat:@"%d", person.recordID];
    self.first_name = person.firstName;
    self.last_name = person.lastName;
    self.name = person.compositeName ?: person.phoneNumbers.values.firstObject ?: person.emails.values.firstObject;
    self.birthday = person.birthday;
    self.is_personValue = person.isPerson;

    [self updateWithEmails:[NSSet setWithArray:person.emails.values]];
    [self updateWithPhoneNumbers:[NSSet setWithArray:person.phoneNumbers.values]];

    UIImage* image = person.thumbnail;
    if (image) {
        [[SDImageCache sharedImageCache] storeImage:image forKey:[self _imageCacheKey] toDisk:YES];
    }
}

- (void)updateWithPhoneNumbers:(NSSet*)numbers {
    NSSet* currentNumbers = [self.phone_numbers valueForKey:@"phone_number"];

    NSMutableSet* newNumbers = [numbers mutableCopy];
    [newNumbers minusSet:currentNumbers];
    NSMutableSet* oldNumbers = [currentNumbers mutableCopy];
    [oldNumbers minusSet:numbers];

    for (HashedNumber* number in self.phone_numbers) {
        if ([oldNumbers containsObject:number.phone_number])
            [self removePhone_numbersObject:number];
    }

    for (NSString* number in newNumbers) {
        NSString* objId = [HashedNumber hashForNumber:number];
        HashedNumber* obj = [HashedNumber findOrCreateById:objId inContext:self.managedObjectContext];
        obj.phone_number = number;
        obj.address_book_person = self;

        self.user = self.user ?: obj.user;
        self.user.address_book_name = self.name;
    }
}

- (void)updateWithEmails:(NSSet*)emails {
    NSSet* currentEmails = [self.emails valueForKey:@"email"];

    NSMutableSet* newEmails = [emails mutableCopy];
    [newEmails minusSet:currentEmails];
    NSMutableSet* oldEmails = [currentEmails mutableCopy];
    [oldEmails minusSet:emails];

    for (HashedEmail* em in self.emails) {
        if ([oldEmails containsObject:em.email])
            [self removeEmailsObject:em];
    }

    for (NSString* email in newEmails) {
        NSString* objId = [HashedEmail hashForEmail:email];
        HashedEmail* obj = [HashedEmail findOrCreateById:objId inContext:self.managedObjectContext];
        obj.email = email;
        obj.address_book_person = self;

        self.user = self.user ?: obj.user;
        self.user.address_book_name = self.name;
    }
}

- (RHAddressBook*) rhAddressBook {
    static RHAddressBook* __rhab;
    if (!__rhab) __rhab = [RHAddressBook new];
    return __rhab;
}

- (UIImage*)image {
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self _imageCacheKey]];
}

- (NSString*)_imageCacheKey {
    return [NSString stringWithFormat:@"addressbookperson_image_%@", self.id];
}

- (RHPerson*) rhPerson {
    _rhPerson = _rhPerson ?: [[self rhAddressBook] personForABRecordID:self.id.intValue];
    return _rhPerson;
}

@end
