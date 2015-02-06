// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeletedGroup.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct DeletedGroupAttributes {
	__unsafe_unretained NSString *deleted_at;
	__unsafe_unretained NSString *id;
} DeletedGroupAttributes;

@interface DeletedGroupID : NSManagedObjectID {}
@end

@interface _DeletedGroup : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DeletedGroupID* objectID;

@property (nonatomic, strong) NSDate* deleted_at;

//- (BOOL)validateDeleted_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@end

@interface _DeletedGroup (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveDeleted_at;
- (void)setPrimitiveDeleted_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

@end
