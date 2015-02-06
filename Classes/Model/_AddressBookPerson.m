// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AddressBookPerson.m instead.

#import "_AddressBookPerson.h"

const struct AddressBookPersonAttributes AddressBookPersonAttributes = {
	.birthday = @"birthday",
	.created_at = @"created_at",
	.deleted = @"deleted",
	.first_name = @"first_name",
	.id = @"id",
	.is_person = @"is_person",
	.last_name = @"last_name",
	.name = @"name",
	.rank = @"rank",
	.updated_at = @"updated_at",
};

const struct AddressBookPersonRelationships AddressBookPersonRelationships = {
	.emails = @"emails",
	.phone_numbers = @"phone_numbers",
	.user = @"user",
};

@implementation AddressBookPersonID
@end

@implementation _AddressBookPerson

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AddressBookPerson" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AddressBookPerson";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AddressBookPerson" inManagedObjectContext:moc_];
}

- (AddressBookPersonID*)objectID {
	return (AddressBookPersonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"deletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_personValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_person"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic birthday;

@dynamic created_at;

@dynamic deleted;

- (BOOL)deletedValue {
	NSNumber *result = [self deleted];
	return [result boolValue];
}

- (void)setDeletedValue:(BOOL)value_ {
	[self setDeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeletedValue {
	NSNumber *result = [self primitiveDeleted];
	return [result boolValue];
}

- (void)setPrimitiveDeletedValue:(BOOL)value_ {
	[self setPrimitiveDeleted:[NSNumber numberWithBool:value_]];
}

@dynamic first_name;

@dynamic id;

@dynamic is_person;

- (BOOL)is_personValue {
	NSNumber *result = [self is_person];
	return [result boolValue];
}

- (void)setIs_personValue:(BOOL)value_ {
	[self setIs_person:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_personValue {
	NSNumber *result = [self primitiveIs_person];
	return [result boolValue];
}

- (void)setPrimitiveIs_personValue:(BOOL)value_ {
	[self setPrimitiveIs_person:[NSNumber numberWithBool:value_]];
}

@dynamic last_name;

@dynamic name;

@dynamic rank;

- (int16_t)rankValue {
	NSNumber *result = [self rank];
	return [result shortValue];
}

- (void)setRankValue:(int16_t)value_ {
	[self setRank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRankValue {
	NSNumber *result = [self primitiveRank];
	return [result shortValue];
}

- (void)setPrimitiveRankValue:(int16_t)value_ {
	[self setPrimitiveRank:[NSNumber numberWithShort:value_]];
}

@dynamic updated_at;

@dynamic emails;

- (NSMutableSet*)emailsSet {
	[self willAccessValueForKey:@"emails"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"emails"];

	[self didAccessValueForKey:@"emails"];
	return result;
}

@dynamic phone_numbers;

- (NSMutableSet*)phone_numbersSet {
	[self willAccessValueForKey:@"phone_numbers"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"phone_numbers"];

	[self didAccessValueForKey:@"phone_numbers"];
	return result;
}

@dynamic user;

@end

