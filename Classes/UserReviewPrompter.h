//
//  PNUserReviewManager.h
//  SnapCracklePop
//
//  Created by Cragin Godley on 10/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserReview) {
  UserReviewNotScheduled,
  UserReviewScheduled,
  UserReviewSaved,
  UserReviewSubmitted
};

@interface UserReviewPrompter : NSObject

@property(nonatomic) NSInteger state;
@property(nonatomic) NSDate *nextPromptTime;
@property(nonatomic) NSString *feedback;
@property(nonatomic) float rating;
@property(nonatomic) BOOL willWriteReview;

+(UserReviewPrompter*) prompter;
-(void)run;

@end
