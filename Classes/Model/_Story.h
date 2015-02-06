// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Story.h instead.

#import <CoreData/CoreData.h>
#import "SkyMessage.h"

extern const struct StoryAttributes {
	__unsafe_unretained NSString *comments_count;
	__unsafe_unretained NSString *in_feed;
	__unsafe_unretained NSString *last_comment_at;
	__unsafe_unretained NSString *last_comment_seen_at;
	__unsafe_unretained NSString *last_comments_count;
	__unsafe_unretained NSString *permission;
	__unsafe_unretained NSString *viewed;
} StoryAttributes;

extern const struct StoryRelationships {
	__unsafe_unretained NSString *likes;
	__unsafe_unretained NSString *next_story;
	__unsafe_unretained NSString *previous_story;
	__unsafe_unretained NSString *story_user;
	__unsafe_unretained NSString *tags;
} StoryRelationships;

@class NSManagedObject;
@class Story;
@class Story;
@class User;
@class SkyTag;

@interface StoryID : SkyMessageID {}
@end

@interface _Story : SkyMessage {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) StoryID* objectID;

@property (nonatomic, strong) NSNumber* comments_count;

@property (atomic) int16_t comments_countValue;
- (int16_t)comments_countValue;
- (void)setComments_countValue:(int16_t)value_;

//- (BOOL)validateComments_count:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* in_feed;

@property (atomic) BOOL in_feedValue;
- (BOOL)in_feedValue;
- (void)setIn_feedValue:(BOOL)value_;

//- (BOOL)validateIn_feed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_comment_at;

//- (BOOL)validateLast_comment_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_comment_seen_at;

//- (BOOL)validateLast_comment_seen_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* last_comments_count;

@property (atomic) int16_t last_comments_countValue;
- (int16_t)last_comments_countValue;
- (void)setLast_comments_countValue:(int16_t)value_;

//- (BOOL)validateLast_comments_count:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* permission;

//- (BOOL)validatePermission:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* viewed;

@property (atomic) BOOL viewedValue;
- (BOOL)viewedValue;
- (void)setViewedValue:(BOOL)value_;

//- (BOOL)validateViewed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *likes;

- (NSMutableSet*)likesSet;

@property (nonatomic, strong) Story *next_story;

//- (BOOL)validateNext_story:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Story *previous_story;

//- (BOOL)validatePrevious_story:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *story_user;

//- (BOOL)validateStory_user:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;

@end

@interface _Story (LikesCoreDataGeneratedAccessors)
- (void)addLikes:(NSSet*)value_;
- (void)removeLikes:(NSSet*)value_;
- (void)addLikesObject:(NSManagedObject*)value_;
- (void)removeLikesObject:(NSManagedObject*)value_;

@end

@interface _Story (TagsCoreDataGeneratedAccessors)
- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(SkyTag*)value_;
- (void)removeTagsObject:(SkyTag*)value_;

@end

@interface _Story (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveComments_count;
- (void)setPrimitiveComments_count:(NSNumber*)value;

- (int16_t)primitiveComments_countValue;
- (void)setPrimitiveComments_countValue:(int16_t)value_;

- (NSNumber*)primitiveIn_feed;
- (void)setPrimitiveIn_feed:(NSNumber*)value;

- (BOOL)primitiveIn_feedValue;
- (void)setPrimitiveIn_feedValue:(BOOL)value_;

- (NSDate*)primitiveLast_comment_at;
- (void)setPrimitiveLast_comment_at:(NSDate*)value;

- (NSDate*)primitiveLast_comment_seen_at;
- (void)setPrimitiveLast_comment_seen_at:(NSDate*)value;

- (NSNumber*)primitiveLast_comments_count;
- (void)setPrimitiveLast_comments_count:(NSNumber*)value;

- (int16_t)primitiveLast_comments_countValue;
- (void)setPrimitiveLast_comments_countValue:(int16_t)value_;

- (NSString*)primitivePermission;
- (void)setPrimitivePermission:(NSString*)value;

- (NSNumber*)primitiveViewed;
- (void)setPrimitiveViewed:(NSNumber*)value;

- (BOOL)primitiveViewedValue;
- (void)setPrimitiveViewedValue:(BOOL)value_;

- (NSMutableSet*)primitiveLikes;
- (void)setPrimitiveLikes:(NSMutableSet*)value;

- (Story*)primitiveNext_story;
- (void)setPrimitiveNext_story:(Story*)value;

- (Story*)primitivePrevious_story;
- (void)setPrimitivePrevious_story:(Story*)value;

- (User*)primitiveStory_user;
- (void)setPrimitiveStory_user:(User*)value;

- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;

@end
