// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HashedEmail.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct HashedEmailAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *id;
} HashedEmailAttributes;

extern const struct HashedEmailRelationships {
	__unsafe_unretained NSString *address_book_person;
	__unsafe_unretained NSString *user;
} HashedEmailRelationships;

@class AddressBookPerson;
@class User;

@interface HashedEmailID : NSManagedObjectID {}
@end

@interface _HashedEmail : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HashedEmailID* objectID;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) AddressBookPerson *address_book_person;

//- (BOOL)validateAddress_book_person:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _HashedEmail (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (AddressBookPerson*)primitiveAddress_book_person;
- (void)setPrimitiveAddress_book_person:(AddressBookPerson*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
