//
//  SnapInfoController.h
//  NoMe
//
//  Created by Jim Young on 1/19/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@class SnapInfoView;

@protocol SnapInfoDelegate <NSObject>

@optional
- (void)snapInfo:(SnapInfoView*)infoView didDismiss:(SkyMessage*)snap;
- (void)snapInfo:(SnapInfoView*)infoView didDelete:(SkyMessage*)snap;
- (void)snapInfo:(SnapInfoView*)infoView didUpdate:(SkyMessage*)snap toPermission:(NSString*)newPermission;
- (void)snapInfo:(SnapInfoView*)infoView didFlag:(SkyMessage*)snap withOptions:(NSDictionary*)options;

@end

@interface SnapInfoView : UIView

@property (nonatomic, strong) SkyMessage* snap;
@property (nonatomic, assign) id<SnapInfoDelegate> delegate;
@property (nonatomic, strong) NSString* permission;

@end