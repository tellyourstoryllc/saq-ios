#import "_Theme.h"

#define THEME [Theme current]
#define COLOR(colorName) [THEME cachedColorFromHexString:[THEME colorName]]
#define COLOR_ALPHA(colorName, alpha) [[THEME cachedColorFromHexString:[THEME colorName]] colorWithAlphaComponent:alpha]

#define FONT(size) [THEME fontWithSize:size]
#define FONT_I(size) [THEME italicFontWithSize:size]
#define FONT_B(size) [THEME boldFontWithSize:size]
#define FONT_BI(size) [THEME boldItalicFontWithSize:size]

#define USERFONT(size) [THEME usernameFontWithSize:size]
#define HEADFONT(size) [THEME headlineFontWithSize:size]

@interface Theme : _Theme {}
+(Theme*)current;

#pragma mark - Colors
- (UIColor *)randomColorWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (UIColor *)randomColor;

@property (nonatomic, strong) NSString* facebookBlue;

#pragma mark - Fonts
- (UIFont *)fontWithSize:(CGFloat)size;
- (UIFont *)italicFontWithSize:(CGFloat)size;

- (UIFont *)boldFontWithSize:(CGFloat)size;
- (UIFont *)boldItalicFontWithSize:(CGFloat)size;

- (UIFont *)lightFontWithSize:(CGFloat)size;
- (UIFont *)lightItalicFontWithSize:(CGFloat)size;

- (UIFont *)extraBoldFontWithSize:(CGFloat)size;
- (UIFont *)extraBoldItalicFontWithSize:(CGFloat)size;

- (UIFont *)usernameFontWithSize:(CGFloat)size;
- (UIFont *)headlineFontWithSize:(CGFloat)size;

- (UIColor*)cachedColorFromHexString:(NSString *)hexString;

@end

@interface UIColor (Utilities)
- (UIColor *)complement;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end
