//
//  DXRDynamicXrayConfigurationViewController+Controls.m
//  DynamicXray
//
//  Created by Chris Miles on 24/10/13.
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

#import "DXRDynamicXrayConfigurationViewController+Controls.h"
#import "DXRDynamicXrayConfigurationViewController_Internal.h"

#import "DXRDynamicXrayConfigurationActiveView.h"
#import "DXRDynamicXrayConfigurationFaderView.h"
#import "DXRDynamicXrayConfigurationTitleView.h"
#import "DXRDynamicXrayWindowController.h"


@implementation DXRDynamicXrayConfigurationViewController (Controls)

#pragma mark - View/Control Creation

- (UIButton *)newDismissButtonWithFrame:(CGRect)frame
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.frame = frame;
    dismissButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [dismissButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    return dismissButton;
}

- (void)setupControlsView
{
    [self setupControlsViewWithInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)setupControlsViewWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    DXRDynamicXrayConfigurationControlsLayoutStyle layoutStyle;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        layoutStyle = DXRDynamicXrayConfigurationControlsLayoutStyleNarrow;
    }
    else
    {
        layoutStyle = DXRDynamicXrayConfigurationControlsLayoutStyleWide;
    }

    DXRDynamicXrayConfigurationControlsView *controlsView = [[DXRDynamicXrayConfigurationControlsView alloc] initWithLayoutStyle:layoutStyle];
    controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    controlsView.backgroundColor = [UIColor clearColor];

    controlsView.tintColor = [self controlsTintColor];

    __strong DynamicXray *dynamicXray = self.dynamicXray;

    [controlsView.activeView.activeToggleSwitch setOn:dynamicXray.isActive];
    [controlsView.activeView.activeToggleSwitch setOnTintColor:[self controlsTintColor]];
    [controlsView.activeView.activeToggleSwitch addTarget:self action:@selector(activeToggleAction:) forControlEvents:UIControlEventValueChanged];

    [controlsView.faderView.faderSlider setValue:(float)((dynamicXray.crossFade+1.0f)/2.0f)];
    [controlsView.faderView.faderSlider addTarget:self action:@selector(faderSliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:controlsView];

    // Contraints

    NSDictionary *layoutViews = NSDictionaryOfVariableBindings(controlsView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controlsView]|" options:0 metrics:nil views:layoutViews]];

    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:controlsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:controlsView.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self.view addConstraint:bottomConstraint];
    self.controlsBottomLayoutConstraint = bottomConstraint;

    self.controlsView = controlsView;
}


#pragma mark - Actions

- (void)dismissAction:(__unused id)sender
{
    DXRDynamicXrayWindowController *xrayWindowController = (DXRDynamicXrayWindowController *)self.parentViewController;

    void ((^completion)(void)) = ^{
        [xrayWindowController dismissConfigViewController];
    };

    if (self.animateAppearance) {
        [self transitionOutAnimatedWithCompletion:completion];
    }
    else {
        completion();
    }
}

- (void)activeToggleAction:(UISwitch *)toggleSwitch
{
    __strong DynamicXray *dynamicXray = self.dynamicXray;
    [dynamicXray setActive:toggleSwitch.on];
}

- (void)faderSliderValueChanged:(UISlider *)slider
{
    CGFloat crossFade = slider.value * 2.0f - 1.0f;
    __strong DynamicXray *dynamicXray = self.dynamicXray;
    dynamicXray.crossFade = crossFade;
}

- (UIColor *)controlsTintColor
{
    return [UIColor colorWithRed:0 green:0.639216f blue:0.85098f alpha:1.0f];
}

@end
