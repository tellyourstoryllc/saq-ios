#import "UserGroupPreference.h"
#import "App.h"

@interface UserGroupPreference ()

// Private interface goes here.

@end


@implementation UserGroupPreference

+(UserGroupPreference*)forGroup:(Group*)group {
    if (!group) return nil;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"group_id = %@", group.id];
    return [[self findAllUsingPredicate:pred inContext:[App moc]] lastObject];
}

@end
