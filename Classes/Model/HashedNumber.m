#import "HashedNumber.h"
#import "NSString+PhoneNumber.h"
#import "NSString+SHA256.h"

@interface HashedNumber ()

// Private interface goes here.

@end


@implementation HashedNumber

+ (NSString*)hashForNumber:(NSString*)phone_number {
    return [phone_number.normalizedPhoneNumber sha256];
}

- (void)willSave {
    if (self.phone_number && ![self.id isEqualToString:[self.class hashForNumber:self.phone_number]])
        self.primitivePhone_number = nil;
}

@end
