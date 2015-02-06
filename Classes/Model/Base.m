#import "Base.h"
#import "App.h"
#import "NSArray+Map.h"

@implementation Base

@synthesize json = _json;

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors
                            limit:(NSUInteger)fetchLimit
                           offset:(NSUInteger)fetchOffset
                        inContext:(NSManagedObjectContext*)context {

    __block NSArray* fetchedObjects;

    [context performBlockAndWait:^{

        NSFetchRequest* request = [self fetchRequestInContext:context];

        if (predicate) request.predicate = predicate;
        if (sortDescriptors) {
            if ([sortDescriptors isKindOfClass:[NSSortDescriptor class]]) [request setSortDescriptors:@[sortDescriptors]];
            if ([sortDescriptors isKindOfClass:[NSArray class]]) [request setSortDescriptors:(NSArray*)sortDescriptors];
        }
        if (fetchLimit) request.fetchLimit = fetchLimit;
        if (fetchOffset) request.fetchOffset = fetchOffset;

        NSError* error;
        fetchedObjects = [context executeFetchRequest:request error:&error];
    }];

    return fetchedObjects;
}

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                        inContext:(NSManagedObjectContext*)context {
    return [self findAllUsingPredicate:predicate sortedBy:nil limit:0 offset:0 inContext:context];
}

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors {
    return [self findAllUsingPredicate:predicate sortedBy:sortDescriptors limit:0 offset:0 inContext:[App moc]];
}

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors
                            limit:(NSUInteger)fetchLimit {
    return [self findAllUsingPredicate:predicate sortedBy:sortDescriptors limit:fetchLimit offset:0 inContext:[App moc]];
}

//

+ (void)fetchAllUsingPredicate:(NSPredicate*)predicate
                      sortedBy:(id)sortDescriptors
                         limit:(NSUInteger)fetchLimit
                        offset:(NSUInteger)fetchOffset
                     inContext:(NSManagedObjectContext*)context
                    completion:(void (^)(NSArray* results))completion {

    [context performBlock:^{
        NSFetchRequest* request = [self fetchRequestInContext:context];
        if (predicate) request.predicate = predicate;
        if (sortDescriptors) {
            if ([sortDescriptors isKindOfClass:[NSSortDescriptor class]]) [request setSortDescriptors:@[sortDescriptors]];
            if ([sortDescriptors isKindOfClass:[NSArray class]]) [request setSortDescriptors:(NSArray*)sortDescriptors];
        }
        if (fetchLimit) request.fetchLimit = fetchLimit;
        if (fetchOffset) request.fetchOffset = fetchOffset;

        NSError* error;
        NSArray* fetchedObjects = [context executeFetchRequest:request error:&error];
        if (completion) completion(fetchedObjects);
    }];
}

+ (NSString*)entityName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSFetchRequest*)fetchRequestInContext:(NSManagedObjectContext*)context {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    if (!context) context = [App moc];
    request.entity = [NSEntityDescription entityForName:[self entityName]
                                 inManagedObjectContext:context];
    return request;
}

+ (id)findById:(id)objectId
     inContext:(NSManagedObjectContext*)context {
    
    if (!objectId) return nil;
    NSArray* result = [self findByIds:@[objectId] inContext:context];
    return [result lastObject];
}

+ (id)createWithId:(id)objectId
         inContext:(NSManagedObjectContext*)context {

    __block id obj;
    [context performBlockAndWait:^{
        obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                            inManagedObjectContext:context];
        [obj setValue:[NSString stringWithFormat:@"%@", objectId] forKey:@"id"];
        if ([obj respondsToSelector:@selector(created_at)])
            [obj setValue:[[NSDate alloc] init] forKey:@"created_at"];
    }];

    return obj;
}

+ (id)findOrCreateById:(id)objectId
             inContext:(NSManagedObjectContext*)context {
    return [self findById:objectId inContext:context] ?: [self createWithId:objectId inContext:context];
}

+ (NSArray*)findByIds:(NSArray*)objectIds
            inContext:(NSManagedObjectContext*)context {
    
    NSArray* idStrings = [objectIds mapUsingBlock:^id(id obj) {
        return [obj description];
    }];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id IN (%@)", idStrings];
    NSMutableArray* result = [[self findAllUsingPredicate:predicate inContext:context] mutableCopy];
    
    // Make sure results are returned in the same order as objectIds array.
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return ([idStrings indexOfObject:[obj1 valueForKey:@"id"]] > [idStrings indexOfObject:[obj2 valueForKey:@"id"]]) ? NSOrderedDescending : NSOrderedSame;
    }];
    
    return result;
}

+ (void)deleteAll {
    NSManagedObjectContext* moc = [App moc];
    for (Base* item in [self findAllUsingPredicate:nil inContext:moc])
        [item delete];
}

+ (void)deleteAllNullIds {
    NSManagedObjectContext* moc = [App moc];
    for (Base* item in [self findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id = NULL"] inContext:moc])
        [item delete];
}

+ (NSUInteger)countUsingPredicate:(NSPredicate*)predicate
                        inContext:(NSManagedObjectContext*)context {
    NSArray* result = [self findAllUsingPredicate:predicate inContext:context];
    return result.count;
}

- (void)delete {
    [self destroyAndSave:NO];
}

- (void) save {
    [self.managedObjectContext performBlock:^{
        [self.managedObjectContext save:nil];
    }];
}

- (void) destroyAndSave:(BOOL)shouldSave {
    NSManagedObjectContext* context = self.managedObjectContext;
    [context performBlockAndWait:^{
        [context deleteObject:self];
        if (shouldSave)
            [context save:nil];
    }];
}

- (void)processJSONObject:(NSDictionary *)jsonObject {

    if(!jsonObject)
        return;
    
    _json = jsonObject;

    // Look for keys in JSON data that have the same name as the entity attributes
    for (NSPropertyDescription* prop in [self entity]) {
        if ([prop isKindOfClass:[NSAttributeDescription class]]) {

            if ([prop.name isEqualToString:@"id"]) continue;

            id val = [jsonObject objectForKey:prop.name];
            
            if(val && [val isKindOfClass:[NSNull class]]) {
                [self setNilValueForKey:prop.name];
                
            } else if (val) {
                NSAttributeDescription* attrProp = (NSAttributeDescription*)prop;
                switch (attrProp.attributeType) {
                        
                    case NSStringAttributeType:
                        [self setValue:[NSString stringWithFormat:@"%@", val] forKey:prop.name];
                        break;
                        
                    case NSDateAttributeType:
                        [self setValue:[NSDate dateWithTimeIntervalSince1970:[val doubleValue]] forKey:prop.name];
                        break;
                        
                    case NSInteger16AttributeType:
                    case NSInteger32AttributeType:
                    case NSInteger64AttributeType:
                        [self setValue:[NSNumber numberWithInt:[val intValue]] forKey:prop.name];
                        break;
                        
                    case NSDecimalAttributeType:
                    case NSDoubleAttributeType:
                        [self setValue:[NSNumber numberWithDouble:[val doubleValue]] forKey:prop.name];
                        break;
                        
                    case NSFloatAttributeType:
                        [self setValue:[NSNumber numberWithFloat:[val floatValue]] forKey:prop.name];
                        break;
                        
                    case NSBooleanAttributeType:
                        [self setValue:[NSNumber numberWithBool:[val boolValue]] forKey:prop.name];
                        break;
                }
            } else if ([prop.userInfo objectForKey:@"local"]) {
                // Persisted property. Don't nullify.
            } else {
                [self setNilValueForKey:prop.name];
            }
        }
    }

    if ([self respondsToSelector:@selector(jsonData)]) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
        [self setValue:data forKey:@"jsonData"];
    }
}

- (void)awakeFromRemoteWithContext:(NSManagedObjectContext*)moc
{
    [moc performBlockAndWait:^{
        if ([self respondsToSelector:@selector(updated_at)]) [self setValue:[NSDate date] forKey:@"updated_at"];
        [self awakeFromRemoteWithJson:_json context:moc];
    }];
}

// This is roughly equivalent to a "before_save" hook.
- (void)awakeFromRemoteWithJson:(id)json context:(NSManagedObjectContext*)moc
{
}

- (id)json {
    if (_json) return _json;

    if ([self respondsToSelector:@selector(jsonData)] && [self valueForKey:@"jsonData"]) {
        NSError* error = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:[self valueForKey:@"jsonData"]
                                                options:NSJSONReadingAllowFragments
                                                  error:&error];
        if (!error) _json = obj;
    }

    return _json;
}

- (void)copyAttributesFrom:(id)otherObject
                     named:(NSArray*)attributeNames
                 excluding:(NSArray*)excludedAttributeNames
            preserveLocals:(BOOL)preserveLocals {

    if ([otherObject isKindOfClass:[self class]]) {
        for (NSPropertyDescription* prop in [self entity]) {
            if ([excludedAttributeNames containsObject:prop.name])
                continue;

            if (preserveLocals && [prop.userInfo objectForKey:@"local"])
                continue;

            if (!attributeNames || [attributeNames containsObject:prop.name]) {
                id otherValue = [otherObject valueForKey:prop.name];
                [self setValue:otherValue forKey:prop.name];
            }
        }
    }
}

- (void)copyLocalAttributesFrom:(id)otherObject {
    if ([otherObject isKindOfClass:[self class]]) {
        for (NSPropertyDescription* prop in [self entity]) {
            if ([prop.userInfo objectForKey:@"local"]) {
                [self setValue:[otherObject valueForKey:prop.name] forKey:prop.name];
            }
        }
    }
}

@end
