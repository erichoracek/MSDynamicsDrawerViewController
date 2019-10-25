//
//  MSMonospaceWebViewController.m
//  MSDynamicsDrawerViewController Example
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSMonospaceWebViewController.h"

@implementation MSMonospaceWebViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];
    [super viewDidLoad];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if ([parent isKindOfClass:[UINavigationController class]]) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.webView.superview) {
        self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.webView.frame = self.view.bounds;
        [self.view addSubview:self.webView];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - MSMonospaceWebViewController

NSString * const MSMonospaceURL = @"http://www.monospacecollective.com";

- (UIWebView *)webView
{
    if (!_webView) {
        self.webView = ({
            UIWebView *webView = [UIWebView new];
            webView.backgroundColor = [UIColor clearColor];
            webView.opaque = NO;
            UIEdgeInsets insets = (UIEdgeInsets){.top = ([self.topLayoutGuide length])};
            webView.scrollView.contentInset = insets;
            webView.scrollView.scrollIndicatorInsets = insets;
            [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:MSMonospaceURL]]];
            webView;
        });
    }
    return _webView;
}

@end
