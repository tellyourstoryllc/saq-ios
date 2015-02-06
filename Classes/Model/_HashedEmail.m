// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HashedEmail.m instead.

#import "_HashedEmail.h"

const struct HashedEmailAttributes HashedEmailAttributes = {
	.email = @"email",
	.id = @"id",
};

const struct HashedEmailRelationships HashedEmailRelationships = {
	.address_book_person = @"address_book_person",
	.user = @"user",
};

@implementation HashedEmailID
@end

@implementation _HashedEmail

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"HashedEmail" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"HashedEmail";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"HashedEmail" inManagedObjectContext:moc_];
}

- (HashedEmailID*)objectID {
	return (HashedEmailID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic email;

@dynamic id;

@dynamic address_book_person;

@dynamic user;

@end

