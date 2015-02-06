#import "_SkyAccount.h"
#import "User.h"

@interface SkyAccount : _SkyAccount {}
+(SkyAccount*)forUser:(User*)user;
+(SkyAccount*)mine;
@end
