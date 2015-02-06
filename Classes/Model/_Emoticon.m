// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Emoticon.m instead.

#import "_Emoticon.h"

const struct EmoticonAttributes EmoticonAttributes = {
	.created_at = @"created_at",
	.id = @"id",
	.image_url = @"image_url",
	.name = @"name",
	.updated_at = @"updated_at",
};

@implementation EmoticonID
@end

@implementation _Emoticon

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Emoticon" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Emoticon";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Emoticon" inManagedObjectContext:moc_];
}

- (EmoticonID*)objectID {
	return (EmoticonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic created_at;

@dynamic id;

@dynamic image_url;

@dynamic name;

@dynamic updated_at;

@end

