// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SnapchatSnap.m instead.

#import "_SnapchatSnap.h"

const struct SnapchatSnapAttributes SnapchatSnapAttributes = {
	.client_id = @"client_id",
	.created_at = @"created_at",
	.didNotify = @"didNotify",
	.id = @"id",
	.isNew = @"isNew",
	.media_state = @"media_state",
	.media_type = @"media_type",
	.recipient_name = @"recipient_name",
	.sender_name = @"sender_name",
	.timer = @"timer",
	.updated_at = @"updated_at",
};

@implementation SnapchatSnapID
@end

@implementation _SnapchatSnap

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SnapchatSnap" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SnapchatSnap";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SnapchatSnap" inManagedObjectContext:moc_];
}

- (SnapchatSnapID*)objectID {
	return (SnapchatSnapID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"didNotifyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"didNotify"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"media_stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"media_state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"media_typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"media_type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"timerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"timer"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic client_id;

@dynamic created_at;

@dynamic didNotify;

- (BOOL)didNotifyValue {
	NSNumber *result = [self didNotify];
	return [result boolValue];
}

- (void)setDidNotifyValue:(BOOL)value_ {
	[self setDidNotify:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDidNotifyValue {
	NSNumber *result = [self primitiveDidNotify];
	return [result boolValue];
}

- (void)setPrimitiveDidNotifyValue:(BOOL)value_ {
	[self setPrimitiveDidNotify:[NSNumber numberWithBool:value_]];
}

@dynamic id;

@dynamic isNew;

- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}

@dynamic media_state;

- (int32_t)media_stateValue {
	NSNumber *result = [self media_state];
	return [result intValue];
}

- (void)setMedia_stateValue:(int32_t)value_ {
	[self setMedia_state:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMedia_stateValue {
	NSNumber *result = [self primitiveMedia_state];
	return [result intValue];
}

- (void)setPrimitiveMedia_stateValue:(int32_t)value_ {
	[self setPrimitiveMedia_state:[NSNumber numberWithInt:value_]];
}

@dynamic media_type;

- (int16_t)media_typeValue {
	NSNumber *result = [self media_type];
	return [result shortValue];
}

- (void)setMedia_typeValue:(int16_t)value_ {
	[self setMedia_type:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMedia_typeValue {
	NSNumber *result = [self primitiveMedia_type];
	return [result shortValue];
}

- (void)setPrimitiveMedia_typeValue:(int16_t)value_ {
	[self setPrimitiveMedia_type:[NSNumber numberWithShort:value_]];
}

@dynamic recipient_name;

@dynamic sender_name;

@dynamic timer;

- (int16_t)timerValue {
	NSNumber *result = [self timer];
	return [result shortValue];
}

- (void)setTimerValue:(int16_t)value_ {
	[self setTimer:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTimerValue {
	NSNumber *result = [self primitiveTimer];
	return [result shortValue];
}

- (void)setPrimitiveTimerValue:(int16_t)value_ {
	[self setPrimitiveTimer:[NSNumber numberWithShort:value_]];
}

@dynamic updated_at;

@end

