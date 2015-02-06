//
//  UIImage+Noise.m
//  SnapCracklePop
//
//  Created by Cragin Godley on 11/2/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "UIImage+Noise.h"

@implementation UIImage (Noise)
-(UIImage*) imageByAddingNoiseWithAlpha:(float)alpha
{
    UIImage *noise = [[UIImage alloc] initWithCGImage:CGGenerateNoiseImage(self.size, 1)];
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width,self.size.height)];
    [noise drawInRect:CGRectMake(0,0, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

CF_RETURNS_RETAINED CGImageRef CGGenerateNoiseImage(CGSize size, CGFloat factor) {
    NSUInteger bits = fabs(size.width) * fabs(size.height);
    char *rgba = (char *)malloc(bits);
    srand([[NSDate date] timeIntervalSince1970]);
    
    for(int i = 0; i < bits; ++i)
        rgba[i] = (rand() % 256) * factor;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, fabs(size.width), fabs(size.height),
                                                       8, fabs(size.width), colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    
    CFRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    free(rgba);
    
    return image;
}

@end
