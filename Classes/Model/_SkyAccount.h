// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyAccount.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SkyAccountAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *needs_password;
	__unsafe_unretained NSString *one_to_one_wallpaper_url;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *user_id;
} SkyAccountAttributes;

@interface SkyAccountID : NSManagedObjectID {}
@end

@interface _SkyAccount : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SkyAccountID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* needs_password;

@property (atomic) BOOL needs_passwordValue;
- (BOOL)needs_passwordValue;
- (void)setNeeds_passwordValue:(BOOL)value_;

//- (BOOL)validateNeeds_password:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* one_to_one_wallpaper_url;

//- (BOOL)validateOne_to_one_wallpaper_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* user_id;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;

@end

@interface _SkyAccount (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveNeeds_password;
- (void)setPrimitiveNeeds_password:(NSNumber*)value;

- (BOOL)primitiveNeeds_passwordValue;
- (void)setPrimitiveNeeds_passwordValue:(BOOL)value_;

- (NSString*)primitiveOne_to_one_wallpaper_url;
- (void)setPrimitiveOne_to_one_wallpaper_url:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSString*)value;

@end
