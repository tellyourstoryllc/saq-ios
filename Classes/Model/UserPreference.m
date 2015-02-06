#import "UserPreference.h"
#import "App.h"

@interface UserPreference ()

// Private interface goes here.

@end


@implementation UserPreference

+(UserPreference*)any {
    return [[self findAllUsingPredicate:nil inContext:[App moc]] lastObject];
}

@end
