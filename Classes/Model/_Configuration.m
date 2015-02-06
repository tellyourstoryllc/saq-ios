// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Configuration.m instead.

#import "_Configuration.h"

const struct ConfigurationAttributes ConfigurationAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.jsonData = @"jsonData",
	.updated_at = @"updated_at",
};

@implementation ConfigurationID
@end

@implementation _Configuration

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Configuration" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Configuration";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:moc_];
}

- (ConfigurationID*)objectID {
	return (ConfigurationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic jsonData;

@dynamic updated_at;

@end

