//
//  DXRDynamicXrayWindowController.m
//  DynamicXray
//
//  Created by Chris Miles on 14/10/13.
//  Copyright (c) 2013-2014 Chris Miles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "DXRDynamicXrayWindowController.h"
#import "DXRDynamicXrayViewController.h"
#import "DXRDynamicXrayWindow.h"
#import "DXRDynamicXrayConfigurationViewController.h"
#import "DXRDynamicXrayConfigurationViewController+Private.h"
#import "DynamicXray_Internal.h"


static CGFloat
AngleForUIInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);


@interface DXRDynamicXrayWindowController () <DXRDynamicXrayWindowDelegate>

@property (strong, nonatomic) DXRDynamicXrayConfigurationViewController *configurationViewController;
@property (strong, nonatomic) NSMutableArray *xrayViewControllers;

@property (weak, nonatomic) DXRDynamicXrayWindow *window;

@end


@implementation DXRDynamicXrayWindowController

- (id)init
{
    self = [super init];
    if (self) {
        _xrayViewControllers = [NSMutableArray array];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarFrameNotification:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (UIWindow *)xrayWindow
{
    DXRDynamicXrayWindow *window = self.window;

    if (window == nil) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];

        // Create a new shared UIWindow to host dynamics xray views
        window = [[DXRDynamicXrayWindow alloc] initWithFrame:screenBounds];
        window.xrayWindowDelegate = self;
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.userInteractionEnabled = NO;

        // Create a share root view controller on the window
        UIViewController *rootViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        [window setRootViewController:rootViewController];
        rootViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        self.window = window;
    }

    return window;
}


#pragma mark - Xray View Controller Presentation

- (void)presentDynamicXrayViewController:(DXRDynamicXrayViewController *)dynamicXrayViewController
{
    if ([self.xrayViewControllers containsObject:dynamicXrayViewController] == NO) {
        [self.xrayViewControllers addObject:dynamicXrayViewController];

        __strong DXRDynamicXrayWindow *window = self.window;
        UIView *rootView = window.rootViewController.view;
        [dynamicXrayViewController.view setTransform:rootView.transform];
        [dynamicXrayViewController.view setFrame:rootView.frame];
        [dynamicXrayViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

        if (self.configurationViewController.view.superview == window) {
            [window insertSubview:dynamicXrayViewController.view belowSubview:self.configurationViewController.view];
        }
        else {
            [window addSubview:dynamicXrayViewController.view];
        }

        [self addChildViewController:dynamicXrayViewController];
    }
}

- (void)dismissDynamicXrayViewController:(DXRDynamicXrayViewController *)xrayViewController
{
    [xrayViewController.view removeFromSuperview];
    [xrayViewController removeFromParentViewController];
    [self.xrayViewControllers removeObject:xrayViewController];
}


#pragma mark - Config View Controller Presentation

- (void)presentConfigViewControllerWithDynamicXray:(DynamicXray *)dynamicXray animated:(BOOL)animated
{
    if (self.configurationViewController == nil) {
        __strong DXRDynamicXrayWindow *window = self.window;

        DXRDynamicXrayConfigurationViewController *configViewController = [[DXRDynamicXrayConfigurationViewController alloc] initWithDynamicXray:dynamicXray];
        self.configurationViewController = configViewController;

        configViewController.animateAppearance = animated;
        [configViewController.view setFrame:window.bounds];
        [configViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

        [window addSubview:configViewController.view];

        [self addChildViewController:configViewController];

        [window setUserInteractionEnabled:YES];
    }
    else {
        NSLog(@"Warning: attempt to present a DynamicXray Configuration view when one is already visible.");
    }
}

- (void)dismissConfigViewController
{
    [self.configurationViewController.view removeFromSuperview];
    self.configurationViewController = nil;

    __strong DXRDynamicXrayWindow *window = self.window;
    [window setUserInteractionEnabled:NO];
}


#pragma mark - Status Bar Frame & Orientation Changes

- (void)applicationDidChangeStatusBarFrameNotification:(__unused NSNotification *)notification
{
    [self layoutRootViews];
}

- (void)applicationDidChangeStatusBarOrientationNotification:(__unused NSNotification *)notification
{
    [self layoutRootViews];
}

- (void)layoutRootViews
{
    __strong DXRDynamicXrayWindow *window = self.window;
    if (window == nil) return;

    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = AngleForUIInterfaceOrientation(statusBarOrientation);

    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGSize frameSize = window.frame.size;
    CGRect frame = CGRectMake(0, 0, frameSize.width, frameSize.height);

    NSArray *viewControllers = self.childViewControllers;

    for (UIViewController *viewController in viewControllers) {
        UIView *rootView = viewController.view;

        if (CGRectEqualToRect(frame, rootView.frame) == NO || CGAffineTransformEqualToTransform(transform, rootView.transform) == NO) {
            rootView.transform = transform;
            rootView.frame = CGRectMake(0, 0, frameSize.width, frameSize.height);

            if ([viewController isKindOfClass:[DXRDynamicXrayViewController class]]) {
                DynamicXray *dynamicXray = [(DXRDynamicXrayViewController *)viewController dynamicXray];
                [dynamicXray redraw];
            }
        }
    }
}


#pragma mark - DXRDynamicXrayWindowDelegate

- (void)dynamicXrayWindowNeedsToLayoutSubviews:(__unused DXRDynamicXrayWindow *)dynamicXrayWindow
{
    [self layoutRootViews];
}

@end


static CGFloat
AngleForUIInterfaceOrientation(UIInterfaceOrientation interfaceOrientation)
{
    CGFloat angle;

    if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        angle = (CGFloat)M_PI;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        angle = -(CGFloat)M_PI_2;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        angle = (CGFloat)M_PI_2;
    }
    else {
        angle = 0;
    }

    return angle;
}
