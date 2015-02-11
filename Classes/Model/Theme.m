#import "App.h"
#import "Theme.h"

@interface Theme ()

// Private interface goes here.

@end

static Theme *current;

@implementation Theme

@synthesize facebookBlue;

+(Theme*)current {
    if(current == nil)
        current = [Theme defaultTheme];
    return current;
}

+(void)setCurrent:(Theme*)theme {
    current = theme;
}

+(Theme*) defaultTheme {
    static Theme *theme;
    if (theme == nil) {
        theme = [[Theme findByIds:@[@"remote"] inContext:[App moc]] lastObject];
        if (!theme) {
            theme = [Theme findOrCreateById:@"default" inContext:[App moc]];
            [theme loadDefaults];
        }
    }
    return theme;
}

-(void)loadDefaults {
    
    // Colors
    self.blackColor = @"#232C33";
    self.blueColor = @"#69d2e7";
    self.darkBlueColor = @"#556270";
    self.lightBlueColor = @"#a7dbd8";
    self.whiteColor = @"#FFFFFF";

    self.darkGrayColor = @"#6D6D6D";
    self.grayColor = @"#B4B4B4";
    self.lightGrayColor = @"#dcdcdc";

    self.greenColor = @"#D5F26D";
    self.turquoiseColor = @"#4ecdc4";
    self.purpleColor = @"#a13d95";
    self.orangeColor = @"#fa6900";
    self.pinkColor = @"#ff6b6b";
    self.redColor = @"#c44d58";
    self.yellowColor = @"#FFC60E";

    self.defaultForegroundColor = @"#354751";
    self.defaultNavigationColor = self.orangeColor;
    self.defaultBackgroundColor = @"#eeeeee"; // self.lightGrayColor;
    self.usernameColor = self.blueColor;
    self.navTitleColor = self.blackColor;
    self.defaultTableTextColor = self.darkGrayColor;

    self.privateColor = self.orangeColor;
    self.friendColor = self.turquoiseColor;
    self.publicColor = self.greenColor;
    self.messageColor = self.purpleColor;
    
    // Fonts
    self.font = @"Lato-Regular";
    self.font_italic = @"Lato-Italic";
    self.font_light = @"Lato-Light";
    self.font_light_italic = @"Lato-LightItalic";
    self.font_bold = @"Lato-Bold";
    self.font_bold_italic = @"Lato-BoldItalic";
    self.font_extrabold = @"Lato-Black";
    self.font_extrabold_italic = @"Lato-BlackItalic";
}

- (NSString*)facebookBlue {
    return @"#3B5998";
}

#pragma mark Colors
- (UIColor *)randomColorWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    NSParameterAssert(saturation && brightness && alpha);
    return [UIColor colorWithHue:arc4random() % 256 / 256.0 saturation:saturation brightness:brightness alpha:alpha];
}

- (UIColor *)randomColor {
    return [self randomColorWithSaturation:1.0 brightness:1.0 alpha:1.0];
}

#pragma mark - Fonts
- (float)osVersion {
    static NSNumber *version;
    if(!version)
        version = [NSNumber numberWithFloat: [[[UIDevice currentDevice] systemVersion] floatValue]];
    return [version floatValue];
}

- (UIFont *)fontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font size:size];
}

- (UIFont *)italicFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_italic size:size];
}

- (UIFont *)lightFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_light size:size];
}

- (UIFont *)lightItalicFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_light_italic size:size];
}

- (UIFont *)boldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_bold size:size];
}

- (UIFont *)boldItalicFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_bold_italic size:size];
}

- (UIFont *)extraBoldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_extrabold size:size];
}

- (UIFont *)extraBoldItalicFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:self.font_extrabold_italic size:size];
}

- (UIFont *)usernameFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-BoldCondensed" size:size];
}

- (UIFont *)headlineFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"LicensePlate" size:size];
}

- (UIColor*)cachedColorFromHexString:(NSString *)hexString {
    static NSMutableDictionary* colorCache;
    if (!colorCache) colorCache = [NSMutableDictionary new];

    UIColor* color = colorCache[hexString];
    if (!color) {
        color = [UIColor colorFromHexString:hexString];
        colorCache[hexString] = color;
    }
    return color;
}

@end

@implementation UIColor (Utilities)

- (UIColor *)complement {
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    int degreesToAdd = 180;
    int hueInt = hue * 256;
    if ((hueInt + degreesToAdd) <= 360) {
        hueInt += degreesToAdd;
    } else {
        hueInt = 360 - hueInt;
    }
    
    return [UIColor colorWithHue:hueInt / 256.0 saturation:saturation brightness:brightness alpha:alpha];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
