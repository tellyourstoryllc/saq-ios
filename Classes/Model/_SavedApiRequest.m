// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SavedApiRequest.m instead.

#import "_SavedApiRequest.h"

const struct SavedApiRequestAttributes SavedApiRequestAttributes = {
	.created_at = @"created_at",
	.data2_filepath = @"data2_filepath",
	.data2_mimetype = @"data2_mimetype",
	.data2_param = @"data2_param",
	.data_filepath = @"data_filepath",
	.data_mimetype = @"data_mimetype",
	.data_param = @"data_param",
	.id = @"id",
	.jsonData = @"jsonData",
	.request_path = @"request_path",
	.status = @"status",
	.upload_attempts = @"upload_attempts",
};

const struct SavedApiRequestRelationships SavedApiRequestRelationships = {
	.placeholder = @"placeholder",
};

@implementation SavedApiRequestID
@end

@implementation _SavedApiRequest

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SavedApiRequest" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SavedApiRequest";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SavedApiRequest" inManagedObjectContext:moc_];
}

- (SavedApiRequestID*)objectID {
	return (SavedApiRequestID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"upload_attemptsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"upload_attempts"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic created_at;

@dynamic data2_filepath;

@dynamic data2_mimetype;

@dynamic data2_param;

@dynamic data_filepath;

@dynamic data_mimetype;

@dynamic data_param;

@dynamic id;

@dynamic jsonData;

@dynamic request_path;

@dynamic status;

- (int16_t)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(int16_t)value_ {
	[self setStatus:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(int16_t)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithShort:value_]];
}

@dynamic upload_attempts;

- (int16_t)upload_attemptsValue {
	NSNumber *result = [self upload_attempts];
	return [result shortValue];
}

- (void)setUpload_attemptsValue:(int16_t)value_ {
	[self setUpload_attempts:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUpload_attemptsValue {
	NSNumber *result = [self primitiveUpload_attempts];
	return [result shortValue];
}

- (void)setPrimitiveUpload_attemptsValue:(int16_t)value_ {
	[self setPrimitiveUpload_attempts:[NSNumber numberWithShort:value_]];
}

@dynamic placeholder;

@end

