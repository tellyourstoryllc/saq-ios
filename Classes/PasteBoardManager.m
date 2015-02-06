//
//  PasteBoardObserver.m
//  NoMe
//
//  Created by Jim Young on 12/9/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "PasteBoardManager.h"
#import "AlertView.h"
#import "App.h"
#import "WebViewController.h"
#import "UIImage+Utility.h"
#import "MediaAssetManager.h"
#import "SpinnerImageView.h"
#import "PNSimpleWebView.h"

@interface PasteBoardManager() {
    NSUInteger _lastHash;
    PNSimpleWebView* _webView;
}

@end

@implementation PasteBoardManager

+ (instancetype)manager {

    static PasteBoardManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[PasteBoardManager alloc] init];
    });

    return singleton;
}

- (void)importWithCompletion:(void (^)(UIImage* image, NSDictionary* metadata))completion
{
    UIPasteboard* pb = [UIPasteboard generalPasteboard];

    NSUInteger hash;
    id value = [pb valueForPasteboardType:(NSString*)kUTTypePNG];
    if (value) {
        UIImage* image = (UIImage*)value;
        hash = [UIImagePNGRepresentation(image) length];
        if (hash != _lastHash) {
            _lastHash = hash;
            [self processImage:image withCompletion:completion];
        }
        else {
            completion(nil, nil);
        }
        return;
    }

    value = [pb valueForPasteboardType:(NSString*)kUTTypeJPEG];
    if (value) {
        UIImage* image = (UIImage*)value;
        hash = [UIImageJPEGRepresentation(image, 1.0) length];
        if (hash != _lastHash) {
            _lastHash = hash;
            [self processImage:image withCompletion:completion];
        }
        else {
            completion(nil, nil);
        }
        return;
    }

    NSString* str = [pb string];
    if (str) {
        hash = [str hash];
        NSURL* url = [NSURL URLWithString:str];
        if ([url.scheme isMatchedByRegex:@"http(s)"] && hash != _lastHash) {
            // Pasteboard contains a URL.
            _lastHash = hash;
            [self processUrl:[NSURL URLWithString:str] withCompletion:completion];
        }
        else {
            completion(nil, nil);
        }
        return;
    }

    completion(nil, nil);

}

- (void)processImage:(UIImage*)image
      withCompletion:(void (^)(UIImage* image, NSDictionary* metadata))completion {

    AlertView* av = [[AlertView alloc] initWithTitle:nil
                                             message:@"Import image from clipboard?"
                                      andButtonArray:@[@"Yes", @"No"]];
    av.verticalAlignment = AlertViewAlignHigh;

    [av showAfterPresent:^{
        CGRect b = av.backgroundOverlay.bounds;
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMakeCorners(0, CGRectGetMaxY(av.alertContainer.frame)+4, b.size.width, b.size.height);
        [av.backgroundOverlay addSubview:imageView];

    } withCompletion:^(NSInteger buttonIndex) {
        if (completion) {
            if (buttonIndex == 0)
                completion(image, @{});
            else
                completion(nil, nil);
        }
    }];
}


- (void)processUrl:(NSURL*)url
    withCompletion:(void (^)(UIImage* image, NSDictionary* metadata))completion
{
    __block UIImage* screenshot;

    AlertView* av = [[AlertView alloc] initWithTitle:@"Import URL from clipboard?"
                                             message:url.host
                                      andButtonArray:@[@"Yes", @"No"]];
    av.verticalAlignment = AlertViewAlignHigh;
    [av showWithCompletion:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {

            AlertView* av2 = [[AlertView alloc] initWithTitle:@"Please Wait a Moment"
                                                      message:nil
                                               andButtonArray:@[@"Importing URL...", @"Cancel"]];
            av2.verticalAlignment = AlertViewAlignHigh;

            [av2 showAfterPresent:^{

                _webView = [PNSimpleWebView new];
                _webView.alpha = 0.0;
                _webView.userInteractionEnabled = NO;
                CGRect b = av2.backgroundOverlay.bounds;
                _webView.frame = CGRectOffset(b, 0, CGRectGetMaxY(av2.alertContainer.frame)+8);
                [av2.backgroundOverlay addSubview:_webView];

                UIButton* button = av2.buttons[0];
                button.enabled = NO;

                [_webView loadRequest:[NSURLRequest requestWithURL:url] withCompletion:^(UIView *webView, NSError *error) {
                    if (!error) {
                        UIButton* button = av2.buttons[0];
                        [button setTitle:@"Continue" forState:UIControlStateNormal];
                        button.enabled = YES;
                        _webView.alpha = 1.0;
                        screenshot = [_webView screenshot];
                    }
                }];

            } withCompletion:^(NSInteger buttonIndex) {
                //
                if (buttonIndex == 0) {
                    if (completion) completion(screenshot, @{@"url":url.absoluteString});
                }
                else {
                    if (completion) completion(nil, nil);
                }

                [_webView removeFromSuperview];
                _webView = nil;
            }];

        }
        else {
            if (completion) completion(nil, nil);
        }
    }];

}

@end
