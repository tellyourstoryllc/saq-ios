// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AddressBookPerson.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct AddressBookPersonAttributes {
	__unsafe_unretained NSString *birthday;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *deleted;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *is_person;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *rank;
	__unsafe_unretained NSString *updated_at;
} AddressBookPersonAttributes;

extern const struct AddressBookPersonRelationships {
	__unsafe_unretained NSString *emails;
	__unsafe_unretained NSString *phone_numbers;
	__unsafe_unretained NSString *user;
} AddressBookPersonRelationships;

@class HashedEmail;
@class HashedNumber;
@class User;

@interface AddressBookPersonID : NSManagedObjectID {}
@end

@interface _AddressBookPerson : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) AddressBookPersonID* objectID;

@property (nonatomic, strong) NSDate* birthday;

//- (BOOL)validateBirthday:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* deleted;

@property (atomic) BOOL deletedValue;
- (BOOL)deletedValue;
- (void)setDeletedValue:(BOOL)value_;

//- (BOOL)validateDeleted:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* first_name;

//- (BOOL)validateFirst_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_person;

@property (atomic) BOOL is_personValue;
- (BOOL)is_personValue;
- (void)setIs_personValue:(BOOL)value_;

//- (BOOL)validateIs_person:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* last_name;

//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rank;

@property (atomic) int16_t rankValue;
- (int16_t)rankValue;
- (void)setRankValue:(int16_t)value_;

//- (BOOL)validateRank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *emails;

- (NSMutableSet*)emailsSet;

@property (nonatomic, strong) NSSet *phone_numbers;

- (NSMutableSet*)phone_numbersSet;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _AddressBookPerson (EmailsCoreDataGeneratedAccessors)
- (void)addEmails:(NSSet*)value_;
- (void)removeEmails:(NSSet*)value_;
- (void)addEmailsObject:(HashedEmail*)value_;
- (void)removeEmailsObject:(HashedEmail*)value_;

@end

@interface _AddressBookPerson (Phone_numbersCoreDataGeneratedAccessors)
- (void)addPhone_numbers:(NSSet*)value_;
- (void)removePhone_numbers:(NSSet*)value_;
- (void)addPhone_numbersObject:(HashedNumber*)value_;
- (void)removePhone_numbersObject:(HashedNumber*)value_;

@end

@interface _AddressBookPerson (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveBirthday;
- (void)setPrimitiveBirthday:(NSDate*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSNumber*)primitiveDeleted;
- (void)setPrimitiveDeleted:(NSNumber*)value;

- (BOOL)primitiveDeletedValue;
- (void)setPrimitiveDeletedValue:(BOOL)value_;

- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIs_person;
- (void)setPrimitiveIs_person:(NSNumber*)value;

- (BOOL)primitiveIs_personValue;
- (void)setPrimitiveIs_personValue:(BOOL)value_;

- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveRank;
- (void)setPrimitiveRank:(NSNumber*)value;

- (int16_t)primitiveRankValue;
- (void)setPrimitiveRankValue:(int16_t)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSMutableSet*)primitiveEmails;
- (void)setPrimitiveEmails:(NSMutableSet*)value;

- (NSMutableSet*)primitivePhone_numbers;
- (void)setPrimitivePhone_numbers:(NSMutableSet*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
