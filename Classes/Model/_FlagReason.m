// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FlagReason.m instead.

#import "_FlagReason.h"

const struct FlagReasonAttributes FlagReasonAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.text = @"text",
	.updated_at = @"updated_at",
};

@implementation FlagReasonID
@end

@implementation _FlagReason

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FlagReason" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FlagReason";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FlagReason" inManagedObjectContext:moc_];
}

- (FlagReasonID*)objectID {
	return (FlagReasonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic text;

@dynamic updated_at;

@end

