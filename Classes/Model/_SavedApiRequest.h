// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SavedApiRequest.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct SavedApiRequestAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *data2_filepath;
	__unsafe_unretained NSString *data2_mimetype;
	__unsafe_unretained NSString *data2_param;
	__unsafe_unretained NSString *data_filepath;
	__unsafe_unretained NSString *data_mimetype;
	__unsafe_unretained NSString *data_param;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *jsonData;
	__unsafe_unretained NSString *request_path;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *upload_attempts;
} SavedApiRequestAttributes;

extern const struct SavedApiRequestRelationships {
	__unsafe_unretained NSString *placeholder;
} SavedApiRequestRelationships;

@class SkyMessage;

@interface SavedApiRequestID : NSManagedObjectID {}
@end

@interface _SavedApiRequest : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SavedApiRequestID* objectID;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data2_filepath;

//- (BOOL)validateData2_filepath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data2_mimetype;

//- (BOOL)validateData2_mimetype:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data2_param;

//- (BOOL)validateData2_param:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data_filepath;

//- (BOOL)validateData_filepath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data_mimetype;

//- (BOOL)validateData_mimetype:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* data_param;

//- (BOOL)validateData_param:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* jsonData;

//- (BOOL)validateJsonData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* request_path;

//- (BOOL)validateRequest_path:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* status;

@property (atomic) int16_t statusValue;
- (int16_t)statusValue;
- (void)setStatusValue:(int16_t)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* upload_attempts;

@property (atomic) int16_t upload_attemptsValue;
- (int16_t)upload_attemptsValue;
- (void)setUpload_attemptsValue:(int16_t)value_;

//- (BOOL)validateUpload_attempts:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) SkyMessage *placeholder;

//- (BOOL)validatePlaceholder:(id*)value_ error:(NSError**)error_;

@end

@interface _SavedApiRequest (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveData2_filepath;
- (void)setPrimitiveData2_filepath:(NSString*)value;

- (NSString*)primitiveData2_mimetype;
- (void)setPrimitiveData2_mimetype:(NSString*)value;

- (NSString*)primitiveData2_param;
- (void)setPrimitiveData2_param:(NSString*)value;

- (NSString*)primitiveData_filepath;
- (void)setPrimitiveData_filepath:(NSString*)value;

- (NSString*)primitiveData_mimetype;
- (void)setPrimitiveData_mimetype:(NSString*)value;

- (NSString*)primitiveData_param;
- (void)setPrimitiveData_param:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSData*)primitiveJsonData;
- (void)setPrimitiveJsonData:(NSData*)value;

- (NSString*)primitiveRequest_path;
- (void)setPrimitiveRequest_path:(NSString*)value;

- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (int16_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int16_t)value_;

- (NSNumber*)primitiveUpload_attempts;
- (void)setPrimitiveUpload_attempts:(NSNumber*)value;

- (int16_t)primitiveUpload_attemptsValue;
- (void)setPrimitiveUpload_attemptsValue:(int16_t)value_;

- (SkyMessage*)primitivePlaceholder;
- (void)setPrimitivePlaceholder:(SkyMessage*)value;

@end
