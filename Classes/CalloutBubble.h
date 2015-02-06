//
//  TopBubble.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CalloutBubblePosition) {
    CalloutBubblePositionNone,
    CalloutBubblePositionBottom,
    CalloutBubblePositionTop,
    CalloutBubblePositionLeft,
    CalloutBubblePositionRight
};

@interface CalloutBubble : PNView

@property (nonatomic, readonly) UIImage* bubbleImage;
@property (nonatomic, strong) UIColor* bubbleColor;
@property (nonatomic, assign) CGFloat calloutOffset;
@property (nonatomic, strong) PNLabel* textLabel;
@property (nonatomic, assign) CalloutBubblePosition calloutPosition;

@end
