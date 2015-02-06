//
//  TinderTextView.h
//  SnapCracklePop
//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SnapCardView.h"
#import "CalloutBubble.h"

@interface TextCardView : ContentCard

- (void)setText:(NSString*)text withCalloutPosition:(CalloutBubblePosition)position
    bubbleColor:(UIColor*)bubbleColor
      textColor:(UIColor*)textColor;

@end
