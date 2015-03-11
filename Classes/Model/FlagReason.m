#import "FlagReason.h"
#import "App.h"

@interface FlagReason ()

@end

@implementation FlagReason

// Dictionary of text -> id of all flag reasons
+ (NSDictionary*)dictionary {
    NSArray* reasons = [self findAllUsingPredicate:nil inContext:[App moc]];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:reasons.count];
    for (FlagReason* reason in reasons) {
        dict[reason.text] = reason.id;
    }

    if (dict.count == 0)
        dict[@"Submit report"] = @"99";

    return dict;
}

@end
