#import "SavedApiRequest.h"
#import "Api.h"
#import "App.h"

#import "UploadProgressAlertView.h"
#import "PNBackgroundTaskElf.h"

@interface SavedApiRequest ()

@end

@implementation SavedApiRequest

+(dispatch_queue_t) callbackQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.perceptualnet.media_upload",  DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

+ (NSArray*)allRequestsInContext:(NSManagedObjectContext*)context
{
    return [SavedApiRequest findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id != NULL"]
                                         sortedBy:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]
                                            limit:0
                                           offset:0
                                        inContext:context];
}

+ (NSArray*)pendingRequestsInContext:(NSManagedObjectContext*)context
{
    return [SavedApiRequest findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id != NULL AND status == %@", @(MediaUploadStatusPending)]
                                         sortedBy:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]
                                            limit:0
                                           offset:0
                                        inContext:context];
}

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType
                                data2URL:(NSURL*)data2URL
                              data2Param:(NSString*)data2Param
                           data2MimeType:(NSString*)data2MimeType
{
    NSString* newId = [NSString stringWithFormat:@"request-%f", [[NSDate date] timeIntervalSince1970]];
    NSString* ssId = [NSString stringWithFormat:@"request_ss-%f", [[NSDate date] timeIntervalSince1970]];

    NSString *documentsDirectory = [PNSupport documentPath];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%@.%@", newId, [dataURL pathExtension]];
    NSString *ssPath;

    NSError* err = nil;
    NSError* errr = nil;
    [[NSFileManager defaultManager] moveItemAtURL:dataURL toURL:[NSURL fileURLWithPath:tempPath] error:&err];

    if (data2URL) {
        ssPath = [documentsDirectory stringByAppendingFormat:@"/%@.%@", ssId, [data2URL pathExtension]];
        [[NSFileManager defaultManager] moveItemAtURL:data2URL toURL:[NSURL fileURLWithPath:ssPath] error:&errr];
    }

    if (!err && !errr) {
        SavedApiRequest* newItem = [SavedApiRequest findOrCreateById:newId inContext:[App moc]];
        [newItem.managedObjectContext performBlockAndWait:^{
            newItem.request_path = path;
            if (params) newItem.jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            newItem.data_filepath = tempPath;
            newItem.data_param = dataParam;
            newItem.data_mimetype = dataMimeType;
            newItem.status = @(MediaUploadStatusPending);

            if (data2URL) {
                newItem.data2_filepath = ssPath;
                newItem.data2_param= data2Param;
                newItem.data2_mimetype = data2MimeType;
            }

            [newItem save];
        }];
        return newItem;

    } else {
        return nil;
    }
}

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                          parameters:(NSDictionary*)params
                                data:(NSData*)data
                           dataParam:(NSString*)dataParam
                        dataMimeType:(NSString*)dataMimeType
                               data2:(NSData*)data2
                          data2Param:(NSString*)data2Param
                       data2MimeType:(NSString*)data2MimeType
{
    NSString* newId = [NSString stringWithFormat:@"request-%f", [[NSDate date] timeIntervalSince1970]];
    NSString* ssId = [NSString stringWithFormat:@"request_ss-%f", [[NSDate date] timeIntervalSince1970]];

    // Save data file
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *tempPath = [tempDirectory stringByAppendingFormat:@"/%@.%@", newId, dataMimeType.lastPathComponent];
    NSString *ssPath = [tempDirectory stringByAppendingFormat:@"/%@.%@", ssId, data2MimeType.lastPathComponent];

    BOOL success = [data writeToFile:tempPath atomically:NO];
    BOOL succe_ss = data2 ? [data2 writeToFile:ssPath atomically:NO] : YES;

    if (success && succe_ss) {
        NSURL* data2URL = data2 ? [NSURL fileURLWithPath:ssPath] : nil;
        return [self storeRequestWithPath:path
                               parameters:params
                                  dataURL:[NSURL fileURLWithPath:tempPath]
                                dataParam:dataParam
                             dataMimeType:dataMimeType
                                 data2URL:data2URL
                               data2Param:data2Param
                            data2MimeType:data2MimeType];
    } else {
        return nil;
    }
}

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType
                                   data2:(NSData*)data2
                              data2Param:(NSString*)data2Param
                           data2MimeType:(NSString*)data2MimeType {

    NSString* newId = [NSString stringWithFormat:@"request-%f", [[NSDate date] timeIntervalSince1970]];
    NSString* ssId = [NSString stringWithFormat:@"request_ss-%f", [[NSDate date] timeIntervalSince1970]];

    NSString *documentsDirectory = [PNSupport documentPath];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%@.%@", newId, [dataURL pathExtension]];

    NSError* err = nil;
    [[NSFileManager defaultManager] moveItemAtURL:dataURL toURL:[NSURL fileURLWithPath:tempPath] error:&err];
    BOOL success = YES;
    NSString *ssPath = nil;

    if (data2) {
        ssPath = [documentsDirectory stringByAppendingFormat:@"/%@.%@", ssId, data2MimeType.lastPathComponent];
        success = data2 ? [data2 writeToFile:ssPath atomically:NO] : YES;
    }

    if (!err && success) {
        SavedApiRequest* newItem = [SavedApiRequest findOrCreateById:newId inContext:[App moc]];
        [newItem.managedObjectContext performBlockAndWait:^{
            newItem.request_path = path;
            if (params) newItem.jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            newItem.data_filepath = tempPath;
            newItem.data_param = dataParam;
            newItem.data_mimetype = dataMimeType;
            newItem.status = @(MediaUploadStatusPending);

            if (data2) {
                newItem.data2_filepath = ssPath;
                newItem.data2_param = data2Param;
                newItem.data2_mimetype = data2MimeType;
            }

            [newItem save];
        }];
        return newItem;

    } else {
        return nil;
    }
}

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                    data:(NSData*)data
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType {
    return [self storeRequestWithPath:path parameters:params data:data dataParam:dataParam dataMimeType:dataMimeType
                                data2:nil data2Param:nil data2MimeType:nil];

}

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType {
    return [self storeRequestWithPath:path parameters:params dataURL:dataURL dataParam:dataParam dataMimeType:dataMimeType
                                data2:nil data2Param:nil data2MimeType:nil];
}

+ (void)removeRequestWithId:(NSString*)requestId
                fromContext:(NSManagedObjectContext*)context {
    SavedApiRequest* savedItem = [[SavedApiRequest findByIds:@[requestId] inContext:context] lastObject];
    [savedItem delete];
}

+ (AFHTTPRequestOperation*)operationForStoredRequest:(SavedApiRequest*)mediaUpload
                                         andCallback:(PNAPIRequestCallback)callback {

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:8];

    id jsonObject = [mediaUpload json];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
        [params addEntriesFromDictionary:jsonObject];

    __block NSString* mediaUploadId = mediaUpload.id;
    __weak SavedApiRequest* weakUpload = mediaUpload;

    void(^callbackWithCleanup)(NSData*, NSHTTPURLResponse*, id, NSSet*, NSError*) =
    ^void(NSData *data, NSHTTPURLResponse *response, id result, NSSet* entities, NSError *error){

        __block NSSet* entityIds = [entities valueForKey:@"objectID"];

        dispatch_async([self callbackQueue], ^{
            NSManagedObjectContext* context = [App privateManagedObjectContext];

            if (error) {
                NSLog(@"!!! ERROR on media upload operation %@: %@, %@", mediaUploadId, response, error);
                weakUpload.statusValue = MediaUploadStatusPending;
            }

            if (!error || response.statusCode == 500 || response.statusCode == 422) {
                [context performBlockAndWait:^{
                    [self removeRequestWithId:mediaUploadId fromContext:context];
                    [context save:nil];
                }];
            }

            NSArray* entityArray = [[entityIds allObjects] mapUsingBlock:^id(id objID) {
                return [context objectWithID:objID];
            }];
            NSSet* entitiesInContext = [NSSet setWithArray:entityArray];
            callback(data, response, result, entitiesInContext, error);

        });
    };

    AFHTTPRequestOperation* op;
    __block BOOL errorConstructingRequest = NO;
    op = [[Api slowApi] multipartRequestOperationWithHTTPMethod:@"POST"
                                                           path:mediaUpload.request_path
                                                     parameters:params
                                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                          if (mediaUpload.data_filepath && mediaUpload.data_param) {
                                              NSError* err;
                                              [formData appendPartWithFileURL:[NSURL fileURLWithPath:mediaUpload.data_filepath]
                                                                         name:mediaUpload.data_param
                                                                     fileName:[mediaUpload.data_filepath lastPathComponent]
                                                                     mimeType:mediaUpload.data_mimetype
                                                                        error:&err];
                                              if (err) {
                                                  errorConstructingRequest = YES;
                                                  NSLog(@"error creating media upload request: %@", err);
                                              }
                                          }

                                          if (mediaUpload.data2_filepath && mediaUpload.data2_param) {
                                              NSError* err;
                                              [formData appendPartWithFileURL:[NSURL fileURLWithPath:mediaUpload.data2_filepath]
                                                                         name:mediaUpload.data2_param
                                                                     fileName:[mediaUpload.data2_filepath lastPathComponent]
                                                                     mimeType:mediaUpload.data2_mimetype
                                                                        error:&err];
                                              if (err) {
                                                  errorConstructingRequest = YES;
                                                  NSLog(@"error creating media upload request: %@", err);
                                              }
                                          }
                                      }
                                                    andCallback:callbackWithCleanup];

    if (errorConstructingRequest)
        return nil;
    else {
        [weakUpload.KVOController observe:op keyPaths:@[@"executing", @"finished"]
                                  options:NSKeyValueObservingOptionNew
                                    block:^(id observer, id object, NSDictionary *change) {
                                        NSOperation* operation = (NSOperation*)object;
                                        if (operation.isExecuting)
                                            weakUpload.statusValue = MediaUploadStatusProcessing;
                                        else if (operation.isFinished)
                                            weakUpload.statusValue = MediaUploadStatusCompleted;
                                    }];

        return op;
    }
}

- (AFHTTPRequestOperation*)requestOperationWithCallback:(void(^)(NSData *data, NSHTTPURLResponse *response, id result, NSSet* entities, NSError *error))callback {
    return [SavedApiRequest operationForStoredRequest:self andCallback:callback];
}

- (void)prepareForDeletion {
    // Delete the data files
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.data_filepath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:self.data2_filepath error:&error];

    // Delete placeholders
    if (self.statusValue == MediaUploadStatusCancelled) {
        id jsonObject = [self json];
        if (jsonObject[@"client_metadata"]) {
            id clientMetadata = [NSJSONSerialization JSONObjectWithData:[jsonObject[@"client_metadata"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:0
                                                                  error:nil];
            NSString *placeholder_id = clientMetadata[@"placeholder"];
            if (placeholder_id) {
                NSArray* placeholders = [SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id BEGINSWITH %@", placeholder_id ] inContext:self.managedObjectContext];
                for (SkyMessage* message in placeholders) {
                    [message delete];
                }
            }
        }
    }
}

@end

@interface MediaUploadManager()
@property (nonatomic, strong) NSMutableDictionary* taskIdentifiers;
@end

@implementation MediaUploadManager

+(MediaUploadManager*)manager {

    static MediaUploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MediaUploadManager alloc] init];
    });

    return manager;
}

-(void)retryUploadsWithLimit:(NSUInteger)limit {
    if (!limit) return;
    on_background(^{
        NSArray* uploadIds = [[SavedApiRequest pendingRequestsInContext:[App privateManagedObjectContext]] valueForKey:@"id"];
        [self _retryUploads:uploadIds withLimit:limit];
    });
}

-(void)_retryUploads:(NSArray*)mediaUploadIds
            withLimit:(NSUInteger)limit {

    NSLog(@"pending media uploads: %d", mediaUploadIds.count);

    if (limit && mediaUploadIds.count) {
        [PNBackgroundTaskElf
         doIt:^(PNBackgroundTaskElf *elf) {
             NSManagedObjectContext* context = [App privateManagedObjectContext];
             SavedApiRequest* upload = [SavedApiRequest findById:mediaUploadIds.firstObject inContext:context];
             AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {
                 [elf doneIt];
                 if (!error && [context save:nil])
                     [self _retryUploads:[mediaUploadIds arrayWithoutFirstObject] withLimit:limit-1];

                 if (error)
                     NSLog(@"media upload error: %@", error);
             }];

             if (uploadOperation) {
                 NSLog(@"retrying upload %@", upload.jsonData);
                 [[Api slowApi] enqueueOperation:uploadOperation];
             }
             else {
                 NSLog(@"no operation for mediaupload. deleting! %@", upload.id);
                 [upload delete];
                 [context save:nil];
                 [elf doneIt];
                 on_background(^{
                     [self _retryUploads:[mediaUploadIds arrayWithoutFirstObject] withLimit:limit];
                 });
             }
         }
         onExpiration:^{
             PNLOG(@"background.task.expired.retryUploadsWithLimit");
         }];
    }
}

@end
