// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserGroupPreference.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct UserGroupPreferenceAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *group_id;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *server_all_messages_mobile_push;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *user_id;
} UserGroupPreferenceAttributes;

@interface UserGroupPreferenceID : NSManagedObjectID {}
@end

@interface _UserGroupPreference : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UserGroupPreferenceID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* group_id;

//- (BOOL)validateGroup_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* server_all_messages_mobile_push;

@property (atomic) BOOL server_all_messages_mobile_pushValue;
- (BOOL)server_all_messages_mobile_pushValue;
- (void)setServer_all_messages_mobile_pushValue:(BOOL)value_;

//- (BOOL)validateServer_all_messages_mobile_push:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* user_id;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;

@end

@interface _UserGroupPreference (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveGroup_id;
- (void)setPrimitiveGroup_id:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveServer_all_messages_mobile_push;
- (void)setPrimitiveServer_all_messages_mobile_push:(NSNumber*)value;

- (BOOL)primitiveServer_all_messages_mobile_pushValue;
- (void)setPrimitiveServer_all_messages_mobile_pushValue:(BOOL)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSString*)value;

@end
