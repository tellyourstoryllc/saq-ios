//
//  Api+MediaInfo.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/17/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Api.h"

@interface Api (MediaInfo)

+ (NSDictionary*)paramsForMediaInfo:(NSDictionary*)mediaInfo;
+ (NSString*)jsonStringForMediaInfo:(NSDictionary*)mediaInfo;

@end
