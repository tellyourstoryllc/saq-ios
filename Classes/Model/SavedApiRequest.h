#import "_SavedApiRequest.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, MediaUploadStatus) {
    MediaUploadStatusPending,
    MediaUploadStatusProcessing,
    MediaUploadStatusCompleted,
    MediaUploadStatusCancelled,
};

@interface SavedApiRequest : _SavedApiRequest {}

+ (NSArray*)allRequestsInContext:(NSManagedObjectContext*)context;
+ (NSArray*)pendingRequestsInContext:(NSManagedObjectContext*)context;

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType
                                data2URL:(NSURL*)data2URL
                              data2Param:(NSString*)data2Param
                           data2MimeType:(NSString*)data2MimeType;

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                    data:(NSData*)data
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType
                                   data2:(NSData*)data2
                              data2Param:(NSString*)data2Param
                           data2MimeType:(NSString*)data2MimeType;

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType
                                   data2:(NSData*)data2
                              data2Param:(NSString*)data2Param
                           data2MimeType:(NSString*)data2MimeType;

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                    data:(NSData*)data
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType;

+ (SavedApiRequest*)storeRequestWithPath:(NSString*)path
                              parameters:(NSDictionary*)params
                                 dataURL:(NSURL*)dataURL
                               dataParam:(NSString*)dataParam
                            dataMimeType:(NSString*)dataMimeType;

+ (void)removeRequestWithId:(NSString*)requestId
                fromContext:(NSManagedObjectContext*)context;

+ (AFHTTPRequestOperation*)operationForStoredRequest:(SavedApiRequest*)mediaUpload
                                         andCallback:(void(^)(NSData *data, NSHTTPURLResponse *response, id result, NSSet* entities, NSError *error))callback;

- (AFHTTPRequestOperation*)requestOperationWithCallback:(void(^)(NSData *data, NSHTTPURLResponse *response, id result, NSSet* entities, NSError *error))callback;

@end

@interface MediaUploadManager : NSObject
+(MediaUploadManager*)manager;
-(void)retryUploadsWithLimit:(NSUInteger)limit;
@end
