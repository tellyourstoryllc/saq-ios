// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyTag.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SkyTagAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *parent_id;
} SkyTagAttributes;

extern const struct SkyTagRelationships {
	__unsafe_unretained NSString *children;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *stories;
} SkyTagRelationships;

@class SkyTag;
@class SkyTag;
@class Story;

@interface SkyTagID : NSManagedObjectID {}
@end

@interface _SkyTag : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SkyTagID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* parent_id;

//- (BOOL)validateParent_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *children;

- (NSMutableSet*)childrenSet;

@property (nonatomic, strong) SkyTag *parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *stories;

- (NSMutableSet*)storiesSet;

@end

@interface _SkyTag (ChildrenCoreDataGeneratedAccessors)
- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(SkyTag*)value_;
- (void)removeChildrenObject:(SkyTag*)value_;

@end

@interface _SkyTag (StoriesCoreDataGeneratedAccessors)
- (void)addStories:(NSSet*)value_;
- (void)removeStories:(NSSet*)value_;
- (void)addStoriesObject:(Story*)value_;
- (void)removeStoriesObject:(Story*)value_;

@end

@interface _SkyTag (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveParent_id;
- (void)setPrimitiveParent_id:(NSString*)value;

- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;

- (SkyTag*)primitiveParent;
- (void)setPrimitiveParent:(SkyTag*)value;

- (NSMutableSet*)primitiveStories;
- (void)setPrimitiveStories:(NSMutableSet*)value;

@end
