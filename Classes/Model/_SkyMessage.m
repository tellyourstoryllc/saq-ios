// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyMessage.m instead.

#import "_SkyMessage.h"

const struct SkyMessageAttributes SkyMessageAttributes = {
	.actor_id = @"actor_id",
	.attachment_content_type = @"attachment_content_type",
	.attachment_local_overlay_url = @"attachment_local_overlay_url",
	.attachment_local_preview_url = @"attachment_local_preview_url",
	.attachment_local_url = @"attachment_local_url",
	.attachment_message_id = @"attachment_message_id",
	.attachment_metadata = @"attachment_metadata",
	.attachment_overlay_text = @"attachment_overlay_text",
	.attachment_overlay_url = @"attachment_overlay_url",
	.attachment_preview_height = @"attachment_preview_height",
	.attachment_preview_url = @"attachment_preview_url",
	.attachment_preview_width = @"attachment_preview_width",
	.attachment_type = @"attachment_type",
	.attachment_url = @"attachment_url",
	.client_metadata = @"client_metadata",
	.created_at = @"created_at",
	.delivered_at = @"delivered_at",
	.duration = @"duration",
	.expires_at = @"expires_at",
	.forward_message_id = @"forward_message_id",
	.id = @"id",
	.is_placeholder = @"is_placeholder",
	.latitude = @"latitude",
	.liked = @"liked",
	.likes_count = @"likes_count",
	.link_url = @"link_url",
	.longitude = @"longitude",
	.obliterated = @"obliterated",
	.original_message_id = @"original_message_id",
	.rank = @"rank",
	.source = @"source",
	.text = @"text",
	.transmission_failed = @"transmission_failed",
	.updated_at = @"updated_at",
	.user_id = @"user_id",
	.viewed_at = @"viewed_at",
	.youtube_id = @"youtube_id",
};

const struct SkyMessageRelationships SkyMessageRelationships = {
	.group = @"group",
	.mentioned_users = @"mentioned_users",
	.saved_requests = @"saved_requests",
	.user = @"user",
};

@implementation SkyMessageID
@end

@implementation _SkyMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SkyMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SkyMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SkyMessage" inManagedObjectContext:moc_];
}

- (SkyMessageID*)objectID {
	return (SkyMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"attachment_preview_heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"attachment_preview_height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"attachment_preview_widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"attachment_preview_width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_placeholderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_placeholder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likes_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"likes_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"obliteratedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"obliterated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transmission_failedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transmission_failed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic actor_id;

@dynamic attachment_content_type;

@dynamic attachment_local_overlay_url;

@dynamic attachment_local_preview_url;

@dynamic attachment_local_url;

@dynamic attachment_message_id;

@dynamic attachment_metadata;

@dynamic attachment_overlay_text;

@dynamic attachment_overlay_url;

@dynamic attachment_preview_height;

- (int32_t)attachment_preview_heightValue {
	NSNumber *result = [self attachment_preview_height];
	return [result intValue];
}

- (void)setAttachment_preview_heightValue:(int32_t)value_ {
	[self setAttachment_preview_height:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveAttachment_preview_heightValue {
	NSNumber *result = [self primitiveAttachment_preview_height];
	return [result intValue];
}

- (void)setPrimitiveAttachment_preview_heightValue:(int32_t)value_ {
	[self setPrimitiveAttachment_preview_height:[NSNumber numberWithInt:value_]];
}

@dynamic attachment_preview_url;

@dynamic attachment_preview_width;

- (int32_t)attachment_preview_widthValue {
	NSNumber *result = [self attachment_preview_width];
	return [result intValue];
}

- (void)setAttachment_preview_widthValue:(int32_t)value_ {
	[self setAttachment_preview_width:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveAttachment_preview_widthValue {
	NSNumber *result = [self primitiveAttachment_preview_width];
	return [result intValue];
}

- (void)setPrimitiveAttachment_preview_widthValue:(int32_t)value_ {
	[self setPrimitiveAttachment_preview_width:[NSNumber numberWithInt:value_]];
}

@dynamic attachment_type;

@dynamic attachment_url;

@dynamic client_metadata;

@dynamic created_at;

@dynamic delivered_at;

@dynamic duration;

- (float)durationValue {
	NSNumber *result = [self duration];
	return [result floatValue];
}

- (void)setDurationValue:(float)value_ {
	[self setDuration:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result floatValue];
}

- (void)setPrimitiveDurationValue:(float)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithFloat:value_]];
}

@dynamic expires_at;

@dynamic forward_message_id;

@dynamic id;

@dynamic is_placeholder;

- (BOOL)is_placeholderValue {
	NSNumber *result = [self is_placeholder];
	return [result boolValue];
}

- (void)setIs_placeholderValue:(BOOL)value_ {
	[self setIs_placeholder:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_placeholderValue {
	NSNumber *result = [self primitiveIs_placeholder];
	return [result boolValue];
}

- (void)setPrimitiveIs_placeholderValue:(BOOL)value_ {
	[self setPrimitiveIs_placeholder:[NSNumber numberWithBool:value_]];
}

@dynamic latitude;

- (float)latitudeValue {
	NSNumber *result = [self latitude];
	return [result floatValue];
}

- (void)setLatitudeValue:(float)value_ {
	[self setLatitude:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result floatValue];
}

- (void)setPrimitiveLatitudeValue:(float)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithFloat:value_]];
}

@dynamic liked;

- (BOOL)likedValue {
	NSNumber *result = [self liked];
	return [result boolValue];
}

- (void)setLikedValue:(BOOL)value_ {
	[self setLiked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLikedValue {
	NSNumber *result = [self primitiveLiked];
	return [result boolValue];
}

- (void)setPrimitiveLikedValue:(BOOL)value_ {
	[self setPrimitiveLiked:[NSNumber numberWithBool:value_]];
}

@dynamic likes_count;

- (int16_t)likes_countValue {
	NSNumber *result = [self likes_count];
	return [result shortValue];
}

- (void)setLikes_countValue:(int16_t)value_ {
	[self setLikes_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLikes_countValue {
	NSNumber *result = [self primitiveLikes_count];
	return [result shortValue];
}

- (void)setPrimitiveLikes_countValue:(int16_t)value_ {
	[self setPrimitiveLikes_count:[NSNumber numberWithShort:value_]];
}

@dynamic link_url;

@dynamic longitude;

- (float)longitudeValue {
	NSNumber *result = [self longitude];
	return [result floatValue];
}

- (void)setLongitudeValue:(float)value_ {
	[self setLongitude:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result floatValue];
}

- (void)setPrimitiveLongitudeValue:(float)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithFloat:value_]];
}

@dynamic obliterated;

- (BOOL)obliteratedValue {
	NSNumber *result = [self obliterated];
	return [result boolValue];
}

- (void)setObliteratedValue:(BOOL)value_ {
	[self setObliterated:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveObliteratedValue {
	NSNumber *result = [self primitiveObliterated];
	return [result boolValue];
}

- (void)setPrimitiveObliteratedValue:(BOOL)value_ {
	[self setPrimitiveObliterated:[NSNumber numberWithBool:value_]];
}

@dynamic original_message_id;

@dynamic rank;

- (int32_t)rankValue {
	NSNumber *result = [self rank];
	return [result intValue];
}

- (void)setRankValue:(int32_t)value_ {
	[self setRank:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRankValue {
	NSNumber *result = [self primitiveRank];
	return [result intValue];
}

- (void)setPrimitiveRankValue:(int32_t)value_ {
	[self setPrimitiveRank:[NSNumber numberWithInt:value_]];
}

@dynamic source;

@dynamic text;

@dynamic transmission_failed;

- (BOOL)transmission_failedValue {
	NSNumber *result = [self transmission_failed];
	return [result boolValue];
}

- (void)setTransmission_failedValue:(BOOL)value_ {
	[self setTransmission_failed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveTransmission_failedValue {
	NSNumber *result = [self primitiveTransmission_failed];
	return [result boolValue];
}

- (void)setPrimitiveTransmission_failedValue:(BOOL)value_ {
	[self setPrimitiveTransmission_failed:[NSNumber numberWithBool:value_]];
}

@dynamic updated_at;

@dynamic user_id;

@dynamic viewed_at;

@dynamic youtube_id;

@dynamic group;

@dynamic mentioned_users;

- (NSMutableSet*)mentioned_usersSet {
	[self willAccessValueForKey:@"mentioned_users"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"mentioned_users"];

	[self didAccessValueForKey:@"mentioned_users"];
	return result;
}

@dynamic saved_requests;

- (NSMutableSet*)saved_requestsSet {
	[self willAccessValueForKey:@"saved_requests"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"saved_requests"];

	[self didAccessValueForKey:@"saved_requests"];
	return result;
}

@dynamic user;

@end

