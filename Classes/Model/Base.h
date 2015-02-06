#import <CoreData/CoreData.h>

#define kNullIdString   @"__NULL__"

@interface Base : NSManagedObject {}
@property (nonatomic, strong) id json;

// "Find" = synchronous, "Fetch" = asynchronous

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors
                            limit:(NSUInteger)fetchLimit
                           offset:(NSUInteger)fetchOffset
                        inContext:(NSManagedObjectContext*)context;

+ (void)fetchAllUsingPredicate:(NSPredicate*)predicate
                      sortedBy:(id)sortDescriptors
                         limit:(NSUInteger)fetchLimit
                        offset:(NSUInteger)fetchOffset
                     inContext:(NSManagedObjectContext*)context
                    completion:(void (^)(NSArray* results))completion;

+ (id)createWithId:(id)objectId
         inContext:(NSManagedObjectContext*)context;

+ (id)findOrCreateById:(id)objectId
             inContext:(NSManagedObjectContext*)context;

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                        inContext:(NSManagedObjectContext*)context;

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors;

+ (NSArray*)findAllUsingPredicate:(NSPredicate*)predicate
                         sortedBy:(id)sortDescriptors
                            limit:(NSUInteger)fetchLimit;

+ (id)findById:(id)objectId
     inContext:(NSManagedObjectContext*)context;

+ (NSArray*)findByIds:(NSArray*)objectIds
            inContext:(NSManagedObjectContext*)context;

+ (NSString*)entityName;

// Mostly for debugging:
+ (NSUInteger)countUsingPredicate:(NSPredicate*)predicate
                      inContext:(NSManagedObjectContext*)context;

//

+ (void)deleteAll;
+ (void)deleteAllNullIds;
- (void)delete;
- (void)destroyAndSave:(BOOL)shouldSave;
- (void)save;

- (void)processJSONObject:(NSDictionary *)jsonObject;
- (void)awakeFromRemoteWithContext:(NSManagedObjectContext*)moc;
- (void)awakeFromRemoteWithJson:(id)json context:(NSManagedObjectContext*)moc;

- (void)copyAttributesFrom:(id)otherObject
                     named:(NSArray*)attributeNames
                 excluding:(NSArray*)excludedAttributeNames
            preserveLocals:(BOOL)preserveLocals;

- (void)copyLocalAttributesFrom:(id)otherObject;

@end
