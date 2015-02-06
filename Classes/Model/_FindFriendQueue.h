// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FindFriendQueue.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct FindFriendQueueAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *phoneNumber;
	__unsafe_unretained NSString *processed;
	__unsafe_unretained NSString *username;
} FindFriendQueueAttributes;

@interface FindFriendQueueID : NSManagedObjectID {}
@end

@interface _FindFriendQueue : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FindFriendQueueID* objectID;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phoneNumber;

//- (BOOL)validatePhoneNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* processed;

@property (atomic) BOOL processedValue;
- (BOOL)processedValue;
- (void)setProcessedValue:(BOOL)value_;

//- (BOOL)validateProcessed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@end

@interface _FindFriendQueue (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePhoneNumber;
- (void)setPrimitivePhoneNumber:(NSString*)value;

- (NSNumber*)primitiveProcessed;
- (void)setPrimitiveProcessed:(NSNumber*)value;

- (BOOL)primitiveProcessedValue;
- (void)setPrimitiveProcessedValue:(BOOL)value_;

- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;

@end
