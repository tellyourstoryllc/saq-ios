//
//  MegaWebView.m
//  Peanut
//
//  Created by Jim Young on 5/24/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "TokenizedWebView.h"
#import "App.h"

@implementation TokenizedWebView

- (NSURLRequest *)signRequest:(NSURLRequest *)request {

    NSMutableString *authURLString = [[[request URL] absoluteString] mutableCopy];

        NSString* token = [App getStringPreference:@"token"];
        if (token) {
            NSString *queryString = [[request URL] query];
            if ([queryString length] > 0) {
                [authURLString appendFormat:@"&token=%@", token];
            } else {
                [authURLString appendFormat:@"?token=%@", token];
            }

            return [NSURLRequest requestWithURL:[NSURL URLWithString:authURLString]];
        }
    return request;
}

- (void)loadRequest:(NSURLRequest *)request {

    if (!self.delegate) self.delegate = self;

    if ([request URL]) {
        [super loadRequest:[self signRequest:request]];
    } else {
        [super loadRequest:request];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* url = [request URL];
    if ([[url scheme] isMatchedByRegex:kCustomURLScheme]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                                          openURL:url
                                                sourceApplication:nil
                                                       annotation:nil];
        return NO;
    } else {
        return YES;
    }
}

@end