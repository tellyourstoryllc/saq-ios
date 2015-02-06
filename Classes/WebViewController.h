//
//  WebViewController.h
//  peanut
//
//  Created by Brian Michel on 12/27/12.
//  Copyright (c) 2012 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (strong) NSURL *url;
@property BOOL showToolbar;
+ (UINavigationController *)controllerInNavigationControllerWithURL:(NSURL *)url;
+ (UINavigationController *)withURL:(NSURL *)url;
@end
