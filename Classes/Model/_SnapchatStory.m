// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatStory.m instead.

#import "_SnapchatStory.h"

const struct SnapchatStoryAttributes SnapchatStoryAttributes = {
	.caption_text_display = @"caption_text_display",
	.client_id = @"client_id",
	.created_at = @"created_at",
	.didNotify = @"didNotify",
	.height = @"height",
	.id = @"id",
	.isNew = @"isNew",
	.isPhoto = @"isPhoto",
	.isUnread = @"isUnread",
	.isVideo = @"isVideo",
	.liked = @"liked",
	.localMediaUrl = @"localMediaUrl",
	.localOverlayUrl = @"localOverlayUrl",
	.localThumbnailUrl = @"localThumbnailUrl",
	.media_id = @"media_id",
	.media_iv = @"media_iv",
	.media_key = @"media_key",
	.media_url = @"media_url",
	.recipient = @"recipient",
	.thumbnail_iv = @"thumbnail_iv",
	.thumbnail_url = @"thumbnail_url",
	.time = @"time",
	.updated_at = @"updated_at",
	.username = @"username",
	.viewed = @"viewed",
	.width = @"width",
	.zipped = @"zipped",
};

const struct SnapchatStoryRelationships SnapchatStoryRelationships = {
	.story = @"story",
};

@implementation SnapchatStoryID
@end

@implementation _SnapchatStory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SnapchatStory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SnapchatStory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SnapchatStory" inManagedObjectContext:moc_];
}

- (SnapchatStoryID*)objectID {
	return (SnapchatStoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"didNotifyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"didNotify"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPhotoValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPhoto"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isUnreadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isUnread"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isVideoValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isVideo"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"timeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"time"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"zippedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"zipped"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic caption_text_display;

@dynamic client_id;

@dynamic created_at;

@dynamic didNotify;

- (BOOL)didNotifyValue {
	NSNumber *result = [self didNotify];
	return [result boolValue];
}

- (void)setDidNotifyValue:(BOOL)value_ {
	[self setDidNotify:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDidNotifyValue {
	NSNumber *result = [self primitiveDidNotify];
	return [result boolValue];
}

- (void)setPrimitiveDidNotifyValue:(BOOL)value_ {
	[self setPrimitiveDidNotify:[NSNumber numberWithBool:value_]];
}

@dynamic height;

- (int16_t)heightValue {
	NSNumber *result = [self height];
	return [result shortValue];
}

- (void)setHeightValue:(int16_t)value_ {
	[self setHeight:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result shortValue];
}

- (void)setPrimitiveHeightValue:(int16_t)value_ {
	[self setPrimitiveHeight:[NSNumber numberWithShort:value_]];
}

@dynamic id;

@dynamic isNew;

- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}

@dynamic isPhoto;

- (BOOL)isPhotoValue {
	NSNumber *result = [self isPhoto];
	return [result boolValue];
}

- (void)setIsPhotoValue:(BOOL)value_ {
	[self setIsPhoto:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPhotoValue {
	NSNumber *result = [self primitiveIsPhoto];
	return [result boolValue];
}

- (void)setPrimitiveIsPhotoValue:(BOOL)value_ {
	[self setPrimitiveIsPhoto:[NSNumber numberWithBool:value_]];
}

@dynamic isUnread;

- (BOOL)isUnreadValue {
	NSNumber *result = [self isUnread];
	return [result boolValue];
}

- (void)setIsUnreadValue:(BOOL)value_ {
	[self setIsUnread:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsUnreadValue {
	NSNumber *result = [self primitiveIsUnread];
	return [result boolValue];
}

- (void)setPrimitiveIsUnreadValue:(BOOL)value_ {
	[self setPrimitiveIsUnread:[NSNumber numberWithBool:value_]];
}

@dynamic isVideo;

- (BOOL)isVideoValue {
	NSNumber *result = [self isVideo];
	return [result boolValue];
}

- (void)setIsVideoValue:(BOOL)value_ {
	[self setIsVideo:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsVideoValue {
	NSNumber *result = [self primitiveIsVideo];
	return [result boolValue];
}

- (void)setPrimitiveIsVideoValue:(BOOL)value_ {
	[self setPrimitiveIsVideo:[NSNumber numberWithBool:value_]];
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

@dynamic localMediaUrl;

@dynamic localOverlayUrl;

@dynamic localThumbnailUrl;

@dynamic media_id;

@dynamic media_iv;

@dynamic media_key;

@dynamic media_url;

@dynamic recipient;

@dynamic thumbnail_iv;

@dynamic thumbnail_url;

@dynamic time;

- (float)timeValue {
	NSNumber *result = [self time];
	return [result floatValue];
}

- (void)setTimeValue:(float)value_ {
	[self setTime:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTimeValue {
	NSNumber *result = [self primitiveTime];
	return [result floatValue];
}

- (void)setPrimitiveTimeValue:(float)value_ {
	[self setPrimitiveTime:[NSNumber numberWithFloat:value_]];
}

@dynamic updated_at;

@dynamic username;

@dynamic viewed;

- (BOOL)viewedValue {
	NSNumber *result = [self viewed];
	return [result boolValue];
}

- (void)setViewedValue:(BOOL)value_ {
	[self setViewed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveViewedValue {
	NSNumber *result = [self primitiveViewed];
	return [result boolValue];
}

- (void)setPrimitiveViewedValue:(BOOL)value_ {
	[self setPrimitiveViewed:[NSNumber numberWithBool:value_]];
}

@dynamic width;

- (int16_t)widthValue {
	NSNumber *result = [self width];
	return [result shortValue];
}

- (void)setWidthValue:(int16_t)value_ {
	[self setWidth:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result shortValue];
}

- (void)setPrimitiveWidthValue:(int16_t)value_ {
	[self setPrimitiveWidth:[NSNumber numberWithShort:value_]];
}

@dynamic zipped;

- (BOOL)zippedValue {
	NSNumber *result = [self zipped];
	return [result boolValue];
}

- (void)setZippedValue:(BOOL)value_ {
	[self setZipped:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveZippedValue {
	NSNumber *result = [self primitiveZipped];
	return [result boolValue];
}

- (void)setPrimitiveZippedValue:(BOOL)value_ {
	[self setPrimitiveZipped:[NSNumber numberWithBool:value_]];
}

@dynamic story;

@end

