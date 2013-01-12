//
//  MSNavigationPaneViewController.h
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012 Monospace Ltd. All rights reserved.
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

#import "MSNavigationPaneViewController.h"
#import "MSDraggableView.h"

#import <QuartzCore/QuartzCore.h>

//#define LAYOUT_DEBUG

// Sizes
const CGFloat MSNavigationPaneOpenStateMasterDisplayWidth = 267.0f;

// Animation Durations
const CGFloat MSNavigationPaneAnimationDurationOpenToSide = 0.2;
const CGFloat MSNavigationPaneAnimationDurationClosedToSide = 0.5;
const CGFloat MSNavigationPaneAnimationDurationSideToClosed = 0.45;
const CGFloat MSNavigationPaneAnimationDurationOpenToClosed = 0.3;
const CGFloat MSNavigationPaneAnimationDurationClosedToOpen = 0.3;
const CGFloat MSNavigationPaneAnimationDurationSnap = 0.15;
const CGFloat MSNavigationPaneAnimationDurationSnapBack = 0.12;

// Appearance Type Constants
const CGFloat MSNavigationPaneAppearanceTypeZoomScaleFraction = 0.075;
const CGFloat MSNavigationPaneAppearanceTypeParallaxOffsetFraction = 0.35;

@interface MSNavigationPaneViewController () <MSDraggableViewDelegate> {
    
    UIViewController *_masterViewController;
    UIViewController *_paneViewController;
    MSNavigationPaneAppearanceType _appearanceType;
}

- (void)initialize;

@end

@implementation MSNavigationPaneViewController

@dynamic masterViewController;
@dynamic paneViewController;
@dynamic paneState;
@dynamic appearanceType;
@synthesize delegate;

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - ERNavigationPaneViewController

- (void)initialize
{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    _appearanceType = MSNavigationPaneAppearanceTypeNone;
    
    _masterView = [[UIView alloc] initWithFrame:self.view.bounds];
    _masterView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _masterView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_masterView];
    
    _paneView = [[MSDraggableView alloc] initWithFrame:self.view.bounds];
    _paneView.navigationPaneViewController = self;
    _paneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _paneView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_paneView];
    
#if defined(LAYOUT_DEBUG)
    _masterView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    _masterView.layer.borderColor = [[UIColor blueColor] CGColor];
    _masterView.layer.borderWidth = 2.0;
    
    _paneView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    _paneView.layer.borderColor = [[UIColor redColor] CGColor];
    _paneView.layer.borderWidth = 2.0;
#endif
}

#pragma mark Pane State

- (MSNavigationPaneState)paneState
{
    return _paneView.state;
}

- (void)setPaneState:(MSNavigationPaneState)paneState
{
    [self setPaneState:paneState animated:NO];
}

#pragma mark View Controller Accessors

- (UIViewController *)masterViewController
{
    return _masterViewController;
}

- (void)setMasterViewController:(UIViewController *)masterViewController
{
	if (_masterViewController == nil) {
        
        masterViewController.view.frame = _masterView.bounds;
		_masterViewController = masterViewController;
		[self addChildViewController:_masterViewController];
		[_masterView addSubview:_masterViewController.view];
		[_masterViewController didMoveToParentViewController:self];
        
	} else if (_masterViewController != masterViewController) {
        
		masterViewController.view.frame = _masterView.bounds;
		[_masterViewController willMoveToParentViewController:nil];
		[self addChildViewController:masterViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [_masterViewController removeFromParentViewController];
            [masterViewController didMoveToParentViewController:self];
            _masterViewController = masterViewController;
        };
        
		[self transitionFromViewController:_masterViewController
						  toViewController:masterViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:nil
								completion:transitionCompletion];
	}
}

- (UIViewController *)paneViewController
{
    return _paneViewController;
}

- (void)setPaneViewController:(UIViewController *)paneViewController
{
	if (_paneViewController == nil) {
        
		paneViewController.view.frame = _paneView.bounds;
		_paneViewController = paneViewController;
		[self addChildViewController:_paneViewController];
		[_paneView addSubview:_paneViewController.view];
		[_paneViewController didMoveToParentViewController:self];
        
	} else if (_paneViewController != paneViewController) {
        
		paneViewController.view.frame = _paneView.bounds;
		[_paneViewController willMoveToParentViewController:nil];
		[self addChildViewController:paneViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [_paneViewController removeFromParentViewController];
            [paneViewController didMoveToParentViewController:self];
            _paneViewController = paneViewController;
        };
        
		[self transitionFromViewController:_paneViewController
						  toViewController:paneViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:nil
								completion:transitionCompletion];
	}
}

#pragma mark Navigation Pane View Controller Methods

- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    // Make sure that we don't have a nil completion block
    void(^localCompletion)() = ^{
        self.view.userInteractionEnabled = YES;
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:didAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self didAnimateToPane:paneViewController];
        }
        if (completion != nil) {
            completion();
        }
    };
    
    if (!animated || (paneViewController == self.paneViewController) || (self.paneViewController == nil)) {
        self.paneViewController = paneViewController;
        localCompletion();
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    void(^movePaneToSide)() = ^{
        CGRect paneViewFrame = _paneView.frame;
        paneViewFrame.origin.x = CGRectGetWidth(self.view.frame) + 20.0;
        _paneView.frame = paneViewFrame;
    };
    
    void(^movePaneToClosed)() = ^{
        CGRect paneViewFrame = _paneView.frame;
        paneViewFrame.origin.x = 0.0;
        _paneView.frame = paneViewFrame;
    };
    
    // If we're trying to animate to the currently visible pane view controller, just close
    if (paneViewController == self.paneViewController) {
        
        [UIView animateWithDuration:MSNavigationPaneAnimationDurationOpenToClosed
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:movePaneToClosed
                         completion:^(BOOL animationFinished) {
                             _paneView.state = MSDraggableViewStateClosed;
                             localCompletion();
                         }];
    }
    // Otherwise, animate off to the right first, set the pane view controller, and then animate closed
    else {
        
        void(^newPaneCompletion)(BOOL finished) = ^(BOOL finished) {
            
            self.paneViewController = paneViewController;
            
            // Force redraw of the pane view (for smooth animation)
            [_paneView setNeedsDisplay];
            [CATransaction flush];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Slide the pane back into view
                [UIView animateWithDuration:MSNavigationPaneAnimationDurationSideToClosed
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:movePaneToClosed
                                 completion:^(BOOL animationFinished) {
                                     if (animationFinished) {
                                         _paneView.state = MSDraggableViewStateClosed;
                                         localCompletion();
                                     }
                                 }];
            });
        };
        
        CGFloat duration = 0.0;
        if (self.paneState == MSNavigationPaneStateOpen) {
            duration = MSNavigationPaneAnimationDurationOpenToSide;
        } else if (self.paneState == MSNavigationPaneStateClosed) {
            duration = MSNavigationPaneAnimationDurationClosedToSide;
        }
        
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:willAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self willAnimateToPane:paneViewController];
        }
        
        [UIView animateWithDuration:duration
                         animations:movePaneToSide
                         completion:newPaneCompletion];
    }
}

- (void)setPaneState:(MSNavigationPaneState)aPaneState animated:(BOOL)animated
{
    void(^animatePaneOpen)() = ^{
        CGRect paneViewFrame = _paneView.frame;
        paneViewFrame.origin.x = MSNavigationPaneOpenStateMasterDisplayWidth;
        _paneView.frame = paneViewFrame;
    };
    
    void(^animatePaneOpenCompletion)(BOOL animationFinished) = ^(BOOL animationFinished) {
        _paneView.state = MSDraggableViewStateOpen;
    };
    
    void(^animatePaneClosed)() = ^{
        CGRect paneViewFrame = _paneView.frame;
        paneViewFrame.origin.x = 0.0;
        _paneView.frame = paneViewFrame;
    };
    
    void(^animatePaneClosedCompletion)(BOOL animationFinished) = ^(BOOL animationFinished) {
        _paneView.state = MSDraggableViewStateClosed;
    };
    
    if (aPaneState == MSNavigationPaneStateClosed) {
        
        if (animated) {
            [UIView animateWithDuration:MSNavigationPaneAnimationDurationClosedToOpen
                             animations:animatePaneClosed
                             completion:animatePaneClosedCompletion];
        } else {
            animatePaneClosed();
            animatePaneClosedCompletion(YES);
        }
        
    } else if (aPaneState == MSNavigationPaneStateOpen) {
        
        if (animated) {
            [UIView animateWithDuration:MSNavigationPaneAnimationDurationOpenToClosed
                             animations:animatePaneOpen
                             completion:animatePaneOpenCompletion];
        } else {
            animatePaneOpen();
            animatePaneOpenCompletion(YES);
        }
    }
}

- (void)setAppearanceType:(MSNavigationPaneAppearanceType)appearanceType
{
    // Reset scale transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeZoom) {
        self.masterView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    }
    // Reset translate transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeParallax) {
        self.masterView.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 0.0);
    }
    _appearanceType = appearanceType;
}

- (MSNavigationPaneAppearanceType)appearanceType
{
    return _appearanceType;
}

#pragma mark - MSDraggableViewDelegate

- (void)draggableView:(MSDraggableView *)draggableView wasDraggedToFraction:(CGFloat)fraction
{
    if (_appearanceType == MSNavigationPaneAppearanceTypeZoom) {
        CGFloat scale = (1.0 - (fraction * MSNavigationPaneAppearanceTypeZoomScaleFraction));
        self.masterView.layer.transform = CATransform3DMakeScale(scale, scale, scale);
    }
    else if (_appearanceType == MSNavigationPaneAppearanceTypeParallax) {
        CGFloat xTranslate = -((MSNavigationPaneOpenStateMasterDisplayWidth * fraction) * MSNavigationPaneAppearanceTypeParallaxOffsetFraction);
        self.masterView.layer.transform = CATransform3DMakeTranslation(xTranslate, 0.0, 0.0);
    }
}

@end
