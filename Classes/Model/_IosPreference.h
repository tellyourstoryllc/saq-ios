// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IosPreference.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct IosPreferenceAttributes {
	__unsafe_unretained NSString *client;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *server_mention;
	__unsafe_unretained NSString *server_one_to_one;
	__unsafe_unretained NSString *updated_at;
} IosPreferenceAttributes;

@interface IosPreferenceID : NSManagedObjectID {}
@end

@interface _IosPreference : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) IosPreferenceID* objectID;

@property (nonatomic, strong) NSString* client;

//- (BOOL)validateClient:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* server_mention;

@property (atomic) BOOL server_mentionValue;
- (BOOL)server_mentionValue;
- (void)setServer_mentionValue:(BOOL)value_;

//- (BOOL)validateServer_mention:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* server_one_to_one;

@property (atomic) BOOL server_one_to_oneValue;
- (BOOL)server_one_to_oneValue;
- (void)setServer_one_to_oneValue:(BOOL)value_;

//- (BOOL)validateServer_one_to_one:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@end

@interface _IosPreference (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveClient;
- (void)setPrimitiveClient:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveServer_mention;
- (void)setPrimitiveServer_mention:(NSNumber*)value;

- (BOOL)primitiveServer_mentionValue;
- (void)setPrimitiveServer_mentionValue:(BOOL)value_;

- (NSNumber*)primitiveServer_one_to_one;
- (void)setPrimitiveServer_one_to_one:(NSNumber*)value;

- (BOOL)primitiveServer_one_to_oneValue;
- (void)setPrimitiveServer_one_to_oneValue:(BOOL)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

@end
