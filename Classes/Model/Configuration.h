#import "_Configuration.h"

@interface Configuration : _Configuration {}

+(NSDictionary*)shared;

+(id)settingFor:(NSString*)key;
+(NSString*)stringFor:(NSString*)key;

// Setting as BOOL value. Defaults to NO if not found.
+(BOOL)boolFor:(NSString*)key;

@end
