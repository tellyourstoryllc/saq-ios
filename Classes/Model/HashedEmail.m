#import "HashedEmail.h"
#import "NSString+Email.h"
#import "NSString+SHA256.h"

@interface HashedEmail ()

// Private interface goes here.

@end


@implementation HashedEmail

+ (NSString*)hashForEmail:(NSString*)email {
    return [email.normalizedEmail sha256];
}

- (void)willSave {
    if (self.email && ![self.id isEqualToString:[self.class hashForEmail:self.email]])
        self.primitiveEmail = nil;
}

@end
