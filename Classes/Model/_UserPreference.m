// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserPreference.m instead.

#import "_UserPreference.h"

const struct UserPreferenceAttributes UserPreferenceAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.server_mention_email = @"server_mention_email",
	.server_one_to_one_email = @"server_one_to_one_email",
	.updated_at = @"updated_at",
};

@implementation UserPreferenceID
@end

@implementation _UserPreference

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UserPreference" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UserPreference";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UserPreference" inManagedObjectContext:moc_];
}

- (UserPreferenceID*)objectID {
	return (UserPreferenceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"server_mention_emailValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"server_mention_email"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"server_one_to_one_emailValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"server_one_to_one_email"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic server_mention_email;

- (BOOL)server_mention_emailValue {
	NSNumber *result = [self server_mention_email];
	return [result boolValue];
}

- (void)setServer_mention_emailValue:(BOOL)value_ {
	[self setServer_mention_email:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveServer_mention_emailValue {
	NSNumber *result = [self primitiveServer_mention_email];
	return [result boolValue];
}

- (void)setPrimitiveServer_mention_emailValue:(BOOL)value_ {
	[self setPrimitiveServer_mention_email:[NSNumber numberWithBool:value_]];
}

@dynamic server_one_to_one_email;

- (BOOL)server_one_to_one_emailValue {
	NSNumber *result = [self server_one_to_one_email];
	return [result boolValue];
}

- (void)setServer_one_to_one_emailValue:(BOOL)value_ {
	[self setServer_one_to_one_email:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveServer_one_to_one_emailValue {
	NSNumber *result = [self primitiveServer_one_to_one_email];
	return [result boolValue];
}

- (void)setPrimitiveServer_one_to_one_emailValue:(BOOL)value_ {
	[self setPrimitiveServer_one_to_one_email:[NSNumber numberWithBool:value_]];
}

@dynamic updated_at;

@end

