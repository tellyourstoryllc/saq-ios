//
//  GroupViewController.h
//  chat
//
//  Created by Cragin Godley on 10/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "CenterViewController.h"

@interface GroupViewController : UIViewController

@property (nonatomic) Group *group;
@property (nonatomic, weak) CenterViewController* cameraController;

-(void)setUserInteractionEnabled:(NSNumber*)enabled;
-(NSString*)insertPlaceHolderMessageWithText:(NSString*)text attachment:(BOOL)hasAttachment;

- (void)viewDidOpen;
- (void)markReadMessages;

@end
