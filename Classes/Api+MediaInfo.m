//
//  Api+MediaInfo.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/17/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "Api+MediaInfo.h"
#import "App.h"

@implementation Api (MediaInfo)

+ (NSDictionary*)paramsForMediaInfo:(NSDictionary*)mediaInfo {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setObject:[self jsonStringForMediaInfo:mediaInfo] forKey:@"attachment_metadata"];

    if (mediaInfo[@"original_message_id"])
        [dict setObject:mediaInfo[@"original_message_id"] forKey:@"original_message_id"];

    if (mediaInfo[@"forward_message_id"])
        [dict setObject:mediaInfo[@"forward_message_id"] forKey:@"forward_message_id"];

    return dict;
}

+ (NSString*)jsonStringForMediaInfo:(NSDictionary*)mediaInfo {
    NSMutableDictionary* info = mediaInfo ? [mediaInfo mutableCopy] : [@{} mutableCopy];

    // Append current user to "senders"
    NSMutableArray* senders = info[@"senders"] ? [info[@"senders"] mutableCopy] : [@[] mutableCopy];
    [senders addObject:[App username]];
    [info setObject:senders forKey:@"senders"];

    // Strip out original_message_id and forward_message_id, since they are passed as separate params
    [info removeObjectForKey:@"original_message_id"];
    [info removeObjectForKey:@"forward_message_id"];

    if ([NSJSONSerialization isValidJSONObject:info]) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else
        return @"";
}

@end
