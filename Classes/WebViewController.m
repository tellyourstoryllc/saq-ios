//
//  WebViewController.m
//  peanut
//
//  Created by Brian Michel on 12/27/12.
//  Copyright (c) 2012 Perceptual Networks. All rights reserved.
//

#import "WebViewController.h"
#import "TokenizedWebView.h"

@interface WebViewController () <UIWebViewDelegate>
@property (strong) TokenizedWebView *webView;
@property (strong) UIBarButtonItem *backButton;
@property (strong) UIBarButtonItem *forwardButton;
@property (strong) UIBarButtonItem *stopButton;
@property (strong) UIActivityIndicatorView *spinner;

@property BOOL toolbarWasHidden;
@end

@implementation WebViewController

@synthesize url = _url;

+ (UINavigationController *)controllerInNavigationControllerWithURL:(NSURL *)url {
  WebViewController *webVC = [[WebViewController alloc] initWithNibName:nil bundle:nil];
  webVC.url = url;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
  webVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webVC action:@selector(dismiss:)];
  return nav;
}

+ (WebViewController*)withURL:(NSURL *)url {
  WebViewController *webVC = [[WebViewController alloc] initWithNibName:nil bundle:nil];
  webVC.url = url;
  return webVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.webView = [[TokenizedWebView alloc] initWithFrame:CGRectZero];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backward"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 20.0;
    
    self.toolbarItems = @[self.backButton, spaceItem, self.forwardButton, spaceItem, self.stopButton];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionInitial context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionInitial context:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.webView.frame = self.view.bounds;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.navigationController) {
    self.toolbarWasHidden = self.navigationController.toolbarHidden;
    self.navigationController.toolbar.tintColor = COLOR(blueColor);
    [self.navigationController setToolbarHidden:!self.showToolbar];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if (self.navigationController) {
    [self.navigationController setToolbarHidden:self.toolbarWasHidden];
  }
}

- (void)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUrl:(NSURL *)url {
  _url = url;
  [self.webView stopLoading];
  
  if (_url) {
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:_url];
    [self.webView loadRequest:req];
  }
}

- (NSURL *)url {
  return _url;
}

#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
  self.navigationItem.title = @"Loading...";
  [PNSupport setNetworkActivityIndicatorVisible:YES];
  [self checkButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.navigationItem.title =  [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  [PNSupport setNetworkActivityIndicatorVisible:NO];
  [self checkButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  self.navigationItem.title = nil;
  [PNSupport setNetworkActivityIndicatorVisible:NO];
  [self checkButtons];
}

- (void)checkButtons {
  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;
  self.stopButton.enabled = self.webView.loading;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NSURL* url = [request URL];
  if ([[url host] isEqualToString:@"peanut"]) {
    [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                                      openURL:url
                                            sourceApplication:nil
                                                   annotation:nil];
    return NO;
  } else {
    return YES;
  }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self checkButtons];
}

- (void)dealloc {
  [self.webView removeObserver:self forKeyPath:@"canGoBack"];
  [self.webView removeObserver:self forKeyPath:@"canGoForward"];
}
@end
