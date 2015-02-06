// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Theme.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct ThemeAttributes {
	__unsafe_unretained NSString *blackColor;
	__unsafe_unretained NSString *blueColor;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *darkBlueColor;
	__unsafe_unretained NSString *darkGrayColor;
	__unsafe_unretained NSString *defaultBackgroundColor;
	__unsafe_unretained NSString *defaultForegroundColor;
	__unsafe_unretained NSString *defaultNavigationColor;
	__unsafe_unretained NSString *defaultTableTextColor;
	__unsafe_unretained NSString *font;
	__unsafe_unretained NSString *font_bold;
	__unsafe_unretained NSString *font_bold_italic;
	__unsafe_unretained NSString *font_extrabold;
	__unsafe_unretained NSString *font_extrabold_italic;
	__unsafe_unretained NSString *font_italic;
	__unsafe_unretained NSString *font_light;
	__unsafe_unretained NSString *font_light_italic;
	__unsafe_unretained NSString *friendColor;
	__unsafe_unretained NSString *grayColor;
	__unsafe_unretained NSString *greenColor;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *lightBlueColor;
	__unsafe_unretained NSString *lightGrayColor;
	__unsafe_unretained NSString *messageColor;
	__unsafe_unretained NSString *navTitleColor;
	__unsafe_unretained NSString *orangeColor;
	__unsafe_unretained NSString *pinkColor;
	__unsafe_unretained NSString *privateColor;
	__unsafe_unretained NSString *publicColor;
	__unsafe_unretained NSString *purpleColor;
	__unsafe_unretained NSString *redColor;
	__unsafe_unretained NSString *turquoiseColor;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *usernameColor;
	__unsafe_unretained NSString *whiteColor;
	__unsafe_unretained NSString *yellowColor;
} ThemeAttributes;

@interface ThemeID : NSManagedObjectID {}
@end

@interface _Theme : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ThemeID* objectID;

@property (nonatomic, strong) NSString* blackColor;

//- (BOOL)validateBlackColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* blueColor;

//- (BOOL)validateBlueColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* darkBlueColor;

//- (BOOL)validateDarkBlueColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* darkGrayColor;

//- (BOOL)validateDarkGrayColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* defaultBackgroundColor;

//- (BOOL)validateDefaultBackgroundColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* defaultForegroundColor;

//- (BOOL)validateDefaultForegroundColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* defaultNavigationColor;

//- (BOOL)validateDefaultNavigationColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* defaultTableTextColor;

//- (BOOL)validateDefaultTableTextColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font;

//- (BOOL)validateFont:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_bold;

//- (BOOL)validateFont_bold:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_bold_italic;

//- (BOOL)validateFont_bold_italic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_extrabold;

//- (BOOL)validateFont_extrabold:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_extrabold_italic;

//- (BOOL)validateFont_extrabold_italic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_italic;

//- (BOOL)validateFont_italic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_light;

//- (BOOL)validateFont_light:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* font_light_italic;

//- (BOOL)validateFont_light_italic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* friendColor;

//- (BOOL)validateFriendColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* grayColor;

//- (BOOL)validateGrayColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* greenColor;

//- (BOOL)validateGreenColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lightBlueColor;

//- (BOOL)validateLightBlueColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lightGrayColor;

//- (BOOL)validateLightGrayColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* messageColor;

//- (BOOL)validateMessageColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* navTitleColor;

//- (BOOL)validateNavTitleColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* orangeColor;

//- (BOOL)validateOrangeColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* pinkColor;

//- (BOOL)validatePinkColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* privateColor;

//- (BOOL)validatePrivateColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* publicColor;

//- (BOOL)validatePublicColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* purpleColor;

//- (BOOL)validatePurpleColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* redColor;

//- (BOOL)validateRedColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* turquoiseColor;

//- (BOOL)validateTurquoiseColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* usernameColor;

//- (BOOL)validateUsernameColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* whiteColor;

//- (BOOL)validateWhiteColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* yellowColor;

//- (BOOL)validateYellowColor:(id*)value_ error:(NSError**)error_;

@end

@interface _Theme (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveBlackColor;
- (void)setPrimitiveBlackColor:(NSString*)value;

- (NSString*)primitiveBlueColor;
- (void)setPrimitiveBlueColor:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveDarkBlueColor;
- (void)setPrimitiveDarkBlueColor:(NSString*)value;

- (NSString*)primitiveDarkGrayColor;
- (void)setPrimitiveDarkGrayColor:(NSString*)value;

- (NSString*)primitiveDefaultBackgroundColor;
- (void)setPrimitiveDefaultBackgroundColor:(NSString*)value;

- (NSString*)primitiveDefaultForegroundColor;
- (void)setPrimitiveDefaultForegroundColor:(NSString*)value;

- (NSString*)primitiveDefaultNavigationColor;
- (void)setPrimitiveDefaultNavigationColor:(NSString*)value;

- (NSString*)primitiveDefaultTableTextColor;
- (void)setPrimitiveDefaultTableTextColor:(NSString*)value;

- (NSString*)primitiveFont;
- (void)setPrimitiveFont:(NSString*)value;

- (NSString*)primitiveFont_bold;
- (void)setPrimitiveFont_bold:(NSString*)value;

- (NSString*)primitiveFont_bold_italic;
- (void)setPrimitiveFont_bold_italic:(NSString*)value;

- (NSString*)primitiveFont_extrabold;
- (void)setPrimitiveFont_extrabold:(NSString*)value;

- (NSString*)primitiveFont_extrabold_italic;
- (void)setPrimitiveFont_extrabold_italic:(NSString*)value;

- (NSString*)primitiveFont_italic;
- (void)setPrimitiveFont_italic:(NSString*)value;

- (NSString*)primitiveFont_light;
- (void)setPrimitiveFont_light:(NSString*)value;

- (NSString*)primitiveFont_light_italic;
- (void)setPrimitiveFont_light_italic:(NSString*)value;

- (NSString*)primitiveFriendColor;
- (void)setPrimitiveFriendColor:(NSString*)value;

- (NSString*)primitiveGrayColor;
- (void)setPrimitiveGrayColor:(NSString*)value;

- (NSString*)primitiveGreenColor;
- (void)setPrimitiveGreenColor:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveLightBlueColor;
- (void)setPrimitiveLightBlueColor:(NSString*)value;

- (NSString*)primitiveLightGrayColor;
- (void)setPrimitiveLightGrayColor:(NSString*)value;

- (NSString*)primitiveMessageColor;
- (void)setPrimitiveMessageColor:(NSString*)value;

- (NSString*)primitiveNavTitleColor;
- (void)setPrimitiveNavTitleColor:(NSString*)value;

- (NSString*)primitiveOrangeColor;
- (void)setPrimitiveOrangeColor:(NSString*)value;

- (NSString*)primitivePinkColor;
- (void)setPrimitivePinkColor:(NSString*)value;

- (NSString*)primitivePrivateColor;
- (void)setPrimitivePrivateColor:(NSString*)value;

- (NSString*)primitivePublicColor;
- (void)setPrimitivePublicColor:(NSString*)value;

- (NSString*)primitivePurpleColor;
- (void)setPrimitivePurpleColor:(NSString*)value;

- (NSString*)primitiveRedColor;
- (void)setPrimitiveRedColor:(NSString*)value;

- (NSString*)primitiveTurquoiseColor;
- (void)setPrimitiveTurquoiseColor:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUsernameColor;
- (void)setPrimitiveUsernameColor:(NSString*)value;

- (NSString*)primitiveWhiteColor;
- (void)setPrimitiveWhiteColor:(NSString*)value;

- (NSString*)primitiveYellowColor;
- (void)setPrimitiveYellowColor:(NSString*)value;

@end
