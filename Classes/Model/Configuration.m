#import "Configuration.h"
#import "App.h"

@implementation Configuration

+(NSDictionary*)shared {
    NSManagedObjectContext* context = [App rootObjectContext];
    __block NSDictionary* dict = nil;
    [context performBlockAndWait:^{
        Configuration* config = [[self findByIds:@[kNullIdString] inContext:context] firstObject];
        if (config)
            dict = [config json];
    }];
    return dict;
}

+(id)settingFor:(NSString*)key {
    return [[self shared] objectForKey:key];
}

+(NSString*)stringFor:(NSString*)key {
    id setting = [self settingFor:key];
    if ([setting isKindOfClass:[NSString class]]) return setting;
    if ([setting isKindOfClass:[NSNumber class]]) return [setting stringValue];
    if (setting) return [setting description];
    return nil;
}

+(BOOL)boolFor:(NSString*)key {
    id setting = [self settingFor:key];
    if ([setting isKindOfClass:[NSNumber class]]) return [setting boolValue];
    if ([setting isKindOfClass:[NSString class]]) return [setting boolValue];
    return NO;
}

@end
