//
//  MSAppDelegate.m
//  MSDynamicsDrawerViewController
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
//  The above copyright notice and thise permission notice shall be included in
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

#import "MSAppDelegate.h"
#import "MSMenuViewController.h"
#import "MSLogoViewController.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

//#define DEBUG_DYNAMICS

#ifdef DEBUG_DYNAMICS
#import <DynamicXray/DynamicXray.h>
#endif

@interface MSAppDelegate () <MSDynamicsDrawerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *windowBackground;

@end

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if !defined(STORYBOARD)
    self.dynamicsDrawerViewController = [MSDynamicsDrawerViewController new];
#else
    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
#endif
    
    self.dynamicsDrawerViewController.delegate = self;
    
    // Add some example stylers
    [self.dynamicsDrawerViewController addStylers:@[[MSDynamicsDrawerStatusBarOffsetStyler new]] forDirection:MSDynamicsDrawerDirectionAll];
    [self.dynamicsDrawerViewController addStylers:@[[MSDynamicsDrawerFadeStyler new]] forDirection:MSDynamicsDrawerDirectionLeft];
    
#if !defined(STORYBOARD)
    MSMenuViewController *menuViewController = [MSMenuViewController new];
#else
    MSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
#endif
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    UINavigationController *menuNavigationController = [[MSStatusBarOffsetDrawerNavigationController alloc] initWithRootViewController:menuViewController];
    menuNavigationController.navigationBarHidden = YES;
    [self.dynamicsDrawerViewController setDrawerViewController:menuNavigationController forDirection:MSDynamicsDrawerDirectionLeft];
    
#if !defined(STORYBOARD)
    MSLogoViewController *logoViewController = [MSLogoViewController new];
#else
    MSLogoViewController *logoViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Logo"];
#endif
    [self.dynamicsDrawerViewController setDrawerViewController:logoViewController forDirection:MSDynamicsDrawerDirectionRight];
    [self.dynamicsDrawerViewController addStyler:[MSDynamicsDrawerResizeStyler new] forDirection:MSDynamicsDrawerDirectionAll];
    
    // Transition to the first view controller
    [menuViewController transitionToViewController:0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];
    
    // Add window background image
    [self.window addSubview:self.windowBackground];
    self.windowBackground.frame = self.window.bounds;
    [self.window sendSubviewToBack:self.windowBackground];
    
    return YES;
}

#pragma mark - MSAppDelegate

- (UIImageView *)windowBackground
{
    if (!_windowBackground) {
        _windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Window Background"]];
        _windowBackground.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return _windowBackground;
}

- (NSString *)descriptionForPaneState:(MSDynamicsDrawerPaneState)paneState
{
    switch (paneState) {
        case MSDynamicsDrawerPaneStateOpen:
            return @"Open";
        case MSDynamicsDrawerPaneStateClosed:
            return @"Closed";
        case MSDynamicsDrawerPaneStateOpenWide:
            return @"Open Wide";
    }
    return nil;
}

- (NSString *)descriptionForDirection:(MSDynamicsDrawerDirection)direction
{
    switch (direction) {
        case MSDynamicsDrawerDirectionTop:
            return @"Top";
        case MSDynamicsDrawerDirectionLeft:
            return @"Left";
        case MSDynamicsDrawerDirectionBottom:
            return @"Bottom";
        case MSDynamicsDrawerDirectionRight:
            return @"Right";
        default:
            return nil;
    }
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"May update to `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
    
#ifdef DEBUG_DYNAMICS
    UIDynamicAnimator *dynamicAnimator = [drawerViewController performSelector:@selector(_dynamicAnimator)];
    DynamicXray *xray = [[DynamicXray alloc] init];
    xray.crossFade = 0.5;
    [dynamicAnimator addBehavior:xray];
#endif
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"Did update to `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
}

@end
