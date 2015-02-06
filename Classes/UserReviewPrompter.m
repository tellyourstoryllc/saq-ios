//
//  PNUserReviewManager.m
//  SnapCracklePop
//
//  Created by Cragin Godley on 10/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "UserReviewPrompter.h"
#import "PNUserPreferences.h"

#import "CustomIOS7AlertView.h"
#import "AlertView.h"
#import "EDStarRating.h"
#import "App.h"
#import "Api.h"

#import "PNAppStoreUtil.h"

#define kStateKey @"PNUserReviewPrompter_state"
#define kNextPromptTimeKey @"PNUserReviewPrompter_nextPromptTime"
#define kRatingKey @"PNUserReviewPrompter_rating"
#define kFeedbackKey @"PNUserReviewPrompter_feedback"
#define kWillWriteReviewKey @"PNUserReviewPrompter_willWriteReview"

@implementation UserReviewPrompter

#pragma mark Singleton
+(UserReviewPrompter*)prompter
{
    static UserReviewPrompter *prompter;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        prompter = [[UserReviewPrompter alloc] init];
    });

    return prompter;
}

#pragma mark Collect User Review
-(void)run
{
    [self printState];

    // Uncomment to test
//    self.state = UserReviewScheduled;
//    self.nextPromptTime = [NSDate date];

    if(![App isLoggedIn])
        return;

    if(UserReviewSubmitted == self.state)
        return;

    if (UserReviewSaved == self.state) {
        [self submitSavedReview];
        return;
    }

    if(UserReviewNotScheduled == self.state) {
        [self scheduleFuturePrompt];
        return;
    }

    if ([[NSDate date] compare:self.nextPromptTime] == NSOrderedAscending) {
        [self printNextPromptTime];
        return;
    }

    [self showFirstDialogRating];
}

-(void) showFirstDialogRating
{
    const int kTitleHeight = 40;
    const int kStarHeight = 50;
    const int kAlertWidth = 290;
    const int kAlertHeight = kTitleHeight + kStarHeight;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, kTitleHeight)];
    title.text = [NSString stringWithFormat:@"Please rate %@", kAppTitle];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = FONT_B(18);

    EDStarRating *starRating = [[EDStarRating alloc] initWithFrame:CGRectMake(0, kTitleHeight, kAlertWidth, kStarHeight)];
    starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    starRating.maxRating = 5.0;
    starRating.rating = 0;
    starRating.horizontalMargin = 25.0;
    starRating.editable = YES;
    starRating.displayMode = EDStarRatingDisplayFull;
    [starRating setNeedsDisplay];
    starRating.tintColor = COLOR(blueColor);

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, kAlertHeight)];
    [container addSubview:title];
    [container addSubview:starRating];

    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
    alert.containerView = container;
    alert.buttonTitles = @[@"Not now", @"Submit"];
    alert.useMotionEffects = NO;

    [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {

        if(0 == buttonIndex) {  // Not now
            [self scheduleFuturePrompt];

        } else if(1 == buttonIndex) {  // Submit
            if(starRating.rating >= 4)
                [self showSecondDialogGotoAppStoreWithRating: starRating.rating];

            else if (starRating.rating > 0)
                [self showSecondDialogGetFeedbackWithRating: starRating.rating];

            else
                return;
            [alertView close];
        }
    }];
    [alert show];

    // Disable submit button
    UIButton *submit = nil;
    for(UIView *v in alert.dialogView.subviews) {
        if([v isKindOfClass:[UIButton class]] && v.tag == 1) {
            submit = (UIButton*) v;
            submit.enabled = NO;
            break;
        }
    }

    // Enable submit button when a rating is chosen
    if(submit) {
        starRating.returnBlock = ^(float rating) {
            submit.enabled = YES;
        };
    }

}

-(void) showSecondDialogGetFeedbackWithRating:(float)rating
{
    const int kTitleHeight = 40;
    const int kTextViewHeight = 150;
    const int kAlertWidth = 290;
    const int kAlertHeight = kTitleHeight + kTextViewHeight;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, kTitleHeight)];
    title.text = @"How can we improve?";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = FONT_B(18);

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kTitleHeight, kAlertWidth, kTextViewHeight)];
    textView.backgroundColor = COLOR(whiteColor);
    textView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    textView.font = FONT(18);

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, kAlertHeight)];
    [container addSubview:title];
    [container addSubview:textView];

    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
    alert.containerView = container;
    alert.buttonTitles = @[@"OK"];

    [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSString *message = textView.text;
        [self saveReview:message rating:rating willWriteReview:NO];
        [self submitSavedReview];
    }];
    [alert show];
    [textView becomeFirstResponder];
}

-(void) showSecondDialogGotoAppStoreWithRating:(float) rating
{
    AlertView *alert = [[AlertView alloc] initWithTitle:nil message:@"Can you write a quick review of our app on the App Store?" andButtonArray:@[@"Yes", @"Not now"]];

    [alert showWithCompletion:^(NSInteger buttonIndex) {

        BOOL will_write_review = (0 == buttonIndex);

        if(will_write_review)
            [PNAppStoreUtil openUrlForAppStoreId:kAppStoreId];
        else
            [self scheduleFuturePrompt];

        [self saveReview:nil rating:rating willWriteReview:will_write_review];
        [self submitSavedReview];
    }];
}

# pragma mark Helpers
-(void)scheduleFuturePrompt
{
    BOOL firstTime = (self.state == UserReviewNotScheduled);
    self.nextPromptTime = [NSDate dateWithTimeIntervalSinceNow:firstTime ? 24 * 3600 : 72 * 3600];
    self.state = UserReviewScheduled;
}

-(void) saveReview:(NSString*)message rating:(float)rating willWriteReview:(BOOL)will_write_review
{
    // NOTE: message can be `nil`

    // Persist review to app preferences (make sure logout does NOT erase)
    self.feedback = message;
    self.rating = rating;
    self.willWriteReview = will_write_review;

    self.state = UserReviewSaved;
}

-(void)submitSavedReview
{
    NSLog(@"PNUserReviewPrompter: submit: rating=%d, message=\"%@\", willWriteReview=%d)", (int)self.rating, self.feedback, self.willWriteReview);

    NSMutableDictionary *params = [@{
                                     @"rating":[[NSString alloc] initWithFormat:@"%d", (int)self.rating]
                                     } mutableCopy];

    if(self.feedback && self.feedback.length > 0)
        [params setValue:self.feedback forKey:@"feedback"];

    // Only send "will_write_review" if the user was prompted
    if(self.rating >= 4)
        [params setValue:(self.willWriteReview ? @"true" : @"false") forKey:@"will_write_review"];

    [[Api fastApi] postPath:@"/app_reviews/create"
                 parameters:params
                   callback:^(NSSet *entities, id responseObject, NSError *error) {
                       if(error) {
                           NSLog(@"Error sending user review to server");
                       }
                       else
                           self.state = UserReviewSubmitted;
                   }];
}

-(void)printState
{
    NSLog(@"PNUserReviewPrompter.state = %d", self.state);
}

-(void)printNextPromptTime
{
    NSLog(@"PNUserReviewPrompter.nextPromptTime = %@", self.nextPromptTime);
}

#pragma mark Properties
-(void)setState:(NSInteger)state
{
    [[NSUserDefaults standardUserDefaults] setValue:@(state) forKey:kStateKey];
    [self printState];
}

-(NSInteger)state
{
    return [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:kStateKey] intValue] ?: UserReviewNotScheduled;
}

-(void)setNextPromptTime:(NSDate *)nextPromptTime
{
    [[NSUserDefaults standardUserDefaults] setValue:nextPromptTime forKey:kNextPromptTimeKey];
    [self printNextPromptTime];
}

-(NSDate *)nextPromptTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kNextPromptTimeKey];
}

-(void)setFeedback:(NSString *)feedback
{
    [[NSUserDefaults standardUserDefaults] setValue:feedback forKey:kFeedbackKey];
}

-(NSString *)feedback
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kFeedbackKey];
}

-(void)setRating:(float)rating
{
    [[NSUserDefaults standardUserDefaults] setValue:@(rating) forKey:kRatingKey];
}

-(float)rating
{
    return [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:kRatingKey] floatValue];
}

-(void)setWillWriteReview:(BOOL)will_write_review
{
    [[NSUserDefaults standardUserDefaults] setValue:@(will_write_review) forKey:kWillWriteReviewKey];
}

-(BOOL)willWriteReview
{
    return [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:kWillWriteReviewKey] boolValue];
}
@end

