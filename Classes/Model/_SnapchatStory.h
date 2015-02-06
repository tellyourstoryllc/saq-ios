// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatStory.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SnapchatStoryAttributes {
	__unsafe_unretained NSString *caption_text_display;
	__unsafe_unretained NSString *client_id;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *didNotify;
	__unsafe_unretained NSString *height;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *isPhoto;
	__unsafe_unretained NSString *isUnread;
	__unsafe_unretained NSString *isVideo;
	__unsafe_unretained NSString *liked;
	__unsafe_unretained NSString *localMediaUrl;
	__unsafe_unretained NSString *localOverlayUrl;
	__unsafe_unretained NSString *localThumbnailUrl;
	__unsafe_unretained NSString *media_id;
	__unsafe_unretained NSString *media_iv;
	__unsafe_unretained NSString *media_key;
	__unsafe_unretained NSString *media_url;
	__unsafe_unretained NSString *recipient;
	__unsafe_unretained NSString *thumbnail_iv;
	__unsafe_unretained NSString *thumbnail_url;
	__unsafe_unretained NSString *time;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *viewed;
	__unsafe_unretained NSString *width;
	__unsafe_unretained NSString *zipped;
} SnapchatStoryAttributes;

extern const struct SnapchatStoryRelationships {
	__unsafe_unretained NSString *story;
} SnapchatStoryRelationships;

@class Story;

@interface SnapchatStoryID : NSManagedObjectID {}
@end

@interface _SnapchatStory : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SnapchatStoryID* objectID;

@property (nonatomic, strong) NSString* caption_text_display;

//- (BOOL)validateCaption_text_display:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* client_id;

//- (BOOL)validateClient_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* didNotify;

@property (atomic) BOOL didNotifyValue;
- (BOOL)didNotifyValue;
- (void)setDidNotifyValue:(BOOL)value_;

//- (BOOL)validateDidNotify:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* height;

@property (atomic) int16_t heightValue;
- (int16_t)heightValue;
- (void)setHeightValue:(int16_t)value_;

//- (BOOL)validateHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isNew;

@property (atomic) BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isPhoto;

@property (atomic) BOOL isPhotoValue;
- (BOOL)isPhotoValue;
- (void)setIsPhotoValue:(BOOL)value_;

//- (BOOL)validateIsPhoto:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isUnread;

@property (atomic) BOOL isUnreadValue;
- (BOOL)isUnreadValue;
- (void)setIsUnreadValue:(BOOL)value_;

//- (BOOL)validateIsUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isVideo;

@property (atomic) BOOL isVideoValue;
- (BOOL)isVideoValue;
- (void)setIsVideoValue:(BOOL)value_;

//- (BOOL)validateIsVideo:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* liked;

@property (atomic) BOOL likedValue;
- (BOOL)likedValue;
- (void)setLikedValue:(BOOL)value_;

//- (BOOL)validateLiked:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* localMediaUrl;

//- (BOOL)validateLocalMediaUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* localOverlayUrl;

//- (BOOL)validateLocalOverlayUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* localThumbnailUrl;

//- (BOOL)validateLocalThumbnailUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* media_id;

//- (BOOL)validateMedia_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* media_iv;

//- (BOOL)validateMedia_iv:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* media_key;

//- (BOOL)validateMedia_key:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* media_url;

//- (BOOL)validateMedia_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* recipient;

//- (BOOL)validateRecipient:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* thumbnail_iv;

//- (BOOL)validateThumbnail_iv:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* thumbnail_url;

//- (BOOL)validateThumbnail_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* time;

@property (atomic) float timeValue;
- (float)timeValue;
- (void)setTimeValue:(float)value_;

//- (BOOL)validateTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* viewed;

@property (atomic) BOOL viewedValue;
- (BOOL)viewedValue;
- (void)setViewedValue:(BOOL)value_;

//- (BOOL)validateViewed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* width;

@property (atomic) int16_t widthValue;
- (int16_t)widthValue;
- (void)setWidthValue:(int16_t)value_;

//- (BOOL)validateWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* zipped;

@property (atomic) BOOL zippedValue;
- (BOOL)zippedValue;
- (void)setZippedValue:(BOOL)value_;

//- (BOOL)validateZipped:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Story *story;

//- (BOOL)validateStory:(id*)value_ error:(NSError**)error_;

@end

@interface _SnapchatStory (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCaption_text_display;
- (void)setPrimitiveCaption_text_display:(NSString*)value;

- (NSString*)primitiveClient_id;
- (void)setPrimitiveClient_id:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSNumber*)primitiveDidNotify;
- (void)setPrimitiveDidNotify:(NSNumber*)value;

- (BOOL)primitiveDidNotifyValue;
- (void)setPrimitiveDidNotifyValue:(BOOL)value_;

- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (int16_t)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(int16_t)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;

- (NSNumber*)primitiveIsPhoto;
- (void)setPrimitiveIsPhoto:(NSNumber*)value;

- (BOOL)primitiveIsPhotoValue;
- (void)setPrimitiveIsPhotoValue:(BOOL)value_;

- (NSNumber*)primitiveIsUnread;
- (void)setPrimitiveIsUnread:(NSNumber*)value;

- (BOOL)primitiveIsUnreadValue;
- (void)setPrimitiveIsUnreadValue:(BOOL)value_;

- (NSNumber*)primitiveIsVideo;
- (void)setPrimitiveIsVideo:(NSNumber*)value;

- (BOOL)primitiveIsVideoValue;
- (void)setPrimitiveIsVideoValue:(BOOL)value_;

- (NSNumber*)primitiveLiked;
- (void)setPrimitiveLiked:(NSNumber*)value;

- (BOOL)primitiveLikedValue;
- (void)setPrimitiveLikedValue:(BOOL)value_;

- (NSString*)primitiveLocalMediaUrl;
- (void)setPrimitiveLocalMediaUrl:(NSString*)value;

- (NSString*)primitiveLocalOverlayUrl;
- (void)setPrimitiveLocalOverlayUrl:(NSString*)value;

- (NSString*)primitiveLocalThumbnailUrl;
- (void)setPrimitiveLocalThumbnailUrl:(NSString*)value;

- (NSString*)primitiveMedia_id;
- (void)setPrimitiveMedia_id:(NSString*)value;

- (NSString*)primitiveMedia_iv;
- (void)setPrimitiveMedia_iv:(NSString*)value;

- (NSString*)primitiveMedia_key;
- (void)setPrimitiveMedia_key:(NSString*)value;

- (NSString*)primitiveMedia_url;
- (void)setPrimitiveMedia_url:(NSString*)value;

- (NSString*)primitiveRecipient;
- (void)setPrimitiveRecipient:(NSString*)value;

- (NSString*)primitiveThumbnail_iv;
- (void)setPrimitiveThumbnail_iv:(NSString*)value;

- (NSString*)primitiveThumbnail_url;
- (void)setPrimitiveThumbnail_url:(NSString*)value;

- (NSNumber*)primitiveTime;
- (void)setPrimitiveTime:(NSNumber*)value;

- (float)primitiveTimeValue;
- (void)setPrimitiveTimeValue:(float)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;

- (NSNumber*)primitiveViewed;
- (void)setPrimitiveViewed:(NSNumber*)value;

- (BOOL)primitiveViewedValue;
- (void)setPrimitiveViewedValue:(BOOL)value_;

- (NSNumber*)primitiveWidth;
- (void)setPrimitiveWidth:(NSNumber*)value;

- (int16_t)primitiveWidthValue;
- (void)setPrimitiveWidthValue:(int16_t)value_;

- (NSNumber*)primitiveZipped;
- (void)setPrimitiveZipped:(NSNumber*)value;

- (BOOL)primitiveZippedValue;
- (void)setPrimitiveZippedValue:(BOOL)value_;

- (Story*)primitiveStory;
- (void)setPrimitiveStory:(Story*)value;

@end
