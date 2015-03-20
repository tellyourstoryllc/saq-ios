// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.address_book_name = @"address_book_name",
	.avatar_url = @"avatar_url",
	.avatar_video_url = @"avatar_video_url",
	.created_at = @"created_at",
	.email = @"email",
	.facebook_id = @"facebook_id",
	.friend_code = @"friend_code",
	.has_one_to_one = @"has_one_to_one",
	.id = @"id",
	.idle_duration = @"idle_duration",
	.idle_start_time = @"idle_start_time",
	.is_blocked = @"is_blocked",
	.is_communicating = @"is_communicating",
	.is_contact = @"is_contact",
	.is_incoming_friend = @"is_incoming_friend",
	.is_incoming_ignored = @"is_incoming_ignored",
	.is_outgoing_friend = @"is_outgoing_friend",
	.jsonData = @"jsonData",
	.last_seen_story_at = @"last_seen_story_at",
	.last_story_at = @"last_story_at",
	.name = @"name",
	.priority = @"priority",
	.raw_username = @"raw_username",
	.registered = @"registered",
	.status = @"status",
	.status_ordinal = @"status_ordinal",
	.status_text = @"status_text",
	.token = @"token",
	.updated_at = @"updated_at",
	.username = @"username",
};

const struct UserRelationships UserRelationships = {
	.groups_administered = @"groups_administered",
	.groups_joined = @"groups_joined",
	.last_story = @"last_story",
	.likes = @"likes",
	.messages = @"messages",
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"has_one_to_oneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"has_one_to_one"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idle_durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"idle_duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idle_start_timeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"idle_start_time"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_blockedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_blocked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_communicatingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_communicating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_contactValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_contact"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_incoming_friendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_incoming_friend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_incoming_ignoredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_incoming_ignored"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_outgoing_friendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_outgoing_friend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"registeredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"registered"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"status_ordinalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status_ordinal"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic address_book_name;

@dynamic avatar_url;

@dynamic avatar_video_url;

@dynamic created_at;

@dynamic email;

@dynamic facebook_id;

@dynamic friend_code;

@dynamic has_one_to_one;

- (BOOL)has_one_to_oneValue {
	NSNumber *result = [self has_one_to_one];
	return [result boolValue];
}

- (void)setHas_one_to_oneValue:(BOOL)value_ {
	[self setHas_one_to_one:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHas_one_to_oneValue {
	NSNumber *result = [self primitiveHas_one_to_one];
	return [result boolValue];
}

- (void)setPrimitiveHas_one_to_oneValue:(BOOL)value_ {
	[self setPrimitiveHas_one_to_one:[NSNumber numberWithBool:value_]];
}

@dynamic id;

@dynamic idle_duration;

- (int32_t)idle_durationValue {
	NSNumber *result = [self idle_duration];
	return [result intValue];
}

- (void)setIdle_durationValue:(int32_t)value_ {
	[self setIdle_duration:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIdle_durationValue {
	NSNumber *result = [self primitiveIdle_duration];
	return [result intValue];
}

- (void)setPrimitiveIdle_durationValue:(int32_t)value_ {
	[self setPrimitiveIdle_duration:[NSNumber numberWithInt:value_]];
}

@dynamic idle_start_time;

- (int64_t)idle_start_timeValue {
	NSNumber *result = [self idle_start_time];
	return [result longLongValue];
}

- (void)setIdle_start_timeValue:(int64_t)value_ {
	[self setIdle_start_time:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIdle_start_timeValue {
	NSNumber *result = [self primitiveIdle_start_time];
	return [result longLongValue];
}

- (void)setPrimitiveIdle_start_timeValue:(int64_t)value_ {
	[self setPrimitiveIdle_start_time:[NSNumber numberWithLongLong:value_]];
}

@dynamic is_blocked;

- (BOOL)is_blockedValue {
	NSNumber *result = [self is_blocked];
	return [result boolValue];
}

- (void)setIs_blockedValue:(BOOL)value_ {
	[self setIs_blocked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_blockedValue {
	NSNumber *result = [self primitiveIs_blocked];
	return [result boolValue];
}

- (void)setPrimitiveIs_blockedValue:(BOOL)value_ {
	[self setPrimitiveIs_blocked:[NSNumber numberWithBool:value_]];
}

@dynamic is_communicating;

- (BOOL)is_communicatingValue {
	NSNumber *result = [self is_communicating];
	return [result boolValue];
}

- (void)setIs_communicatingValue:(BOOL)value_ {
	[self setIs_communicating:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_communicatingValue {
	NSNumber *result = [self primitiveIs_communicating];
	return [result boolValue];
}

- (void)setPrimitiveIs_communicatingValue:(BOOL)value_ {
	[self setPrimitiveIs_communicating:[NSNumber numberWithBool:value_]];
}

@dynamic is_contact;

- (BOOL)is_contactValue {
	NSNumber *result = [self is_contact];
	return [result boolValue];
}

- (void)setIs_contactValue:(BOOL)value_ {
	[self setIs_contact:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_contactValue {
	NSNumber *result = [self primitiveIs_contact];
	return [result boolValue];
}

- (void)setPrimitiveIs_contactValue:(BOOL)value_ {
	[self setPrimitiveIs_contact:[NSNumber numberWithBool:value_]];
}

@dynamic is_incoming_friend;

- (BOOL)is_incoming_friendValue {
	NSNumber *result = [self is_incoming_friend];
	return [result boolValue];
}

- (void)setIs_incoming_friendValue:(BOOL)value_ {
	[self setIs_incoming_friend:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_incoming_friendValue {
	NSNumber *result = [self primitiveIs_incoming_friend];
	return [result boolValue];
}

- (void)setPrimitiveIs_incoming_friendValue:(BOOL)value_ {
	[self setPrimitiveIs_incoming_friend:[NSNumber numberWithBool:value_]];
}

@dynamic is_incoming_ignored;

- (BOOL)is_incoming_ignoredValue {
	NSNumber *result = [self is_incoming_ignored];
	return [result boolValue];
}

- (void)setIs_incoming_ignoredValue:(BOOL)value_ {
	[self setIs_incoming_ignored:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_incoming_ignoredValue {
	NSNumber *result = [self primitiveIs_incoming_ignored];
	return [result boolValue];
}

- (void)setPrimitiveIs_incoming_ignoredValue:(BOOL)value_ {
	[self setPrimitiveIs_incoming_ignored:[NSNumber numberWithBool:value_]];
}

@dynamic is_outgoing_friend;

- (BOOL)is_outgoing_friendValue {
	NSNumber *result = [self is_outgoing_friend];
	return [result boolValue];
}

- (void)setIs_outgoing_friendValue:(BOOL)value_ {
	[self setIs_outgoing_friend:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_outgoing_friendValue {
	NSNumber *result = [self primitiveIs_outgoing_friend];
	return [result boolValue];
}

- (void)setPrimitiveIs_outgoing_friendValue:(BOOL)value_ {
	[self setPrimitiveIs_outgoing_friend:[NSNumber numberWithBool:value_]];
}

@dynamic jsonData;

@dynamic last_seen_story_at;

@dynamic last_story_at;

@dynamic name;

@dynamic priority;

- (int16_t)priorityValue {
	NSNumber *result = [self priority];
	return [result shortValue];
}

- (void)setPriorityValue:(int16_t)value_ {
	[self setPriority:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result shortValue];
}

- (void)setPrimitivePriorityValue:(int16_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithShort:value_]];
}

@dynamic raw_username;

@dynamic registered;

- (BOOL)registeredValue {
	NSNumber *result = [self registered];
	return [result boolValue];
}

- (void)setRegisteredValue:(BOOL)value_ {
	[self setRegistered:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRegisteredValue {
	NSNumber *result = [self primitiveRegistered];
	return [result boolValue];
}

- (void)setPrimitiveRegisteredValue:(BOOL)value_ {
	[self setPrimitiveRegistered:[NSNumber numberWithBool:value_]];
}

@dynamic status;

@dynamic status_ordinal;

- (int32_t)status_ordinalValue {
	NSNumber *result = [self status_ordinal];
	return [result intValue];
}

- (void)setStatus_ordinalValue:(int32_t)value_ {
	[self setStatus_ordinal:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveStatus_ordinalValue {
	NSNumber *result = [self primitiveStatus_ordinal];
	return [result intValue];
}

- (void)setPrimitiveStatus_ordinalValue:(int32_t)value_ {
	[self setPrimitiveStatus_ordinal:[NSNumber numberWithInt:value_]];
}

@dynamic status_text;

@dynamic token;

@dynamic updated_at;

@dynamic username;

@dynamic groups_administered;

- (NSMutableSet*)groups_administeredSet {
	[self willAccessValueForKey:@"groups_administered"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"groups_administered"];

	[self didAccessValueForKey:@"groups_administered"];
	return result;
}

@dynamic groups_joined;

- (NSMutableSet*)groups_joinedSet {
	[self willAccessValueForKey:@"groups_joined"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"groups_joined"];

	[self didAccessValueForKey:@"groups_joined"];
	return result;
}

@dynamic last_story;

@dynamic likes;

- (NSMutableSet*)likesSet {
	[self willAccessValueForKey:@"likes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"likes"];

	[self didAccessValueForKey:@"likes"];
	return result;
}

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@end

