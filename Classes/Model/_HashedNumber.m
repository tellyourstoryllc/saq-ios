// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HashedNumber.m instead.

#import "_HashedNumber.h"

const struct HashedNumberAttributes HashedNumberAttributes = {
	.id = @"id",
	.phone_number = @"phone_number",
};

const struct HashedNumberRelationships HashedNumberRelationships = {
	.address_book_person = @"address_book_person",
	.user = @"user",
};

@implementation HashedNumberID
@end

@implementation _HashedNumber

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"HashedNumber" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"HashedNumber";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"HashedNumber" inManagedObjectContext:moc_];
}

- (HashedNumberID*)objectID {
	return (HashedNumberID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic id;

@dynamic phone_number;

@dynamic address_book_person;

@dynamic user;

@end

