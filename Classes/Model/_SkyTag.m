// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SkyTag.m instead.

#import "_SkyTag.h"

const struct SkyTagAttributes SkyTagAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.parent_id = @"parent_id",
};

const struct SkyTagRelationships SkyTagRelationships = {
	.children = @"children",
	.parent = @"parent",
	.stories = @"stories",
};

@implementation SkyTagID
@end

@implementation _SkyTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SkyTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SkyTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SkyTag" inManagedObjectContext:moc_];
}

- (SkyTagID*)objectID {
	return (SkyTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic parent_id;

@dynamic children;

- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];

	[self didAccessValueForKey:@"children"];
	return result;
}

@dynamic parent;

@dynamic stories;

- (NSMutableSet*)storiesSet {
	[self willAccessValueForKey:@"stories"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"stories"];

	[self didAccessValueForKey:@"stories"];
	return result;
}

@end

