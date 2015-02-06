// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatMediaItem.m instead.

#import "_SnapchatMediaItem.h"

const struct SnapchatMediaItemAttributes SnapchatMediaItemAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.updated_at = @"updated_at",
};

@implementation SnapchatMediaItemID
@end

@implementation _SnapchatMediaItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SnapchatMediaItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SnapchatMediaItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SnapchatMediaItem" inManagedObjectContext:moc_];
}

- (SnapchatMediaItemID*)objectID {
	return (SnapchatMediaItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic updated_at;

@end

