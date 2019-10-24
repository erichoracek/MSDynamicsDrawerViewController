//
//  DXRDynamicXrayConfigurationViewController.m
//  DynamicXray
//
//  Created by Chris Miles on 16/10/13.
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

#import "DXRDynamicXrayConfigurationViewController.h"
#import "DXRDynamicXrayConfigurationViewController_Internal.h"
#import "DXRDynamicXrayConfigurationViewController+Private.h"
#import "DXRDynamicXrayConfigurationViewController+Controls.h"


@implementation DXRDynamicXrayConfigurationViewController

- (id)initWithDynamicXray:(DynamicXray *)dynamicXray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _dynamicXray = dynamicXray;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeStatusBarOrientationNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];

    CGRect bounds = self.view.bounds;

    UIButton *dismissButton = [self newDismissButtonWithFrame:bounds];
    [self.view addSubview:dismissButton];

    [self setupControlsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.animateAppearance && self.initialAppearanceWasAnimated == NO) {
        // Hide views, preparing to animate in
        self.view.backgroundColor = [UIColor clearColor];
        [self.controlsView layoutIfNeeded];
        self.controlsBottomLayoutConstraint.constant = CGRectGetHeight(self.controlsView.frame);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.animateAppearance && self.initialAppearanceWasAnimated == NO) {
        self.initialAppearanceWasAnimated = YES;
        [self transitionInAnimatedWithCompletion:NULL];
    }
}


#pragma mark - Rotation

- (void)applicationWillChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.controlsView removeFromSuperview];
        UIInterfaceOrientation toInterfaceOrientation = [notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
        [self setupControlsViewWithInterfaceOrientation:toInterfaceOrientation];
        [self.view layoutIfNeeded];
    }
}


#pragma mark - Transition Animations

- (void)transitionInAnimatedWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:0 options:0 animations:^{

        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];

        self.controlsBottomLayoutConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(__unused BOOL finished) {
        if (completion) completion();
    }];
}

- (void)transitionOutAnimatedWithCompletion:(void (^)(void))completion
{
    CGRect controlsFrame = self.controlsView.frame;

    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:0 options:0 animations:^{

        self.view.backgroundColor = [UIColor clearColor];

        self.controlsBottomLayoutConstraint.constant = CGRectGetHeight(controlsFrame);
        [self.view layoutIfNeeded];
    } completion:^(__unused BOOL finished) {
        if (completion) completion();
    }];
}

@end
