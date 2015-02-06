// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserPreference.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct UserPreferenceAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *server_mention_email;
	__unsafe_unretained NSString *server_one_to_one_email;
	__unsafe_unretained NSString *updated_at;
} UserPreferenceAttributes;

@interface UserPreferenceID : NSManagedObjectID {}
@end

@interface _UserPreference : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UserPreferenceID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* server_mention_email;

@property (atomic) BOOL server_mention_emailValue;
- (BOOL)server_mention_emailValue;
- (void)setServer_mention_emailValue:(BOOL)value_;

//- (BOOL)validateServer_mention_email:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* server_one_to_one_email;

@property (atomic) BOOL server_one_to_one_emailValue;
- (BOOL)server_one_to_one_emailValue;
- (void)setServer_one_to_one_emailValue:(BOOL)value_;

//- (BOOL)validateServer_one_to_one_email:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@end

@interface _UserPreference (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveServer_mention_email;
- (void)setPrimitiveServer_mention_email:(NSNumber*)value;

- (BOOL)primitiveServer_mention_emailValue;
- (void)setPrimitiveServer_mention_emailValue:(BOOL)value_;

- (NSNumber*)primitiveServer_one_to_one_email;
- (void)setPrimitiveServer_one_to_one_email:(NSNumber*)value;

- (BOOL)primitiveServer_one_to_one_emailValue;
- (void)setPrimitiveServer_one_to_one_emailValue:(BOOL)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

@end
