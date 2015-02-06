#import "_Emoticon.h"

#define kEmoticonLoadedNotification @"emoticon_loaded"

@interface Emoticon : _Emoticon {}

+(NSMutableAttributedString*) emoticonStringForString:(NSString*) string;

@end
