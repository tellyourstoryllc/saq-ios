#import "SkyAccount.h"
#import "App.h"

@interface SkyAccount ()
@end

@implementation SkyAccount

+(SkyAccount*)forUser:(User*)user {
    if (!user) return nil;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"user_id = %@", user.id];
    return [[self findAllUsingPredicate:pred inContext:[App moc]] lastObject];
}

+(SkyAccount*)mine {
    return [self forUser:[User me]];
}

@end
