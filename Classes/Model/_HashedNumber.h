// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HashedNumber.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct HashedNumberAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *phone_number;
} HashedNumberAttributes;

extern const struct HashedNumberRelationships {
	__unsafe_unretained NSString *address_book_person;
	__unsafe_unretained NSString *user;
} HashedNumberRelationships;

@class AddressBookPerson;
@class User;

@interface HashedNumberID : NSManagedObjectID {}
@end

@interface _HashedNumber : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HashedNumberID* objectID;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phone_number;

//- (BOOL)validatePhone_number:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) AddressBookPerson *address_book_person;

//- (BOOL)validateAddress_book_person:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _HashedNumber (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitivePhone_number;
- (void)setPrimitivePhone_number:(NSString*)value;

- (AddressBookPerson*)primitiveAddress_book_person;
- (void)setPrimitiveAddress_book_person:(AddressBookPerson*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
