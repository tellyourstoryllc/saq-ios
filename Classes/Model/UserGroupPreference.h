#import "_UserGroupPreference.h"
#import "Group.h"

@interface UserGroupPreference : _UserGroupPreference {}
+(UserGroupPreference*)forGroup:(Group*)group;
@end
