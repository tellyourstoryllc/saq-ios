//
//  UpdateMediaEditController.h
//  NoMe
//
//  Created by Jim Young on 1/16/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "BaseMediaEditController.h"
#import "SkyMessage.h"
#import "ArrowButton.h"

@interface UpdateMediaEditController : BaseMediaEditController

@property (nonatomic, strong) SkyMessage* snap;
@property (nonatomic, strong) ArrowButton* saveButton;
@property (nonatomic, strong) PNButton* cancelButton;
@property (nonatomic, strong) PNButton* clearOverlayButton;

@end
