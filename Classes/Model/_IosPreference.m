// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IosPreference.m instead.

#import "_IosPreference.h"

const struct IosPreferenceAttributes IosPreferenceAttributes = {
	.client = @"client",
	.created_at = @"created_at",
	.id = @"id",
	.server_mention = @"server_mention",
	.server_one_to_one = @"server_one_to_one",
	.updated_at = @"updated_at",
};

@implementation IosPreferenceID
@end

@implementation _IosPreference

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IosPreference" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IosPreference";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IosPreference" inManagedObjectContext:moc_];
}

- (IosPreferenceID*)objectID {
	return (IosPreferenceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"server_mentionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"server_mention"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"server_one_to_oneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"server_one_to_one"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic client;

@dynamic created_at;

@dynamic id;

@dynamic server_mention;

- (BOOL)server_mentionValue {
	NSNumber *result = [self server_mention];
	return [result boolValue];
}

- (void)setServer_mentionValue:(BOOL)value_ {
	[self setServer_mention:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveServer_mentionValue {
	NSNumber *result = [self primitiveServer_mention];
	return [result boolValue];
}

- (void)setPrimitiveServer_mentionValue:(BOOL)value_ {
	[self setPrimitiveServer_mention:[NSNumber numberWithBool:value_]];
}

@dynamic server_one_to_one;

- (BOOL)server_one_to_oneValue {
	NSNumber *result = [self server_one_to_one];
	return [result boolValue];
}

- (void)setServer_one_to_oneValue:(BOOL)value_ {
	[self setServer_one_to_one:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveServer_one_to_oneValue {
	NSNumber *result = [self primitiveServer_one_to_one];
	return [result boolValue];
}

- (void)setPrimitiveServer_one_to_oneValue:(BOOL)value_ {
	[self setPrimitiveServer_one_to_one:[NSNumber numberWithBool:value_]];
}

@dynamic updated_at;

@end

