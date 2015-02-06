// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatUser.m instead.

#import "_SnapchatUser.h"

const struct SnapchatUserAttributes SnapchatUserAttributes = {
	.added_at = @"added_at",
	.can_see_custom_stories = @"can_see_custom_stories",
	.created_at = @"created_at",
	.display = @"display",
	.friend_of_type = @"friend_of_type",
	.friend_type = @"friend_type",
	.id = @"id",
	.is_best_friend = @"is_best_friend",
	.is_friend = @"is_friend",
	.is_friend_of = @"is_friend_of",
	.is_shared_story = @"is_shared_story",
	.name = @"name",
	.phone = @"phone",
	.updated_at = @"updated_at",
	.user_type = @"user_type",
};

const struct SnapchatUserRelationships SnapchatUserRelationships = {
	.user = @"user",
};

@implementation SnapchatUserID
@end

@implementation _SnapchatUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SnapchatUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SnapchatUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SnapchatUser" inManagedObjectContext:moc_];
}

- (SnapchatUserID*)objectID {
	return (SnapchatUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"can_see_custom_storiesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"can_see_custom_stories"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"friend_of_typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"friend_of_type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"friend_typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"friend_type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_best_friendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_best_friend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_friendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_friend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_friend_ofValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_friend_of"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_shared_storyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_shared_story"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"user_typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic added_at;

@dynamic can_see_custom_stories;

- (BOOL)can_see_custom_storiesValue {
	NSNumber *result = [self can_see_custom_stories];
	return [result boolValue];
}

- (void)setCan_see_custom_storiesValue:(BOOL)value_ {
	[self setCan_see_custom_stories:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCan_see_custom_storiesValue {
	NSNumber *result = [self primitiveCan_see_custom_stories];
	return [result boolValue];
}

- (void)setPrimitiveCan_see_custom_storiesValue:(BOOL)value_ {
	[self setPrimitiveCan_see_custom_stories:[NSNumber numberWithBool:value_]];
}

@dynamic created_at;

@dynamic display;

@dynamic friend_of_type;

- (int16_t)friend_of_typeValue {
	NSNumber *result = [self friend_of_type];
	return [result shortValue];
}

- (void)setFriend_of_typeValue:(int16_t)value_ {
	[self setFriend_of_type:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFriend_of_typeValue {
	NSNumber *result = [self primitiveFriend_of_type];
	return [result shortValue];
}

- (void)setPrimitiveFriend_of_typeValue:(int16_t)value_ {
	[self setPrimitiveFriend_of_type:[NSNumber numberWithShort:value_]];
}

@dynamic friend_type;

- (int16_t)friend_typeValue {
	NSNumber *result = [self friend_type];
	return [result shortValue];
}

- (void)setFriend_typeValue:(int16_t)value_ {
	[self setFriend_type:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFriend_typeValue {
	NSNumber *result = [self primitiveFriend_type];
	return [result shortValue];
}

- (void)setPrimitiveFriend_typeValue:(int16_t)value_ {
	[self setPrimitiveFriend_type:[NSNumber numberWithShort:value_]];
}

@dynamic id;

@dynamic is_best_friend;

- (BOOL)is_best_friendValue {
	NSNumber *result = [self is_best_friend];
	return [result boolValue];
}

- (void)setIs_best_friendValue:(BOOL)value_ {
	[self setIs_best_friend:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_best_friendValue {
	NSNumber *result = [self primitiveIs_best_friend];
	return [result boolValue];
}

- (void)setPrimitiveIs_best_friendValue:(BOOL)value_ {
	[self setPrimitiveIs_best_friend:[NSNumber numberWithBool:value_]];
}

@dynamic is_friend;

- (BOOL)is_friendValue {
	NSNumber *result = [self is_friend];
	return [result boolValue];
}

- (void)setIs_friendValue:(BOOL)value_ {
	[self setIs_friend:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_friendValue {
	NSNumber *result = [self primitiveIs_friend];
	return [result boolValue];
}

- (void)setPrimitiveIs_friendValue:(BOOL)value_ {
	[self setPrimitiveIs_friend:[NSNumber numberWithBool:value_]];
}

@dynamic is_friend_of;

- (BOOL)is_friend_ofValue {
	NSNumber *result = [self is_friend_of];
	return [result boolValue];
}

- (void)setIs_friend_ofValue:(BOOL)value_ {
	[self setIs_friend_of:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_friend_ofValue {
	NSNumber *result = [self primitiveIs_friend_of];
	return [result boolValue];
}

- (void)setPrimitiveIs_friend_ofValue:(BOOL)value_ {
	[self setPrimitiveIs_friend_of:[NSNumber numberWithBool:value_]];
}

@dynamic is_shared_story;

- (BOOL)is_shared_storyValue {
	NSNumber *result = [self is_shared_story];
	return [result boolValue];
}

- (void)setIs_shared_storyValue:(BOOL)value_ {
	[self setIs_shared_story:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_shared_storyValue {
	NSNumber *result = [self primitiveIs_shared_story];
	return [result boolValue];
}

- (void)setPrimitiveIs_shared_storyValue:(BOOL)value_ {
	[self setPrimitiveIs_shared_story:[NSNumber numberWithBool:value_]];
}

@dynamic name;

@dynamic phone;

@dynamic updated_at;

@dynamic user_type;

- (int32_t)user_typeValue {
	NSNumber *result = [self user_type];
	return [result intValue];
}

- (void)setUser_typeValue:(int32_t)value_ {
	[self setUser_type:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUser_typeValue {
	NSNumber *result = [self primitiveUser_type];
	return [result intValue];
}

- (void)setPrimitiveUser_typeValue:(int32_t)value_ {
	[self setPrimitiveUser_type:[NSNumber numberWithInt:value_]];
}

@dynamic user;

@end

