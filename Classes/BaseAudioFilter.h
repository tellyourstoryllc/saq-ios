//
//  BaseAudioFilter.h
//  TellYourStory
//
//  Created by Jim Young on 2/23/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#include <stdio.h>

@interface BaseAudioFilter : NSObject

@property (nonatomic, assign) int pitchOne;
@property (nonatomic, assign) int pitchTwo;
@property (nonatomic, assign) float fade;

-(void) processAudioData:(AudioBuffer)audioBuffer;

@end
