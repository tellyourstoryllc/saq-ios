// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Theme.m instead.

#import "_Theme.h"

const struct ThemeAttributes ThemeAttributes = {
	.blackColor = @"blackColor",
	.blueColor = @"blueColor",
	.created_at = @"created_at",
	.darkBlueColor = @"darkBlueColor",
	.darkGrayColor = @"darkGrayColor",
	.defaultBackgroundColor = @"defaultBackgroundColor",
	.defaultForegroundColor = @"defaultForegroundColor",
	.defaultNavigationColor = @"defaultNavigationColor",
	.defaultTableTextColor = @"defaultTableTextColor",
	.font = @"font",
	.font_bold = @"font_bold",
	.font_bold_italic = @"font_bold_italic",
	.font_extrabold = @"font_extrabold",
	.font_extrabold_italic = @"font_extrabold_italic",
	.font_italic = @"font_italic",
	.font_light = @"font_light",
	.font_light_italic = @"font_light_italic",
	.friendColor = @"friendColor",
	.grayColor = @"grayColor",
	.greenColor = @"greenColor",
	.id = @"id",
	.lightBlueColor = @"lightBlueColor",
	.lightGrayColor = @"lightGrayColor",
	.messageColor = @"messageColor",
	.navTitleColor = @"navTitleColor",
	.orangeColor = @"orangeColor",
	.pinkColor = @"pinkColor",
	.privateColor = @"privateColor",
	.publicColor = @"publicColor",
	.purpleColor = @"purpleColor",
	.redColor = @"redColor",
	.turquoiseColor = @"turquoiseColor",
	.updated_at = @"updated_at",
	.usernameColor = @"usernameColor",
	.whiteColor = @"whiteColor",
	.yellowColor = @"yellowColor",
};

@implementation ThemeID
@end

@implementation _Theme

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Theme";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Theme" inManagedObjectContext:moc_];
}

- (ThemeID*)objectID {
	return (ThemeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic blackColor;

@dynamic blueColor;

@dynamic created_at;

@dynamic darkBlueColor;

@dynamic darkGrayColor;

@dynamic defaultBackgroundColor;

@dynamic defaultForegroundColor;

@dynamic defaultNavigationColor;

@dynamic defaultTableTextColor;

@dynamic font;

@dynamic font_bold;

@dynamic font_bold_italic;

@dynamic font_extrabold;

@dynamic font_extrabold_italic;

@dynamic font_italic;

@dynamic font_light;

@dynamic font_light_italic;

@dynamic friendColor;

@dynamic grayColor;

@dynamic greenColor;

@dynamic id;

@dynamic lightBlueColor;

@dynamic lightGrayColor;

@dynamic messageColor;

@dynamic navTitleColor;

@dynamic orangeColor;

@dynamic pinkColor;

@dynamic privateColor;

@dynamic publicColor;

@dynamic purpleColor;

@dynamic redColor;

@dynamic turquoiseColor;

@dynamic updated_at;

@dynamic usernameColor;

@dynamic whiteColor;

@dynamic yellowColor;

@end

