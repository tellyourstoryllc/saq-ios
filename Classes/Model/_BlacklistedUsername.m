// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BlacklistedUsername.m instead.

#import "_BlacklistedUsername.h"

const struct BlacklistedUsernameAttributes BlacklistedUsernameAttributes = {
	.existsOnServer = @"existsOnServer",
	.id = @"id",
};

@implementation BlacklistedUsernameID
@end

@implementation _BlacklistedUsername

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BlacklistedUsername" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BlacklistedUsername";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BlacklistedUsername" inManagedObjectContext:moc_];
}

- (BlacklistedUsernameID*)objectID {
	return (BlacklistedUsernameID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"existsOnServerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"existsOnServer"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic existsOnServer;

- (BOOL)existsOnServerValue {
	NSNumber *result = [self existsOnServer];
	return [result boolValue];
}

- (void)setExistsOnServerValue:(BOOL)value_ {
	[self setExistsOnServer:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveExistsOnServerValue {
	NSNumber *result = [self primitiveExistsOnServer];
	return [result boolValue];
}

- (void)setPrimitiveExistsOnServerValue:(BOOL)value_ {
	[self setPrimitiveExistsOnServer:[NSNumber numberWithBool:value_]];
}

@dynamic id;

@end

