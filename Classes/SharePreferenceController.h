//
//  SharePreferenceController.h
//  TellYourStory
//
//  Created by Jim Young on 3/31/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SharePreferenceController;

@protocol SharePreferenceDelegate <NSObject>
- (void)sharePreferenceController:(SharePreferenceController*)controller didSelectPreference:(NSString*)sharePreference;
@end

@interface SharePreferenceController : UIViewController
@property (nonatomic, weak) id<SharePreferenceDelegate>delegate;
@end
