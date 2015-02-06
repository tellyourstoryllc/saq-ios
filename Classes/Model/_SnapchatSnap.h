// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatSnap.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SnapchatSnapAttributes {
	__unsafe_unretained NSString *client_id;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *didNotify;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *media_state;
	__unsafe_unretained NSString *media_type;
	__unsafe_unretained NSString *recipient_name;
	__unsafe_unretained NSString *sender_name;
	__unsafe_unretained NSString *timer;
	__unsafe_unretained NSString *updated_at;
} SnapchatSnapAttributes;

@interface SnapchatSnapID : NSManagedObjectID {}
@end

@interface _SnapchatSnap : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SnapchatSnapID* objectID;

@property (nonatomic, strong) NSString* client_id;

//- (BOOL)validateClient_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* didNotify;

@property (atomic) BOOL didNotifyValue;
- (BOOL)didNotifyValue;
- (void)setDidNotifyValue:(BOOL)value_;

//- (BOOL)validateDidNotify:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isNew;

@property (atomic) BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* media_state;

@property (atomic) int32_t media_stateValue;
- (int32_t)media_stateValue;
- (void)setMedia_stateValue:(int32_t)value_;

//- (BOOL)validateMedia_state:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* media_type;

@property (atomic) int16_t media_typeValue;
- (int16_t)media_typeValue;
- (void)setMedia_typeValue:(int16_t)value_;

//- (BOOL)validateMedia_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* recipient_name;

//- (BOOL)validateRecipient_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sender_name;

//- (BOOL)validateSender_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* timer;

@property (atomic) int16_t timerValue;
- (int16_t)timerValue;
- (void)setTimerValue:(int16_t)value_;

//- (BOOL)validateTimer:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@end

@interface _SnapchatSnap (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveClient_id;
- (void)setPrimitiveClient_id:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSNumber*)primitiveDidNotify;
- (void)setPrimitiveDidNotify:(NSNumber*)value;

- (BOOL)primitiveDidNotifyValue;
- (void)setPrimitiveDidNotifyValue:(BOOL)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;

- (NSNumber*)primitiveMedia_state;
- (void)setPrimitiveMedia_state:(NSNumber*)value;

- (int32_t)primitiveMedia_stateValue;
- (void)setPrimitiveMedia_stateValue:(int32_t)value_;

- (NSNumber*)primitiveMedia_type;
- (void)setPrimitiveMedia_type:(NSNumber*)value;

- (int16_t)primitiveMedia_typeValue;
- (void)setPrimitiveMedia_typeValue:(int16_t)value_;

- (NSString*)primitiveRecipient_name;
- (void)setPrimitiveRecipient_name:(NSString*)value;

- (NSString*)primitiveSender_name;
- (void)setPrimitiveSender_name:(NSString*)value;

- (NSNumber*)primitiveTimer;
- (void)setPrimitiveTimer:(NSNumber*)value;

- (int16_t)primitiveTimerValue;
- (void)setPrimitiveTimerValue:(int16_t)value_;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

@end
