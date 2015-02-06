#import "Emoticon.h"
#import "NSData+Base64.h"
#import "UIImage+GIF.h"
#import "App.h"

#import "UIImageView+AFNetworking.h"

@interface Emoticon ()
@property (nonatomic) UIImage* image;
@end

@implementation Emoticon

@synthesize image = _image;

-(void)awakeFromRemoteWithJson:(id)json context:(NSManagedObjectContext *)moc {
    [[Emoticon emoticonsByNameInMoc:moc] setObject:self forKey:self.name];
}

+(NSMutableAttributedString*) emoticonStringForString:(NSString*) string {
    if(!string)
        return nil;
    
    // Detect emoticons - O(N)
    NSArray *matches = [[self emoticonRegex] matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableArray *emoticonRanges = [[NSMutableArray alloc] init];
    NSMutableArray *emoticons = [[NSMutableArray alloc] init];
    
    // Load emoticons and remember their locations - O(N)
    for (NSTextCheckingResult *match in matches) {
        NSString *name = [string substringWithRange:[match rangeAtIndex:0]];
        Emoticon *emoticon = [[Emoticon emoticonsByNameInMoc:[App privateManagedObjectContext]] objectForKey:name];
        if(emoticon) {
            [emoticonRanges addObject:[NSValue valueWithRange:[match rangeAtIndex:0]]];
            [emoticons addObject:emoticon];
        }
    }
    
    // Construct emoticon string - O(N)
    NSMutableAttributedString *emoString = [[NSMutableAttributedString alloc] init];
    
    for (int emoIdx = 0, offset = 0; true; emoIdx++) {
        
        // No more emoticons; append remaining characters
        if(emoIdx == emoticons.count) {
            [emoString appendAttributedString:[[NSAttributedString alloc] initWithString: [string substringWithRange:NSMakeRange(offset, string.length - offset)]]];
            break;
        }
        
        // Prepare emoticon image
        Emoticon *emoticon = [emoticons objectAtIndex:emoIdx];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = emoticon.image;
        
        // Insert emoticon and text preceeding it
        NSRange emoRange = [[emoticonRanges objectAtIndex:emoIdx] rangeValue];
        int emoOffset = emoRange.location;
        [emoString appendAttributedString:[[NSAttributedString alloc] initWithString: [string substringWithRange:NSMakeRange(offset, emoOffset - offset)]]];
        [emoString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        // Jump to end of emoticon
        offset = emoOffset + emoRange.length;
    }
    return emoString;
}

+(NSRegularExpression*)emoticonRegex {
    static NSRegularExpression *pattern = nil;
    if(!pattern)
        pattern = [NSRegularExpression regularExpressionWithPattern:@"\\:\\w+\\:" options:0 error:nil];
    return pattern;
}

+(NSMutableDictionary*) emoticonsByNameInMoc:(NSManagedObjectContext*)context {
    static NSMutableDictionary *cache = nil;
    if(!cache) {
        cache = [[NSMutableDictionary alloc] init];
        NSArray *emoticons = [Emoticon findAllUsingPredicate:nil inContext:context];
        for(Emoticon *emoticon in emoticons)
            [cache setObject:emoticon forKey:emoticon.name];
    }
    return cache;
}

// Hack to use AFNetworking's image cache
-(UIImage*) image {
    
    if(_image)
        return _image;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: self.image_url]];
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if(response != nil) {
            _image = image;
            [[NSNotificationCenter defaultCenter] postNotificationName: kEmoticonLoadedNotification object:self];
        }
    } failure:nil];
    return [Emoticon placeholder];
}

+(UIImage*) placeholder {
    static UIImage *image;
    if(!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, 0.0);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
