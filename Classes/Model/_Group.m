// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.m instead.

#import "_Group.h"

const struct GroupAttributes GroupAttributes = {
	.avatar_url = @"avatar_url",
	.created_at = @"created_at",
	.deleted_at = @"deleted_at",
	.id = @"id",
	.isGroup = @"isGroup",
	.isHidden = @"isHidden",
	.isOneToOne = @"isOneToOne",
	.isVirtualOneToOne = @"isVirtualOneToOne",
	.join_url = @"join_url",
	.last_deleted_rank = @"last_deleted_rank",
	.last_message_at = @"last_message_at",
	.last_received_message_at = @"last_received_message_at",
	.last_seen_at = @"last_seen_at",
	.last_seen_rank = @"last_seen_rank",
	.max_rank = @"max_rank",
	.name = @"name",
	.topic = @"topic",
	.updated_at = @"updated_at",
	.wallpaper_url = @"wallpaper_url",
};

const struct GroupRelationships GroupRelationships = {
	.admins = @"admins",
	.last_message = @"last_message",
	.last_nonmeta_message = @"last_nonmeta_message",
	.last_user_message = @"last_user_message",
	.members = @"members",
	.messages = @"messages",
	.other_user = @"other_user",
};

@implementation GroupID
@end

@implementation _Group

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Group";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Group" inManagedObjectContext:moc_];
}

- (GroupID*)objectID {
	return (GroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isGroupValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isGroup"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isHiddenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isHidden"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isOneToOneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isOneToOne"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isVirtualOneToOneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isVirtualOneToOne"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_deleted_rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_deleted_rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_seen_rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_seen_rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"max_rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"max_rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic avatar_url;

@dynamic created_at;

@dynamic deleted_at;

@dynamic id;

@dynamic isGroup;

- (BOOL)isGroupValue {
	NSNumber *result = [self isGroup];
	return [result boolValue];
}

- (void)setIsGroupValue:(BOOL)value_ {
	[self setIsGroup:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsGroupValue {
	NSNumber *result = [self primitiveIsGroup];
	return [result boolValue];
}

- (void)setPrimitiveIsGroupValue:(BOOL)value_ {
	[self setPrimitiveIsGroup:[NSNumber numberWithBool:value_]];
}

@dynamic isHidden;

- (BOOL)isHiddenValue {
	NSNumber *result = [self isHidden];
	return [result boolValue];
}

- (void)setIsHiddenValue:(BOOL)value_ {
	[self setIsHidden:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsHiddenValue {
	NSNumber *result = [self primitiveIsHidden];
	return [result boolValue];
}

- (void)setPrimitiveIsHiddenValue:(BOOL)value_ {
	[self setPrimitiveIsHidden:[NSNumber numberWithBool:value_]];
}

@dynamic isOneToOne;

- (BOOL)isOneToOneValue {
	NSNumber *result = [self isOneToOne];
	return [result boolValue];
}

- (void)setIsOneToOneValue:(BOOL)value_ {
	[self setIsOneToOne:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsOneToOneValue {
	NSNumber *result = [self primitiveIsOneToOne];
	return [result boolValue];
}

- (void)setPrimitiveIsOneToOneValue:(BOOL)value_ {
	[self setPrimitiveIsOneToOne:[NSNumber numberWithBool:value_]];
}

@dynamic isVirtualOneToOne;

- (BOOL)isVirtualOneToOneValue {
	NSNumber *result = [self isVirtualOneToOne];
	return [result boolValue];
}

- (void)setIsVirtualOneToOneValue:(BOOL)value_ {
	[self setIsVirtualOneToOne:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsVirtualOneToOneValue {
	NSNumber *result = [self primitiveIsVirtualOneToOne];
	return [result boolValue];
}

- (void)setPrimitiveIsVirtualOneToOneValue:(BOOL)value_ {
	[self setPrimitiveIsVirtualOneToOne:[NSNumber numberWithBool:value_]];
}

@dynamic join_url;

@dynamic last_deleted_rank;

- (int16_t)last_deleted_rankValue {
	NSNumber *result = [self last_deleted_rank];
	return [result shortValue];
}

- (void)setLast_deleted_rankValue:(int16_t)value_ {
	[self setLast_deleted_rank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLast_deleted_rankValue {
	NSNumber *result = [self primitiveLast_deleted_rank];
	return [result shortValue];
}

- (void)setPrimitiveLast_deleted_rankValue:(int16_t)value_ {
	[self setPrimitiveLast_deleted_rank:[NSNumber numberWithShort:value_]];
}

@dynamic last_message_at;

@dynamic last_received_message_at;

@dynamic last_seen_at;

@dynamic last_seen_rank;

- (int16_t)last_seen_rankValue {
	NSNumber *result = [self last_seen_rank];
	return [result shortValue];
}

- (void)setLast_seen_rankValue:(int16_t)value_ {
	[self setLast_seen_rank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLast_seen_rankValue {
	NSNumber *result = [self primitiveLast_seen_rank];
	return [result shortValue];
}

- (void)setPrimitiveLast_seen_rankValue:(int16_t)value_ {
	[self setPrimitiveLast_seen_rank:[NSNumber numberWithShort:value_]];
}

@dynamic max_rank;

- (int16_t)max_rankValue {
	NSNumber *result = [self max_rank];
	return [result shortValue];
}

- (void)setMax_rankValue:(int16_t)value_ {
	[self setMax_rank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMax_rankValue {
	NSNumber *result = [self primitiveMax_rank];
	return [result shortValue];
}

- (void)setPrimitiveMax_rankValue:(int16_t)value_ {
	[self setPrimitiveMax_rank:[NSNumber numberWithShort:value_]];
}

@dynamic name;

@dynamic topic;

@dynamic updated_at;

@dynamic wallpaper_url;

@dynamic admins;

- (NSMutableSet*)adminsSet {
	[self willAccessValueForKey:@"admins"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"admins"];

	[self didAccessValueForKey:@"admins"];
	return result;
}

@dynamic last_message;

@dynamic last_nonmeta_message;

@dynamic last_user_message;

@dynamic members;

- (NSMutableSet*)membersSet {
	[self willAccessValueForKey:@"members"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"members"];

	[self didAccessValueForKey:@"members"];
	return result;
}

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic other_user;

@end

