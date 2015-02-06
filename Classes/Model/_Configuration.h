// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Configuration.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct ConfigurationAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *jsonData;
	__unsafe_unretained NSString *updated_at;
} ConfigurationAttributes;

@interface ConfigurationID : NSManagedObjectID {}
@end

@interface _Configuration : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConfigurationID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* jsonData;

//- (BOOL)validateJsonData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@end

@interface _Configuration (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSData*)primitiveJsonData;
- (void)setPrimitiveJsonData:(NSData*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

@end
