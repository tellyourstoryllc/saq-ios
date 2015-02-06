// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FindFriendQueue.m instead.

#import "_FindFriendQueue.h"

const struct FindFriendQueueAttributes FindFriendQueueAttributes = {
	.id = @"id",
	.name = @"name",
	.phoneNumber = @"phoneNumber",
	.processed = @"processed",
	.username = @"username",
};

@implementation FindFriendQueueID
@end

@implementation _FindFriendQueue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FindFriendQueue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FindFriendQueue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FindFriendQueue" inManagedObjectContext:moc_];
}

- (FindFriendQueueID*)objectID {
	return (FindFriendQueueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"processedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"processed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic id;

@dynamic name;

@dynamic phoneNumber;

@dynamic processed;

- (BOOL)processedValue {
	NSNumber *result = [self processed];
	return [result boolValue];
}

- (void)setProcessedValue:(BOOL)value_ {
	[self setProcessed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveProcessedValue {
	NSNumber *result = [self primitiveProcessed];
	return [result boolValue];
}

- (void)setPrimitiveProcessedValue:(BOOL)value_ {
	[self setPrimitiveProcessed:[NSNumber numberWithBool:value_]];
}

@dynamic username;

@end

