// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatMediaItem.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SnapchatMediaItemAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *updated_at;
} SnapchatMediaItemAttributes;

@interface SnapchatMediaItemID : NSManagedObjectID {}
@end

@interface _SnapchatMediaItem : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SnapchatMediaItemID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@end

@interface _SnapchatMediaItem (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

@end
