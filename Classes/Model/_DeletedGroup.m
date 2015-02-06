// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeletedGroup.m instead.

#import "_DeletedGroup.h"

const struct DeletedGroupAttributes DeletedGroupAttributes = {
	.deleted_at = @"deleted_at",
	.id = @"id",
};

@implementation DeletedGroupID
@end

@implementation _DeletedGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DeletedGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DeletedGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DeletedGroup" inManagedObjectContext:moc_];
}

- (DeletedGroupID*)objectID {
	return (DeletedGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic deleted_at;

@dynamic id;

@end

