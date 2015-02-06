// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserGroupPreference.m instead.

#import "_UserGroupPreference.h"

const struct UserGroupPreferenceAttributes UserGroupPreferenceAttributes = {
	.created_at = @"created_at",
	.group_id = @"group_id",
	.id = @"id",
	.server_all_messages_mobile_push = @"server_all_messages_mobile_push",
	.updated_at = @"updated_at",
	.user_id = @"user_id",
};

@implementation UserGroupPreferenceID
@end

@implementation _UserGroupPreference

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UserGroupPreference" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UserGroupPreference";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UserGroupPreference" inManagedObjectContext:moc_];
}

- (UserGroupPreferenceID*)objectID {
	return (UserGroupPreferenceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"server_all_messages_mobile_pushValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"server_all_messages_mobile_push"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic created_at;

@dynamic group_id;

@dynamic id;

@dynamic server_all_messages_mobile_push;

- (BOOL)server_all_messages_mobile_pushValue {
	NSNumber *result = [self server_all_messages_mobile_push];
	return [result boolValue];
}

- (void)setServer_all_messages_mobile_pushValue:(BOOL)value_ {
	[self setServer_all_messages_mobile_push:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveServer_all_messages_mobile_pushValue {
	NSNumber *result = [self primitiveServer_all_messages_mobile_push];
	return [result boolValue];
}

- (void)setPrimitiveServer_all_messages_mobile_pushValue:(BOOL)value_ {
	[self setPrimitiveServer_all_messages_mobile_push:[NSNumber numberWithBool:value_]];
}

@dynamic updated_at;

@dynamic user_id;

@end

