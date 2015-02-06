#import "IosPreference.h"
#import "App.h"

@interface IosPreference ()

// Private interface goes here.

@end


@implementation IosPreference

+(IosPreference*)any {
    return [[self findAllUsingPredicate:nil inContext:[App moc]] lastObject];
}

@end
