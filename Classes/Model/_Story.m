// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Story.m instead.

#import "_Story.h"

const struct StoryAttributes StoryAttributes = {
	.blurred = @"blurred",
	.comments_count = @"comments_count",
	.in_feed = @"in_feed",
	.last_comment_at = @"last_comment_at",
	.last_comment_seen_at = @"last_comment_seen_at",
	.last_comments_count = @"last_comments_count",
	.permission = @"permission",
	.shareable_to = @"shareable_to",
	.status = @"status",
	.viewed = @"viewed",
};

const struct StoryRelationships StoryRelationships = {
	.likes = @"likes",
	.next_story = @"next_story",
	.previous_story = @"previous_story",
	.story_user = @"story_user",
	.tags = @"tags",
};

@implementation StoryID
@end

@implementation _Story

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Story";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Story" inManagedObjectContext:moc_];
}

- (StoryID*)objectID {
	return (StoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"blurredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"blurred"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"comments_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"comments_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"in_feedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"in_feed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_comments_countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_comments_count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic blurred;

- (BOOL)blurredValue {
	NSNumber *result = [self blurred];
	return [result boolValue];
}

- (void)setBlurredValue:(BOOL)value_ {
	[self setBlurred:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBlurredValue {
	NSNumber *result = [self primitiveBlurred];
	return [result boolValue];
}

- (void)setPrimitiveBlurredValue:(BOOL)value_ {
	[self setPrimitiveBlurred:[NSNumber numberWithBool:value_]];
}

@dynamic comments_count;

- (int16_t)comments_countValue {
	NSNumber *result = [self comments_count];
	return [result shortValue];
}

- (void)setComments_countValue:(int16_t)value_ {
	[self setComments_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveComments_countValue {
	NSNumber *result = [self primitiveComments_count];
	return [result shortValue];
}

- (void)setPrimitiveComments_countValue:(int16_t)value_ {
	[self setPrimitiveComments_count:[NSNumber numberWithShort:value_]];
}

@dynamic in_feed;

- (BOOL)in_feedValue {
	NSNumber *result = [self in_feed];
	return [result boolValue];
}

- (void)setIn_feedValue:(BOOL)value_ {
	[self setIn_feed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIn_feedValue {
	NSNumber *result = [self primitiveIn_feed];
	return [result boolValue];
}

- (void)setPrimitiveIn_feedValue:(BOOL)value_ {
	[self setPrimitiveIn_feed:[NSNumber numberWithBool:value_]];
}

@dynamic last_comment_at;

@dynamic last_comment_seen_at;

@dynamic last_comments_count;

- (int16_t)last_comments_countValue {
	NSNumber *result = [self last_comments_count];
	return [result shortValue];
}

- (void)setLast_comments_countValue:(int16_t)value_ {
	[self setLast_comments_count:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLast_comments_countValue {
	NSNumber *result = [self primitiveLast_comments_count];
	return [result shortValue];
}

- (void)setPrimitiveLast_comments_countValue:(int16_t)value_ {
	[self setPrimitiveLast_comments_count:[NSNumber numberWithShort:value_]];
}

@dynamic permission;

@dynamic shareable_to;

@dynamic status;

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

@dynamic likes;

- (NSMutableSet*)likesSet {
	[self willAccessValueForKey:@"likes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"likes"];

	[self didAccessValueForKey:@"likes"];
	return result;
}

@dynamic next_story;

@dynamic previous_story;

@dynamic story_user;

@dynamic tags;

- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];

	[self didAccessValueForKey:@"tags"];
	return result;
}

@end

