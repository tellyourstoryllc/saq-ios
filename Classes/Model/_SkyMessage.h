// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyMessage.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SkyMessageAttributes {
	__unsafe_unretained NSString *actor_id;
	__unsafe_unretained NSString *attachment_content_type;
	__unsafe_unretained NSString *attachment_local_overlay_url;
	__unsafe_unretained NSString *attachment_local_preview_url;
	__unsafe_unretained NSString *attachment_local_url;
	__unsafe_unretained NSString *attachment_message_id;
	__unsafe_unretained NSString *attachment_metadata;
	__unsafe_unretained NSString *attachment_overlay_text;
	__unsafe_unretained NSString *attachment_overlay_url;
	__unsafe_unretained NSString *attachment_preview_height;
	__unsafe_unretained NSString *attachment_preview_url;
	__unsafe_unretained NSString *attachment_preview_width;
	__unsafe_unretained NSString *attachment_type;
	__unsafe_unretained NSString *attachment_url;
	__unsafe_unretained NSString *client_metadata;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *delivered_at;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *expires_at;
	__unsafe_unretained NSString *forward_message_id;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *is_placeholder;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *liked;
	__unsafe_unretained NSString *likes_count;
	__unsafe_unretained NSString *link_url;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *obliterated;
	__unsafe_unretained NSString *original_message_id;
	__unsafe_unretained NSString *rank;
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *transmission_failed;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *user_id;
	__unsafe_unretained NSString *viewed_at;
} SkyMessageAttributes;

extern const struct SkyMessageRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *mentioned_users;
	__unsafe_unretained NSString *saved_requests;
	__unsafe_unretained NSString *user;
} SkyMessageRelationships;

@class Group;
@class User;
@class SavedApiRequest;
@class User;

@interface SkyMessageID : NSManagedObjectID {}
@end

@interface _SkyMessage : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SkyMessageID* objectID;

@property (nonatomic, strong) NSString* actor_id;

//- (BOOL)validateActor_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_content_type;

//- (BOOL)validateAttachment_content_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_local_overlay_url;

//- (BOOL)validateAttachment_local_overlay_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_local_preview_url;

//- (BOOL)validateAttachment_local_preview_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_local_url;

//- (BOOL)validateAttachment_local_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_message_id;

//- (BOOL)validateAttachment_message_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_metadata;

//- (BOOL)validateAttachment_metadata:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_overlay_text;

//- (BOOL)validateAttachment_overlay_text:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_overlay_url;

//- (BOOL)validateAttachment_overlay_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* attachment_preview_height;

@property (atomic) int32_t attachment_preview_heightValue;
- (int32_t)attachment_preview_heightValue;
- (void)setAttachment_preview_heightValue:(int32_t)value_;

//- (BOOL)validateAttachment_preview_height:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_preview_url;

//- (BOOL)validateAttachment_preview_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* attachment_preview_width;

@property (atomic) int32_t attachment_preview_widthValue;
- (int32_t)attachment_preview_widthValue;
- (void)setAttachment_preview_widthValue:(int32_t)value_;

//- (BOOL)validateAttachment_preview_width:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_type;

//- (BOOL)validateAttachment_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* attachment_url;

//- (BOOL)validateAttachment_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* client_metadata;

//- (BOOL)validateClient_metadata:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* delivered_at;

//- (BOOL)validateDelivered_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* duration;

@property (atomic) float durationValue;
- (float)durationValue;
- (void)setDurationValue:(float)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* expires_at;

//- (BOOL)validateExpires_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* forward_message_id;

//- (BOOL)validateForward_message_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_placeholder;

@property (atomic) BOOL is_placeholderValue;
- (BOOL)is_placeholderValue;
- (void)setIs_placeholderValue:(BOOL)value_;

//- (BOOL)validateIs_placeholder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* latitude;

@property (atomic) float latitudeValue;
- (float)latitudeValue;
- (void)setLatitudeValue:(float)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* liked;

@property (atomic) BOOL likedValue;
- (BOOL)likedValue;
- (void)setLikedValue:(BOOL)value_;

//- (BOOL)validateLiked:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* likes_count;

@property (atomic) int16_t likes_countValue;
- (int16_t)likes_countValue;
- (void)setLikes_countValue:(int16_t)value_;

//- (BOOL)validateLikes_count:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* link_url;

//- (BOOL)validateLink_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* longitude;

@property (atomic) float longitudeValue;
- (float)longitudeValue;
- (void)setLongitudeValue:(float)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* obliterated;

@property (atomic) BOOL obliteratedValue;
- (BOOL)obliteratedValue;
- (void)setObliteratedValue:(BOOL)value_;

//- (BOOL)validateObliterated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* original_message_id;

//- (BOOL)validateOriginal_message_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rank;

@property (atomic) int32_t rankValue;
- (int32_t)rankValue;
- (void)setRankValue:(int32_t)value_;

//- (BOOL)validateRank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* source;

//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* transmission_failed;

@property (atomic) BOOL transmission_failedValue;
- (BOOL)transmission_failedValue;
- (void)setTransmission_failedValue:(BOOL)value_;

//- (BOOL)validateTransmission_failed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* user_id;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* viewed_at;

//- (BOOL)validateViewed_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Group *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *mentioned_users;

- (NSMutableSet*)mentioned_usersSet;

@property (nonatomic, strong) NSSet *saved_requests;

- (NSMutableSet*)saved_requestsSet;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _SkyMessage (Mentioned_usersCoreDataGeneratedAccessors)
- (void)addMentioned_users:(NSSet*)value_;
- (void)removeMentioned_users:(NSSet*)value_;
- (void)addMentioned_usersObject:(User*)value_;
- (void)removeMentioned_usersObject:(User*)value_;

@end

@interface _SkyMessage (Saved_requestsCoreDataGeneratedAccessors)
- (void)addSaved_requests:(NSSet*)value_;
- (void)removeSaved_requests:(NSSet*)value_;
- (void)addSaved_requestsObject:(SavedApiRequest*)value_;
- (void)removeSaved_requestsObject:(SavedApiRequest*)value_;

@end

@interface _SkyMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveActor_id;
- (void)setPrimitiveActor_id:(NSString*)value;

- (NSString*)primitiveAttachment_content_type;
- (void)setPrimitiveAttachment_content_type:(NSString*)value;

- (NSString*)primitiveAttachment_local_overlay_url;
- (void)setPrimitiveAttachment_local_overlay_url:(NSString*)value;

- (NSString*)primitiveAttachment_local_preview_url;
- (void)setPrimitiveAttachment_local_preview_url:(NSString*)value;

- (NSString*)primitiveAttachment_local_url;
- (void)setPrimitiveAttachment_local_url:(NSString*)value;

- (NSString*)primitiveAttachment_message_id;
- (void)setPrimitiveAttachment_message_id:(NSString*)value;

- (NSString*)primitiveAttachment_metadata;
- (void)setPrimitiveAttachment_metadata:(NSString*)value;

- (NSString*)primitiveAttachment_overlay_text;
- (void)setPrimitiveAttachment_overlay_text:(NSString*)value;

- (NSString*)primitiveAttachment_overlay_url;
- (void)setPrimitiveAttachment_overlay_url:(NSString*)value;

- (NSNumber*)primitiveAttachment_preview_height;
- (void)setPrimitiveAttachment_preview_height:(NSNumber*)value;

- (int32_t)primitiveAttachment_preview_heightValue;
- (void)setPrimitiveAttachment_preview_heightValue:(int32_t)value_;

- (NSString*)primitiveAttachment_preview_url;
- (void)setPrimitiveAttachment_preview_url:(NSString*)value;

- (NSNumber*)primitiveAttachment_preview_width;
- (void)setPrimitiveAttachment_preview_width:(NSNumber*)value;

- (int32_t)primitiveAttachment_preview_widthValue;
- (void)setPrimitiveAttachment_preview_widthValue:(int32_t)value_;

- (NSString*)primitiveAttachment_type;
- (void)setPrimitiveAttachment_type:(NSString*)value;

- (NSString*)primitiveAttachment_url;
- (void)setPrimitiveAttachment_url:(NSString*)value;

- (NSString*)primitiveClient_metadata;
- (void)setPrimitiveClient_metadata:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSDate*)primitiveDelivered_at;
- (void)setPrimitiveDelivered_at:(NSDate*)value;

- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (float)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(float)value_;

- (NSDate*)primitiveExpires_at;
- (void)setPrimitiveExpires_at:(NSDate*)value;

- (NSString*)primitiveForward_message_id;
- (void)setPrimitiveForward_message_id:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIs_placeholder;
- (void)setPrimitiveIs_placeholder:(NSNumber*)value;

- (BOOL)primitiveIs_placeholderValue;
- (void)setPrimitiveIs_placeholderValue:(BOOL)value_;

- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (float)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(float)value_;

- (NSNumber*)primitiveLiked;
- (void)setPrimitiveLiked:(NSNumber*)value;

- (BOOL)primitiveLikedValue;
- (void)setPrimitiveLikedValue:(BOOL)value_;

- (NSNumber*)primitiveLikes_count;
- (void)setPrimitiveLikes_count:(NSNumber*)value;

- (int16_t)primitiveLikes_countValue;
- (void)setPrimitiveLikes_countValue:(int16_t)value_;

- (NSString*)primitiveLink_url;
- (void)setPrimitiveLink_url:(NSString*)value;

- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (float)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(float)value_;

- (NSNumber*)primitiveObliterated;
- (void)setPrimitiveObliterated:(NSNumber*)value;

- (BOOL)primitiveObliteratedValue;
- (void)setPrimitiveObliteratedValue:(BOOL)value_;

- (NSString*)primitiveOriginal_message_id;
- (void)setPrimitiveOriginal_message_id:(NSString*)value;

- (NSNumber*)primitiveRank;
- (void)setPrimitiveRank:(NSNumber*)value;

- (int32_t)primitiveRankValue;
- (void)setPrimitiveRankValue:(int32_t)value_;

- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSNumber*)primitiveTransmission_failed;
- (void)setPrimitiveTransmission_failed:(NSNumber*)value;

- (BOOL)primitiveTransmission_failedValue;
- (void)setPrimitiveTransmission_failedValue:(BOOL)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSString*)value;

- (NSDate*)primitiveViewed_at;
- (void)setPrimitiveViewed_at:(NSDate*)value;

- (Group*)primitiveGroup;
- (void)setPrimitiveGroup:(Group*)value;

- (NSMutableSet*)primitiveMentioned_users;
- (void)setPrimitiveMentioned_users:(NSMutableSet*)value;

- (NSMutableSet*)primitiveSaved_requests;
- (void)setPrimitiveSaved_requests:(NSMutableSet*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
