// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyAccount.m instead.

#import "_SkyAccount.h"

const struct SkyAccountAttributes SkyAccountAttributes = {
	.created_at = @"created_at",
	.email = @"email",
	.id = @"id",
	.needs_password = @"needs_password",
	.one_to_one_wallpaper_url = @"one_to_one_wallpaper_url",
	.updated_at = @"updated_at",
	.user_id = @"user_id",
};

@implementation SkyAccountID
@end

@implementation _SkyAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SkyAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SkyAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SkyAccount" inManagedObjectContext:moc_];
}

- (SkyAccountID*)objectID {
	return (SkyAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"needs_passwordValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"needs_password"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic created_at;

@dynamic email;

@dynamic id;

@dynamic needs_password;

- (BOOL)needs_passwordValue {
	NSNumber *result = [self needs_password];
	return [result boolValue];
}

- (void)setNeeds_passwordValue:(BOOL)value_ {
	[self setNeeds_password:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNeeds_passwordValue {
	NSNumber *result = [self primitiveNeeds_password];
	return [result boolValue];
}

- (void)setPrimitiveNeeds_passwordValue:(BOOL)value_ {
	[self setPrimitiveNeeds_password:[NSNumber numberWithBool:value_]];
}

@dynamic one_to_one_wallpaper_url;

@dynamic updated_at;

@dynamic user_id;

@end

