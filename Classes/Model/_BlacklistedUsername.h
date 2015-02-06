// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BlacklistedUsername.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct BlacklistedUsernameAttributes {
	__unsafe_unretained NSString *existsOnServer;
	__unsafe_unretained NSString *id;
} BlacklistedUsernameAttributes;

@interface BlacklistedUsernameID : NSManagedObjectID {}
@end

@interface _BlacklistedUsername : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) BlacklistedUsernameID* objectID;

@property (nonatomic, strong) NSNumber* existsOnServer;

@property (atomic) BOOL existsOnServerValue;
- (BOOL)existsOnServerValue;
- (void)setExistsOnServerValue:(BOOL)value_;

//- (BOOL)validateExistsOnServer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@end

@interface _BlacklistedUsername (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveExistsOnServer;
- (void)setPrimitiveExistsOnServer:(NSNumber*)value;

- (BOOL)primitiveExistsOnServerValue;
- (void)setPrimitiveExistsOnServerValue:(BOOL)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

@end
