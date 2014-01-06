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
#import "MSDynamicsDrawerViewController.h"
#import "MSDynamicsDrawerStyler.h"
#import "MSLogoViewController.h"

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
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionRight];
    
#if !defined(STORYBOARD)
    MSMenuViewController *menuViewController = [MSMenuViewController new];
#else
    MSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
#endif
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
#if !defined(STORYBOARD)
    MSLogoViewController *logoViewController = [MSLogoViewController new];
#else
    MSLogoViewController *logoViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Logo"];
#endif
    [self.dynamicsDrawerViewController setDrawerViewController:logoViewController forDirection:MSDynamicsDrawerDirectionRight];
    
    // Transition to the first view controller
    [menuViewController transitionToViewController:MSPaneViewControllerTypeStylers];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.windowBackground];
    [self.window sendSubviewToBack:self.windowBackground];
    
    return YES;
}

#pragma mark - MSAppDelegate

- (UIImageView *)windowBackground
{
    if (!_windowBackground) {
        _windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Window Background"]];
    }
    return _windowBackground;
}

- (NSString *)descriptionForPaneState:(MSDynamicsDrawerPaneState)paneState
{
    switch (paneState) {
        case MSDynamicsDrawerPaneStateOpen:
            return @"MSDynamicsDrawerPaneStateOpen";
        case MSDynamicsDrawerPaneStateClosed:
            return @"MSDynamicsDrawerPaneStateClosed";
        case MSDynamicsDrawerPaneStateOpenWide:
            return @"MSDynamicsDrawerPaneStateOpenWide";
        default:
            return nil;
    }
}

- (NSString *)descriptionForDirection:(MSDynamicsDrawerDirection)direction
{
    switch (direction) {
        case MSDynamicsDrawerDirectionTop:
            return @"MSDynamicsDrawerDirectionTop";
        case MSDynamicsDrawerDirectionLeft:
            return @"MSDynamicsDrawerDirectionLeft";
        case MSDynamicsDrawerDirectionBottom:
            return @"MSDynamicsDrawerDirectionBottom";
        case MSDynamicsDrawerDirectionRight:
            return @"MSDynamicsDrawerDirectionRight";
        default:
            return nil;
    }
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"Drawer view controller may update to state `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"Drawer view controller did update to state `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
}

@end
