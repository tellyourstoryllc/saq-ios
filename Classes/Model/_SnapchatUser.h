// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatUser.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SnapchatUserAttributes {
	__unsafe_unretained NSString *added_at;
	__unsafe_unretained NSString *can_see_custom_stories;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *display;
	__unsafe_unretained NSString *friend_of_type;
	__unsafe_unretained NSString *friend_type;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *is_best_friend;
	__unsafe_unretained NSString *is_friend;
	__unsafe_unretained NSString *is_friend_of;
	__unsafe_unretained NSString *is_shared_story;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *user_type;
} SnapchatUserAttributes;

extern const struct SnapchatUserRelationships {
	__unsafe_unretained NSString *user;
} SnapchatUserRelationships;

@class User;

@interface SnapchatUserID : NSManagedObjectID {}
@end

@interface _SnapchatUser : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SnapchatUserID* objectID;

@property (nonatomic, strong) NSDate* added_at;

//- (BOOL)validateAdded_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* can_see_custom_stories;

@property (atomic) BOOL can_see_custom_storiesValue;
- (BOOL)can_see_custom_storiesValue;
- (void)setCan_see_custom_storiesValue:(BOOL)value_;

//- (BOOL)validateCan_see_custom_stories:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* display;

//- (BOOL)validateDisplay:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* friend_of_type;

@property (atomic) int16_t friend_of_typeValue;
- (int16_t)friend_of_typeValue;
- (void)setFriend_of_typeValue:(int16_t)value_;

//- (BOOL)validateFriend_of_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* friend_type;

@property (atomic) int16_t friend_typeValue;
- (int16_t)friend_typeValue;
- (void)setFriend_typeValue:(int16_t)value_;

//- (BOOL)validateFriend_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_best_friend;

@property (atomic) BOOL is_best_friendValue;
- (BOOL)is_best_friendValue;
- (void)setIs_best_friendValue:(BOOL)value_;

//- (BOOL)validateIs_best_friend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_friend;

@property (atomic) BOOL is_friendValue;
- (BOOL)is_friendValue;
- (void)setIs_friendValue:(BOOL)value_;

//- (BOOL)validateIs_friend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_friend_of;

@property (atomic) BOOL is_friend_ofValue;
- (BOOL)is_friend_ofValue;
- (void)setIs_friend_ofValue:(BOOL)value_;

//- (BOOL)validateIs_friend_of:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_shared_story;

@property (atomic) BOOL is_shared_storyValue;
- (BOOL)is_shared_storyValue;
- (void)setIs_shared_storyValue:(BOOL)value_;

//- (BOOL)validateIs_shared_story:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phone;

//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* user_type;

@property (atomic) int32_t user_typeValue;
- (int32_t)user_typeValue;
- (void)setUser_typeValue:(int32_t)value_;

//- (BOOL)validateUser_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _SnapchatUser (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveAdded_at;
- (void)setPrimitiveAdded_at:(NSDate*)value;

- (NSNumber*)primitiveCan_see_custom_stories;
- (void)setPrimitiveCan_see_custom_stories:(NSNumber*)value;

- (BOOL)primitiveCan_see_custom_storiesValue;
- (void)setPrimitiveCan_see_custom_storiesValue:(BOOL)value_;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveDisplay;
- (void)setPrimitiveDisplay:(NSString*)value;

- (NSNumber*)primitiveFriend_of_type;
- (void)setPrimitiveFriend_of_type:(NSNumber*)value;

- (int16_t)primitiveFriend_of_typeValue;
- (void)setPrimitiveFriend_of_typeValue:(int16_t)value_;

- (NSNumber*)primitiveFriend_type;
- (void)setPrimitiveFriend_type:(NSNumber*)value;

- (int16_t)primitiveFriend_typeValue;
- (void)setPrimitiveFriend_typeValue:(int16_t)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIs_best_friend;
- (void)setPrimitiveIs_best_friend:(NSNumber*)value;

- (BOOL)primitiveIs_best_friendValue;
- (void)setPrimitiveIs_best_friendValue:(BOOL)value_;

- (NSNumber*)primitiveIs_friend;
- (void)setPrimitiveIs_friend:(NSNumber*)value;

- (BOOL)primitiveIs_friendValue;
- (void)setPrimitiveIs_friendValue:(BOOL)value_;

- (NSNumber*)primitiveIs_friend_of;
- (void)setPrimitiveIs_friend_of:(NSNumber*)value;

- (BOOL)primitiveIs_friend_ofValue;
- (void)setPrimitiveIs_friend_ofValue:(BOOL)value_;

- (NSNumber*)primitiveIs_shared_story;
- (void)setPrimitiveIs_shared_story:(NSNumber*)value;

- (BOOL)primitiveIs_shared_storyValue;
- (void)setPrimitiveIs_shared_storyValue:(BOOL)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSNumber*)primitiveUser_type;
- (void)setPrimitiveUser_type:(NSNumber*)value;

- (int32_t)primitiveUser_typeValue;
- (void)setPrimitiveUser_typeValue:(int32_t)value_;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
