//
//  MSDynamicsDrawerViewController.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012-2014 Monospace Ltd. All rights reserved.
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

#import <QuartzCore/QuartzCore.h>
#import "MSDynamicsDrawerViewController.h"
#import "UIViewController+ContainmentHelpers.h"
#import "UIView+ViewHierarchyAction.h"
#import "UIPanGestureRecognizer+BeginEdges.h"
#import "MSDynamicsDrawerHelperFunctions.h"

@interface MSDynamicsDrawerViewController () <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate>

// External properties redefined as `readwrite` instead of `readonly`
@property (nonatomic, strong, readwrite, setter = _setDrawerView:) UIView *drawerView;
@property (nonatomic, strong, readwrite, setter = _setPaneView:) UIView *paneView;
@property (nonatomic, assign, readwrite, setter = _setPossibleDrawerDirection:) MSDynamicsDrawerDirection possibleDrawerDirection;
@property (nonatomic, assign, readwrite, setter = _setCurrentDrawerDirection:) MSDynamicsDrawerDirection currentDrawerDirection;
// Internal properties
@property (nonatomic, assign, setter = _setIsRotating:) BOOL _rotating;
@property (nonatomic, strong, setter = _setVisibleDrawerViewController:) UIViewController *_visibleDrawerViewController;
@property (nonatomic, strong, setter = _setDrawerViewControllers:) NSMutableDictionary *_drawerViewControllers;
@property (nonatomic, strong, setter = _setPaneDragRevealEnabledValues:) NSMutableDictionary *_paneDragRevealEnabledValues;
@property (nonatomic, strong, setter = _setPaneTapToCloseEnabledValues:) NSMutableDictionary *_paneTapToCloseEnabledValues;
@property (nonatomic, strong, setter = _setStylers:) NSMutableDictionary *_stylers;
@property (nonatomic, strong, setter = _setTouchForwardingClasses:) NSMutableSet *_touchForwardingClasses;
@property (nonatomic, strong, setter = _setPanePanGestureRecognizer:) UIPanGestureRecognizer *_panePanGestureRecognizer;
@property (nonatomic, strong, setter = _setPaneTapGestureRecognizer:) UITapGestureRecognizer *_paneTapGestureRecognizer;
@property (nonatomic, strong, setter = _setDynamicAnimator:) UIDynamicAnimator *_dynamicAnimator;
@property (nonatomic, strong, setter = _setPaneBehavior:) UIDynamicItemBehavior *_paneBehavior;
@property (nonatomic, copy, setter = _setDynamicAnimatorCompletion:) void (^_dynamicAnimatorCompletion)(void);
@property (nonatomic, assign, readonly) dispatch_once_t initPaneViewSlideOffAnimationEnabled;
@property (nonatomic, assign, readonly) dispatch_once_t initScreenEdgePanCancelsConflictingGestures;

@end

@implementation MSDynamicsDrawerViewController

@synthesize screenEdgePanCancelsConflictingGestures = _screenEdgePanCancelsConflictingGestures;
@synthesize paneViewSlideOffAnimationEnabled = _paneViewSlideOffAnimationEnabled;
@synthesize panePositioningBehavior = _panePositioningBehavior;
@synthesize paneBounceBehavior = _paneBounceBehavior;

#pragma mark - NSObject (NSKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.paneView) && [keyPath isEqualToString:NSStringFromSelector(@selector(center))]) {
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            [self _paneViewDidUpdatePosition];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.drawerView];
    [self.view addSubview:self.paneView];
    self.drawerView.frame = self.drawerView.superview.bounds;
    self.paneView.frame = self.paneView.superview.bounds;
    [self.view sendSubviewToBack:self.drawerView];
    [self.view bringSubviewToFront:self.paneView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self._rotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self._rotating = NO;
    [self _updateStylers];
}

- (BOOL)shouldAutorotate
{
    // Do not allow rotation when not in resting state (dynamic animator is running or pane pan gesture recognizer is active)
    return (!self._dynamicAnimator.isRunning && (self._panePanGestureRecognizer.state == UIGestureRecognizerStatePossible));
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    if (self.paneViewController) {
        supportedInterfaceOrientations &= self.paneViewController.supportedInterfaceOrientations;
    }
    if (self._visibleDrawerViewController) {
        supportedInterfaceOrientations &= self._visibleDrawerViewController.supportedInterfaceOrientations;
    }
    return supportedInterfaceOrientations;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return [self viewControllerForStatusBarAppearance];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return [self viewControllerForStatusBarAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.paneView addObserver:self forKeyPath:NSStringFromSelector(@selector(center)) options:0 context:NULL];
    [self _stylersWillMoveToDrawerViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _stylersDidMoveToDrawerViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _stylersWillMoveToDrawerViewController:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _stylersDidMoveToDrawerViewController:nil];
    [self.paneView removeObserver:self forKeyPath:NSStringFromSelector(@selector(center))];
}

#pragma mark - MSDynamicsDrawerViewController

#pragma mark Subviews

- (UIView *)drawerView
{
    if (!_drawerView) {
        self.drawerView = ({
            UIView *view = [UIView new];
            view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            view;
        });
    }
    return _drawerView;
}

- (UIView *)paneView
{
    if (!_paneView) {
        self.paneView = ({
            UIView *view = [UIView new];
            view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            [view addGestureRecognizer:self._panePanGestureRecognizer];
            [view addGestureRecognizer:self._paneTapGestureRecognizer];
            view;
        });
    }
    return _paneView;
}

#pragma mark View Controller Containment

- (UIViewController *)viewControllerForStatusBarAppearance
{
    if (((self._dynamicAnimator.isRunning) && self.panePositioningBehavior.targetPaneState == MSDynamicsDrawerPaneStateOpenWide) || self.paneState == MSDynamicsDrawerPaneStateOpenWide) {
        return [self drawerViewControllerForDirection:self.currentDrawerDirection];
    } else {
        return self.paneViewController;
    }
}

#pragma mark Drawer View Controller

- (NSMutableDictionary *)_drawerViewControllers
{
    if (!__drawerViewControllers) {
        self._drawerViewControllers = [NSMutableDictionary new];
    }
    return __drawerViewControllers;
}

- (void)_setVisibleDrawerViewController:(UIViewController *)drawerViewController
{
    [self replaceViewController:self._visibleDrawerViewController withViewController:drawerViewController inContainerView:self.drawerView completion:^{
        __visibleDrawerViewController = drawerViewController;
    }];
}

- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    [self setDrawerViewController:drawerViewController forDirection:direction preloadView:NO];
}

- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction preloadView:(BOOL)preloadView
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts cardinal drawer directions");
    for (UIViewController * __unused currentDrawerViewController in self._drawerViewControllers) {
        NSAssert(currentDrawerViewController != drawerViewController, @"Unable to add a drawer view controller when it's previously been added");
    }
    UIViewController *existingDrawerViewController = self._drawerViewControllers[@(direction)];
    // New drawer view controller
    if (drawerViewController && !existingDrawerViewController) {
        self.possibleDrawerDirection |= direction;
        self._drawerViewControllers[@(direction)] = drawerViewController;
    }
    // Removing existing drawer view controller
    else if (!drawerViewController && existingDrawerViewController) {
        self.possibleDrawerDirection ^= direction;
        [self._drawerViewControllers removeObjectForKey:@(direction)];
    }
    // Replace existing drawer view controller
    else if (drawerViewController && existingDrawerViewController) {
        self._drawerViewControllers[@(direction)] = drawerViewController;
    }
    // If preloading the view, just open in the specified direction (without actually opening the pane to reveal the drawer) and then immediately close.
    if (preloadView) {
        self.currentDrawerDirection = direction;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentDrawerDirection = MSDynamicsDrawerDirectionNone;
        });
    }
}

- (UIViewController *)drawerViewControllerForDirection:(MSDynamicsDrawerDirection)direction
{
    return self._drawerViewControllers[@(direction)];
}

#pragma mark Pane View Controller

- (void)setPaneViewController:(UIViewController *)paneViewController
{
    [self replaceViewController:self.paneViewController withViewController:paneViewController inContainerView:self.paneView completion:^{
        _paneViewController = paneViewController;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSParameterAssert(paneViewController);
    if (!animated) {
        self.paneViewController = paneViewController;
        if (completion) completion();
        return;
    }
    if (self.paneViewController != paneViewController) {
        [self.paneViewController willMoveToParentViewController:nil];
        [self.paneViewController beginAppearanceTransition:NO animated:animated];
        void(^transitionToNewPaneViewController)() = ^{
            [paneViewController willMoveToParentViewController:self];
            [self.paneViewController.view removeFromSuperview];
            [self.paneViewController removeFromParentViewController];
            [self.paneViewController didMoveToParentViewController:nil];
            [self.paneViewController endAppearanceTransition];
            [self addChildViewController:paneViewController];
            paneViewController.view.frame = self.paneView.bounds;
            [paneViewController beginAppearanceTransition:YES animated:animated];
            [self.paneView addSubview:paneViewController.view];
            [self.paneView sendSubviewToBack:paneViewController.view];
            _paneViewController = paneViewController;
            [self setNeedsStatusBarAppearanceUpdate];
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = self;
                [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:animated allowUserInterruption:YES completion:^{
                    [paneViewController didMoveToParentViewController:weakSelf];
                    [paneViewController endAppearanceTransition];
                    if (completion) completion();
                }];
            });
        };
        if (self.paneViewSlideOffAnimationEnabled) {
            [self setPaneState:MSDynamicsDrawerPaneStateOpenWide animated:animated allowUserInterruption:NO completion:transitionToNewPaneViewController];
        } else {
            transitionToNewPaneViewController();
        }
    }
    // If trying to set to the currently visible pane view controller, just close
    else {
        [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:animated allowUserInterruption:YES completion:^{
            if (completion) completion();
        }];
    }
}

#pragma mark Dynamics

- (UIDynamicAnimator *)_dynamicAnimator
{
    if (!__dynamicAnimator) {
        self._dynamicAnimator = ({
            UIDynamicAnimator *dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
            dynamicAnimator.delegate = self;
            dynamicAnimator;
        });
    }
    return __dynamicAnimator;
}

- (UIDynamicItemBehavior *)_paneBehavior
{
    if (!__paneBehavior) {
        self._paneBehavior = ({
            UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paneView]];
            __weak typeof(self) weakSelf = self;
            dynamicItemBehavior.action = ^{
                [weakSelf _dynamicAnimatorDidUpdate];
            };
            dynamicItemBehavior;
        });
    }
    return __paneBehavior;
}

- (void)_dynamicAnimatorDidUpdate
{
    [self _paneViewDidUpdatePosition];
}

- (void)_addPanePositioningBehavior:(MSPaneBehavior <MSPanePositioningBehavior> *)behavior toPositionPaneInState:(MSDynamicsDrawerPaneState)paneState
{
    [self _addPanePositioningBehavior:behavior toPositionPaneInState:paneState withThrowVelocity:CGPointZero];
}

- (void)_addPanePositioningBehavior:(MSPaneBehavior <MSPanePositioningBehavior> *)behavior toPositionPaneInState:(MSDynamicsDrawerPaneState)paneState withThrowVelocity:(CGPoint)throwVelocity
{
    if (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
        return;
    }
    
    // Cancel pane pan gesture if active
    self._panePanGestureRecognizer.enabled = NO;
    self._panePanGestureRecognizer.enabled = YES;
    
    // Remove all other pane positioning behaviors
    for (UIDynamicBehavior *currentBehavior in self._dynamicAnimator.behaviors) {
        if ([currentBehavior conformsToProtocol:@protocol(MSPanePositioningBehavior)]) {
            [self._dynamicAnimator removeBehavior:currentBehavior];
        }
    }
    
    // Build a velocity vector with a component normalized to the current direction
    CGFloat * const throwVelocityComponent = MSPointComponentForDrawerDirection(&throwVelocity, self.currentDrawerDirection);
    CGPoint pushVelocityDirection = CGPointZero;
    CGFloat * const pushVelocityComponent = MSPointComponentForDrawerDirection(&pushVelocityDirection, self.currentDrawerDirection);
    *pushVelocityComponent = *throwVelocityComponent;
    
    // Add the velocity vector to the pane
    if (self._paneBehavior.dynamicAnimator != self._dynamicAnimator) {
        [self._dynamicAnimator addBehavior:self._paneBehavior];
    }
    [self._paneBehavior addLinearVelocity:pushVelocityDirection forItem:self.paneView];
    
    // Must be after the pane receives its linear velocty
    if (behavior.dynamicAnimator != self._dynamicAnimator) {
        [self._dynamicAnimator addBehavior:behavior];
    }
    [behavior positionPaneInState:paneState forDirection:self.currentDrawerDirection];
    
    [self _setPaneViewControllerViewUserInteractionEnabled:(paneState == MSDynamicsDrawerPaneStateClosed)];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (MSPaneBehavior <MSPanePositioningBehavior> *)panePositioningBehavior
{
    if (!_panePositioningBehavior && self.paneView) {
        self.panePositioningBehavior = [[MSPaneSnapBehavior alloc] initWithDrawerViewController:self];
    }
    return _panePositioningBehavior;
}

- (void)setPanePositioningBehavior:(MSPaneBehavior <MSPanePositioningBehavior> *)panePositioningBehavior
{
    NSAssert([panePositioningBehavior isKindOfClass:[MSPaneBehavior class]], @"Pane positioning behavior must be a MSPaneBehavior");
    NSAssert([panePositioningBehavior conformsToProtocol:@protocol(MSPanePositioningBehavior)], @"Pane positioning behavior must conform to MSPanePositioningBehavior");
    if (![self._dynamicAnimator isRunning]) {
        _panePositioningBehavior = panePositioningBehavior;
    }
}

static CGFloat const MSPaneBounceBehaviorDefaultPaneElasticity = 0.5;

- (MSPaneBehavior <MSPaneBounceBehavior> *)paneBounceBehavior
{
    if (!_paneBounceBehavior) {
        self.paneBounceBehavior = ({
            MSPaneGravityBehavior *paneBounceBehavior = [[MSPaneGravityBehavior alloc] initWithDrawerViewController:self];
            paneBounceBehavior.paneBehavior.elasticity = MSPaneBounceBehaviorDefaultPaneElasticity;
            paneBounceBehavior;
        });
    }
    return _paneBounceBehavior;
}

- (void)setPaneBounceBehavior:(MSPaneBehavior <MSPaneBounceBehavior> *)paneBounceBehavior
{
    NSAssert([paneBounceBehavior isKindOfClass:[MSPaneBehavior class]], @"Pane bounce behavior must be a MSPaneBehavior");
    NSAssert([paneBounceBehavior conformsToProtocol:@protocol(MSPaneBounceBehavior)], @"Pane bounce behavior must conform to MSPaneBounceBehavior");
    if (![self._dynamicAnimator isRunning]) {
        _paneBounceBehavior = paneBounceBehavior;
    }
}

#pragma mark Layout

- (MSDynamicsDrawerPaneLayout *)paneLayout
{
    if (!_paneLayout) {
        self.paneLayout = [[MSDynamicsDrawerPaneLayout alloc] initWithPaneContainerView:self.view];
    }
    return _paneLayout;
}

#pragma mark Bouncing

- (void)bouncePaneOpen
{
    [self bouncePaneOpenAllowingUserInterruption:YES completion:nil];
}

- (void)bouncePaneOpenAllowingUserInterruption:(BOOL)allowingUserInterruption completion:(void (^)(void))completion
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.possibleDrawerDirection), @"Unable to bounce open with multiple possible drawer directions");
    [self bouncePaneOpenInDirection:self.currentDrawerDirection allowUserInterruption:allowingUserInterruption completion:completion];
}

- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction
{
    [self bouncePaneOpenInDirection:direction allowUserInterruption:YES completion:nil];
}

- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion
{
    NSAssert(((self.possibleDrawerDirection & direction) == direction), @"Unable to bounce open with impossible/multiple directions");
    
    self.currentDrawerDirection = direction;
    
    [self._dynamicAnimator addBehavior:self.paneBounceBehavior];
    [self._dynamicAnimator addBehavior:self._paneBehavior];
    [self.paneBounceBehavior bouncePaneOpenInDirection:direction];
    
    if (!allowUserInterruption) [self _setViewUserInteractionEnabled:NO];
    __weak typeof(self) weakSelf = self;
    self._dynamicAnimatorCompletion = ^{
        if (!allowUserInterruption) [weakSelf _setViewUserInteractionEnabled:YES];
        if (completion) completion();
    };
}

#pragma mark Stylers

- (NSMutableDictionary *)_stylers
{
    if (!__stylers) {
        self._stylers = [NSMutableDictionary new];
    }
    return __stylers;
}

- (void)addStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction
{
    if (!styler) {
        return;
    }
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
        // Lazy creation of stylers sets
        if (!self._stylers[@(maskedDirection)]) {
            self._stylers[@(maskedDirection)] = [NSMutableSet new];
        }
        if ([self isViewLoaded] && [styler respondsToSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:)]) {
            [styler willMoveToDynamicsDrawerViewController:self forDirection:maskedDirection];
        }
        NSMutableSet *stylersSet = self._stylers[@(maskedDirection)];
        [stylersSet addObject:styler];
        if ([self isViewLoaded] && [styler respondsToSelector:@selector(didMoveToDynamicsDrawerViewController:forDirection:)]) {
            [styler didMoveToDynamicsDrawerViewController:self forDirection:maskedDirection];
        }
    });
}

- (void)removeStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction
{
    if (!styler) {
        return;
    }
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
        if ([self isViewLoaded] && [styler respondsToSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:)]) {
            [styler willMoveToDynamicsDrawerViewController:nil forDirection:maskedDirection];
        }
        NSMutableSet *stylersSet = self._stylers[@(maskedDirection)];
        [stylersSet removeObject:styler];
        if ([self isViewLoaded] && [styler respondsToSelector:@selector(didMoveToDynamicsDrawerViewController:forDirection:)]) {
            [styler didMoveToDynamicsDrawerViewController:nil forDirection:maskedDirection];
        }
    });
}

- (void)addStylers:(NSArray *)stylers forDirection:(MSDynamicsDrawerDirection)direction
{
    for (id <MSDynamicsDrawerStyler> styler in stylers) {
        [self addStyler:styler forDirection:direction];
    }
}

- (void)_updateStylers
{
    // Prevent weird animation issues on rotation
    if (self._rotating) {
        return;
    }
    CGFloat paneClosedFraction = [self.paneLayout paneClosedFractionForPaneWithCenter:self.paneView.center forDirection:self.currentDrawerDirection];
    for (id <MSDynamicsDrawerStyler> styler in [self _stylersForDirection:self.currentDrawerDirection]) {
        if ([styler respondsToSelector:@selector(dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:)]) {
            [styler dynamicsDrawerViewController:self didUpdatePaneClosedFraction:paneClosedFraction forDirection:self.currentDrawerDirection];
        }
    }
}

- (void)_stylersWillMoveToDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedDirection){
        NSMutableSet *stylers = self._stylers[@(maskedDirection)];
        for (id <MSDynamicsDrawerStyler> styler in stylers) {
            if ([styler respondsToSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:)]) {
                [styler willMoveToDynamicsDrawerViewController:drawerViewController forDirection:maskedDirection];
            }
        }
    });

}

- (void)_stylersDidMoveToDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedDirection){
        NSMutableSet *stylers = self._stylers[@(maskedDirection)];
        for (id <MSDynamicsDrawerStyler> styler in stylers) {
            if ([styler respondsToSelector:@selector(didMoveToDynamicsDrawerViewController:forDirection:)]) {
                [styler didMoveToDynamicsDrawerViewController:drawerViewController forDirection:maskedDirection];
            }
        }
    });
}

- (NSSet *)_stylersForDirection:(MSDynamicsDrawerDirection)direction
{
    NSMutableSet *stylers;
    if (!MSDynamicsDrawerDirectionIsMasked(direction)) {
        stylers = self._stylers[@(direction)];
    } else {
        stylers = [NSMutableSet new];
        MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
            [stylers unionSet:self._stylers[@(maskedDirection)]];
        });
    }
    return stylers;
}

- (NSArray *)stylersForDirection:(MSDynamicsDrawerDirection)direction
{
    return [[self _stylersForDirection:direction] allObjects];
}

#pragma mark Pane State

- (void)_paneViewDidUpdatePosition
{
    // If the potential state is open wide and the pane has reached it, remove the dynamic animator's behaviors to speed up state transitions
    if ((self.panePositioningBehavior.targetPaneState == MSDynamicsDrawerPaneStateOpenWide) && [self.paneLayout paneWithCenter:self.paneView.center hasReachedOpenWideStateForDirection:self.currentDrawerDirection]) {
        [self._dynamicAnimator removeAllBehaviors];
    }
    
    [self _updateStylers];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState
{
    [self setPaneState:paneState animated:NO allowUserInterruption:NO completion:nil];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction
{
    [self setPaneState:paneState inDirection:direction animated:NO allowUserInterruption:NO completion:nil];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion
{
    // If the drawer is getting opened and there's more than one possible direction enforce that the directional eqivalent is used
    MSDynamicsDrawerDirection direction;
    if ((paneState != MSDynamicsDrawerPaneStateClosed) && (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone)) {
        NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.possibleDrawerDirection), @"Unable to set the pane to an open state with multiple possible drawer directions, as the drawer direction to open in is indeterminate. Use `setPaneState:inDirection:animated:allowUserInterruption:completion:` instead.");
        direction = self.possibleDrawerDirection;
    } else {
        direction = self.currentDrawerDirection;
    }
    [self setPaneState:paneState inDirection:direction animated:animated allowUserInterruption:allowUserInterruption completion:completion];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion
{
    NSAssert(((self.possibleDrawerDirection & direction) == direction), @"Unable to set pane state with no drawer set for the requested direction");
    
    // If there requested direction is in a different axis (vertical/horizontal) than the current direction, don't continue
    if (self.currentDrawerDirection != MSDynamicsDrawerDirectionNone) {
        if ((self.currentDrawerDirection & MSDynamicsDrawerDirectionHorizontal) && !(direction & MSDynamicsDrawerDirectionHorizontal)) {
            return;
        }
        if ((self.currentDrawerDirection & MSDynamicsDrawerDirectionVertical) && !(direction & MSDynamicsDrawerDirectionVertical)) {
            return;
        }
    }
    
    // If the pane is already positioned in the desired pane state and direction, don't continue
    MSDynamicsDrawerPaneState currentPaneState = -1;
    if ([self.paneLayout paneWithCenter:self.paneView.center isInValidState:&currentPaneState forDirection:self.currentDrawerDirection] && (currentPaneState == paneState)) {
        // If already closed, *in any direction*, don't continue
        if (currentPaneState == MSDynamicsDrawerPaneStateClosed) {
            if (completion) completion();
            return;
        }
        // If opened, *in the correct direction*, don't continue
        else if (direction == self.currentDrawerDirection) {
            if (completion) completion();
            return;
        }
    }
    
    [self _informRelevantObjectsOfPotentialUpdateToPaneState:paneState forDirection:direction];
    
    // If opening in a specified direction, set the drawer to that direction
    if ((paneState != MSDynamicsDrawerPaneStateClosed)) {
        self.currentDrawerDirection = direction;
    }
    
    if (animated) {
        [self _addPanePositioningBehavior:self.panePositioningBehavior toPositionPaneInState:paneState];
        if (!allowUserInterruption) [self _setViewUserInteractionEnabled:NO];
        __weak typeof(self) weakSelf = self;
        self._dynamicAnimatorCompletion = ^{
            if (!allowUserInterruption) [weakSelf _setViewUserInteractionEnabled:YES];
            if (completion) completion();
        };
    } else {
        [self _setPaneState:paneState];
        if (completion) completion();
    }
}

- (void)_setPaneState:(MSDynamicsDrawerPaneState)paneState
{
    [self _updateStylers];
    
    MSDynamicsDrawerDirection previousDirection = self.currentDrawerDirection;
    MSDynamicsDrawerDirection forDirection = ((self.paneState != MSDynamicsDrawerPaneStateClosed) ? self.currentDrawerDirection : previousDirection);
    
    // Update pane center regardless of if it's changed
    self.paneView.center = [self.paneLayout paneCenterForPaneState:paneState direction:self.currentDrawerDirection];
    
    // Post accessibility notifications
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
    if (_paneState != paneState) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(paneState))];
        _paneState = paneState;
        [self didChangeValueForKey:NSStringFromSelector(@selector(paneState))];
    }
    
    [self _updateStylers];
    
#warning re-enable
//    [self setNeedsStatusBarAppearanceUpdate];
    
    if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:)]) {
        [self.delegate dynamicsDrawerViewController:self didUpdateToPaneState:paneState forDirection:forDirection];
    }
    
    for (id <MSDynamicsDrawerStyler> styler in [self _stylersForDirection:self.currentDrawerDirection]) {
        if ([styler respondsToSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:)]) {
            [styler dynamicsDrawerViewController:self didUpdateToPaneState:paneState forDirection:forDirection];
        }
    }
    
    // Update `currentDirection` to `MSDynamicsDrawerDirectionNone` if the `paneState` is `MSDynamicsDrawerPaneStateClosed`
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        self.currentDrawerDirection = MSDynamicsDrawerDirectionNone;
    }
}

- (BOOL)paneViewSlideOffAnimationEnabled
{
    dispatch_once(&_initPaneViewSlideOffAnimationEnabled, ^{
        _paneViewSlideOffAnimationEnabled = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    });
    return _paneViewSlideOffAnimationEnabled;
}

- (void)setPaneViewSlideOffAnimationEnabled:(BOOL)paneViewSlideOffAnimationEnabled
{
    dispatch_once(&_initPaneViewSlideOffAnimationEnabled, ^{ });
    _paneViewSlideOffAnimationEnabled = paneViewSlideOffAnimationEnabled;
}

#pragma mark Current Drawer Direction

- (void)_setCurrentDrawerDirection:(MSDynamicsDrawerDirection)currentDrawerDirection
{
    NSAssert(!MSDynamicsDrawerDirectionIsMasked(currentDrawerDirection), @"Only accepts non-masked directions as current drawer direction");
    NSAssert(!((currentDrawerDirection == MSDynamicsDrawerDirectionNone) && (self.paneState != MSDynamicsDrawerPaneStateClosed)), @"Can't set direction to none with a non-closed pane state");
    
    if (_currentDrawerDirection == currentDrawerDirection) return;
    
    _currentDrawerDirection = currentDrawerDirection;
    
    self._visibleDrawerViewController = self._drawerViewControllers[@(currentDrawerDirection)];
    
    // Disable pane view interaction when not closed
    [self _setPaneViewControllerViewUserInteractionEnabled:(currentDrawerDirection == MSDynamicsDrawerDirectionNone)];
}

#pragma mark Possible drawer direction

- (void)_setPossibleDrawerDirection:(MSDynamicsDrawerDirection)possibleDrawerDirection
{
    NSAssert(MSDynamicsDrawerDirectionIsValid(possibleDrawerDirection), @"Only accepts valid drawer directions as possible drawer direction");
    _possibleDrawerDirection = possibleDrawerDirection;
}

#pragma mark Gestures

- (UIPanGestureRecognizer *)_panePanGestureRecognizer
{
    if (!__panePanGestureRecognizer) {
        self._panePanGestureRecognizer = ({
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panePanned:)];
            panGestureRecognizer.delegate = self;
            panGestureRecognizer;
        });
    }
    return __panePanGestureRecognizer;
}

- (UITapGestureRecognizer *)_paneTapGestureRecognizer
{
    if (!__paneTapGestureRecognizer) {
        self._paneTapGestureRecognizer = ({
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_paneTapped:)];
            tapGestureRecognizer.delegate = self;
            tapGestureRecognizer;
        });
    }
    return __paneTapGestureRecognizer;
}

#pragma mark Pane Drag Reveal

- (NSMutableDictionary *)_paneDragRevealEnabledValues
{
    if (!__paneDragRevealEnabledValues) {
        self._paneDragRevealEnabledValues = [NSMutableDictionary new];
    }
    return __paneDragRevealEnabledValues;
}

- (void)setPaneDragRevealEnabled:(BOOL)paneDraggingEnabled forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
        self._paneDragRevealEnabledValues[@(maskedDirection)] = @(paneDraggingEnabled);
    });
}

- (BOOL)paneDragRevealEnabledForDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts singular directions when querying for drag reveal enabled");
    NSNumber *paneDragRevealEnabled = self._paneDragRevealEnabledValues[@(direction)];
    if (!paneDragRevealEnabled) paneDragRevealEnabled = @(YES);
    return [paneDragRevealEnabled boolValue];
}

#pragma mark Pane Tap To Close

- (NSMutableDictionary *)_paneTapToCloseEnabledValues
{
    if (!__paneTapToCloseEnabledValues) {
        self._paneTapToCloseEnabledValues = [NSMutableDictionary new];
    }
    return __paneTapToCloseEnabledValues;
}

- (void)setPaneTapToCloseEnabled:(BOOL)paneTapToCloseEnabled forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
        self._paneTapToCloseEnabledValues[@(maskedDirection)] = @(paneTapToCloseEnabled);
    });
}

- (BOOL)paneTapToCloseEnabledForDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts singular directions when querying for drag reveal enabled");
    NSNumber *paneTapToCloseEnabled = self._paneTapToCloseEnabledValues[@(direction)];
    if (!paneTapToCloseEnabled) paneTapToCloseEnabled = @(YES);
    return [paneTapToCloseEnabled boolValue];
}

- (BOOL)screenEdgePanCancelsConflictingGestures
{
    dispatch_once(&_initScreenEdgePanCancelsConflictingGestures, ^{
        _screenEdgePanCancelsConflictingGestures = YES;
    });
    return _screenEdgePanCancelsConflictingGestures;
}

- (void)setScreenEdgePanCancelsConflictingGestures:(BOOL)screenEdgePanCancelsConflictingGestures
{
    dispatch_once(&_initScreenEdgePanCancelsConflictingGestures, ^{ });
    _screenEdgePanCancelsConflictingGestures = screenEdgePanCancelsConflictingGestures;
}

- (NSMutableSet *)_touchForwardingClasses
{
    if (!__touchForwardingClasses) {
        self._touchForwardingClasses = [NSMutableSet setWithArray:@[[UISlider class], [UISwitch class]]];
    }
    return __touchForwardingClasses;
}

- (void)registerTouchForwardingClass:(Class)touchForwardingClass
{
    NSAssert([touchForwardingClass isSubclassOfClass:[UIView class]], @"Registered touch forwarding classes must be a subclass of UIView");
    [self._touchForwardingClasses addObject:touchForwardingClass];
}

- (MSDynamicsDrawerDirection)_directionForPanWithStartLocation:(CGPoint)startLocation currentLocation:(CGPoint)currentLocation
{
    __block MSDynamicsDrawerDirection panDirection = MSDynamicsDrawerDirectionNone;
    __block CGFloat maxPanDelta = -CGFLOAT_MAX;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(self.possibleDrawerDirection, ^(MSDynamicsDrawerDirection possibleDirection) {

        CGFloat * const startLocationComponent = MSPointComponentForDrawerDirection(((CGPoint * const)&startLocation), possibleDirection);
        CGFloat * const currentLocationComponent = MSPointComponentForDrawerDirection(((CGPoint * const)&currentLocation), possibleDirection);
        CGFloat panDelta = 0.0;
        if (startLocationComponent && currentLocationComponent) {
            panDelta = (*currentLocationComponent - *startLocationComponent);
        }
        MSDynamicsDrawerDirection direction = MSDynamicsDrawerDirectionNone;
        if (possibleDirection & MSDynamicsDrawerDirectionHorizontal) {
            if (panDelta > 0.0) {
                direction = MSDynamicsDrawerDirectionLeft;
            } else if (panDelta < 0.0) {
                direction = MSDynamicsDrawerDirectionRight;
            }
        } else if (possibleDirection & MSDynamicsDrawerDirectionVertical) {
            if (panDelta > 0.0) {
                direction = MSDynamicsDrawerDirectionTop;
            } else if (panDelta < 0.0) {
                direction = MSDynamicsDrawerDirectionBottom;
            }
        }
        if (fabsf(panDelta) > maxPanDelta) {
            maxPanDelta = fabsf(panDelta);
            panDirection = direction;
        }
    });
    return panDirection;
}

static CGFloat const MSPaneThrowVelocityThreshold = 100.0;

- (BOOL)_paneShouldThrowToState:(inout MSDynamicsDrawerPaneState *)state forVelocity:(CGPoint)velocity inDirection:(MSDynamicsDrawerDirection)direction;
{
    CGFloat * const velocityComponent = MSPointComponentForDrawerDirection(&velocity, direction);
    if (!velocityComponent || (fabs(*velocityComponent) < MSPaneThrowVelocityThreshold)) {
        return NO;
    }
    if (velocityComponent && (direction & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft))) {
        *state = ((*velocityComponent > 0.0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    } else if (velocityComponent && (direction & (MSDynamicsDrawerDirectionBottom | MSDynamicsDrawerDirectionRight))) {
        *state = ((*velocityComponent < 0.0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    }
    return YES;
}

- (MSDynamicsDrawerPaneState)_paneStateForPanVelocity:(CGFloat)panVelocity
{
    if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft)) {
        return ((panVelocity > 0.0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    }
    if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionBottom | MSDynamicsDrawerDirectionRight)) {
        return ((panVelocity < 0.0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    }
    return MSDynamicsDrawerPaneStateClosed;
}

#pragma mark User Interaction

- (void)_setViewUserInteractionEnabled:(BOOL)enabled
{
    static NSInteger disableCount;
    disableCount = (!enabled ? (disableCount + 1) : MAX((disableCount - 1), 0));
    self.view.userInteractionEnabled = (disableCount == 0);
}

- (void)_setPaneViewControllerViewUserInteractionEnabled:(BOOL)enabled
{
    self.paneViewController.view.userInteractionEnabled = enabled;
}

#pragma mark UIGestureRecognizer Callbacks

- (void)_paneTapped:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([self paneTapToCloseEnabledForDirection:self.currentDrawerDirection]) {
        [self _informRelevantObjectsOfPotentialUpdateToPaneState:MSDynamicsDrawerPaneStateClosed forDirection:self.currentDrawerDirection];
        [self _addPanePositioningBehavior:self.panePositioningBehavior toPositionPaneInState:MSDynamicsDrawerPaneStateClosed];
    }
}

- (void)_panePanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGPoint panStartLocation;
    static CGPoint paneStartCenter;
    static MSDynamicsDrawerDirection panDirection;
    
    switch ((NSInteger)gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan: {
        // Initialize static variables
        panStartLocation = [gestureRecognizer locationInView:self.paneView];
        paneStartCenter = self.paneView.center;
        panDirection = self.currentDrawerDirection;
        
        // If the drawer is already opened...
        if (self.currentDrawerDirection != MSDynamicsDrawerDirectionNone) {
            // If the current drawer direction's pane drag reveal is disabled, cancel the gesture outright
            if (![self paneDragRevealEnabledForDirection:self.currentDrawerDirection]) {
                gestureRecognizer.enabled = NO;
                gestureRecognizer.enabled = YES;
                break;
            }
            // The user is now panning the pane, which means that they're probably trying to close it
            [self _informRelevantObjectsOfPotentialUpdateToPaneState:MSDynamicsDrawerPaneStateClosed forDirection:self.currentDrawerDirection];
        }
        
        break;
    }
    case UIGestureRecognizerStateChanged: {
        CGPoint currentPanLocation = [gestureRecognizer locationInView:self.paneView];
        MSDynamicsDrawerDirection currentPanDirection = [self _directionForPanWithStartLocation:panStartLocation currentLocation:currentPanLocation];
        // If there's no current direction, try to determine it
        if (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
            MSDynamicsDrawerDirection newDrawerDirection = MSDynamicsDrawerDirectionNone;
            // If a direction has not yet been previousy determined, use the pan direction
            if (panDirection == MSDynamicsDrawerDirectionNone) {
                newDrawerDirection = currentPanDirection;
            } else {
                // Only allow a new direction to be in the same direction as before to prevent swiping between drawers in one gesture
                if (currentPanDirection == panDirection) {
                    newDrawerDirection = panDirection;
                }
            }
            // If the new direction is still none, don't continue
            if (newDrawerDirection == MSDynamicsDrawerDirectionNone) {
                break;
            }
            // Ensure that the new current direction is:
            if ((self.possibleDrawerDirection & newDrawerDirection) && // Possible
                ([self paneDragRevealEnabledForDirection:newDrawerDirection])) // Has drag to reveal enabled
            {
                // The user is now panning the pane, which means that they're probably trying to update it to the opposite state from where it's at
                MSDynamicsDrawerPaneState mayPaneState = ((self.paneState != MSDynamicsDrawerPaneStateClosed) ? MSDynamicsDrawerPaneStateClosed : MSDynamicsDrawerPaneStateOpen);
                [self _informRelevantObjectsOfPotentialUpdateToPaneState:mayPaneState forDirection:newDrawerDirection];
                
                self.currentDrawerDirection = newDrawerDirection;
                // Establish the initial drawer direction if there was none
                if (panDirection == MSDynamicsDrawerDirectionNone) {
                    panDirection = self.currentDrawerDirection;
                }
            }
            // If these criteria aren't met, cancel the gesture
            else {
                gestureRecognizer.enabled = NO;
                gestureRecognizer.enabled = YES;
                break;
            }
        }
        // If the current drawer direction's pane drag reveal is disabled, cancel the gesture
        else if (![self paneDragRevealEnabledForDirection:self.currentDrawerDirection]) {
            gestureRecognizer.enabled = NO;
            gestureRecognizer.enabled = YES;
            break;
        }
        // At this point, panning is able to move the pane independently from the dynamic animator, so remove all behaviors to prevent conflicting behavior
        [self._dynamicAnimator removeAllBehaviors];
        
        CGPoint panTranslation = [gestureRecognizer translationInView:self.view];
        self.paneView.center = [self.paneLayout paneCenterWithTranslation:panTranslation fromCenter:paneStartCenter inDirection:self.currentDrawerDirection];
        
        break;
    }
    case UIGestureRecognizerStateEnded: {
        // If there was no direction after the gesture, don't attempt to update to a new state
        if (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
            break;
        }
        // If the user threw the pane, update to the state that it was thrown to
        MSDynamicsDrawerPaneState throwState;
        CGPoint throwVelocity = [gestureRecognizer velocityInView:self.view];
        if ([self _paneShouldThrowToState:&throwState forVelocity:throwVelocity inDirection:self.currentDrawerDirection]) {
            [self _addPanePositioningBehavior:self.panePositioningBehavior toPositionPaneInState:throwState withThrowVelocity:throwVelocity];
        }
        // If not thrown, just update to nearest `paneState`
        else {
            MSDynamicsDrawerPaneState nearestPaneState = [self.paneLayout nearestStateForPaneWithCenter:self.paneView.center forDirection:self.currentDrawerDirection];
            [self _addPanePositioningBehavior:self.panePositioningBehavior toPositionPaneInState:nearestPaneState withThrowVelocity:throwVelocity];
        }
        break;
    }
    }
}

#pragma mark Informing Interested Objects

- (void)_informRelevantObjectsOfPotentialUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:)]) {
        [self.delegate dynamicsDrawerViewController:self mayUpdateToPaneState:paneState forDirection:direction];
    }
    for (id <MSDynamicsDrawerStyler> styler in [self _stylersForDirection:direction]) {
        if ([styler respondsToSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:)]) {
            [styler dynamicsDrawerViewController:self mayUpdateToPaneState:paneState forDirection:direction];
        }
    }
}

#pragma mark - MSDynamicsDrawerViewController <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self._panePanGestureRecognizer) {
        if (self.paneDragRequiresScreenEdgePan) {
            MSDynamicsDrawerPaneState currentPaneState;
            if ([self.paneLayout paneWithCenter:self.paneView.center isInValidState:&currentPaneState forDirection:self.currentDrawerDirection] && (currentPaneState == MSDynamicsDrawerPaneStateClosed)) {
                UIRectEdge panBeginEdges = [self._panePanGestureRecognizer didBeginAtEdgesOfView:self.paneView];
                // Mask to only edges that are possible (there's a drawer view controller set in that direction)
                MSDynamicsDrawerDirection possibleDirectionsForPanBeginEdges = (panBeginEdges & self.possibleDrawerDirection);
                BOOL gestureBeganAtPossibleEdge = (possibleDirectionsForPanBeginEdges != UIRectEdgeNone);
                // If the gesture didn't start at a possible edge, return no
                if (!gestureBeganAtPossibleEdge) {
                    return NO;
                }
            }
        }
        if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:shouldBeginPanePan:)]) {
            if (![self.delegate dynamicsDrawerViewController:self shouldBeginPanePan:self._panePanGestureRecognizer]) {
                return NO;
            }
        }
    }
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self._panePanGestureRecognizer) {
        __block BOOL shouldReceiveTouch = YES;
        // Enumerate the view's superviews, checking for a touch-forwarding class
        [touch.view superviewHierarchyAction:^(UIView *view) {
            // Only enumerate while still receiving the touch
            if (!shouldReceiveTouch) {
                return;
            }
            // If the touch was in a touch forwarding view, don't handle the gesture
            [self._touchForwardingClasses enumerateObjectsUsingBlock:^(Class touchForwardingClass, BOOL *stop) {
                if ([view isKindOfClass:touchForwardingClass]) {
                    shouldReceiveTouch = NO;
                    *stop = YES;
                }
            }];
        }];
        return shouldReceiveTouch;
    } else if (gestureRecognizer == self._paneTapGestureRecognizer) {
        MSDynamicsDrawerPaneState currentPaneState;
        if ([self.paneLayout paneWithCenter:self.paneView.center isInValidState:&currentPaneState forDirection:self.currentDrawerDirection]) {
            return (currentPaneState != MSDynamicsDrawerPaneStateClosed);
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self._panePanGestureRecognizer) && self.screenEdgePanCancelsConflictingGestures) {
        UIRectEdge edges = [self._panePanGestureRecognizer didBeginAtEdgesOfView:self.paneView];
        // Mask out edges that aren't possible
        BOOL validEdges = (edges & self.possibleDrawerDirection);
        // If there is a valid edge and pane drag is revealed for that edge's direction
        __block BOOL shouldBeRequiredToFail = NO;
        MSDynamicsDrawerDirectionActionForMaskedValues(validEdges, ^(MSDynamicsDrawerDirection maskedDirection) {
            shouldBeRequiredToFail = (shouldBeRequiredToFail ? YES : [self paneDragRevealEnabledForDirection:maskedDirection]);
        });
        return shouldBeRequiredToFail;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // If the other gesture recognizer's view is a `UITableViewCell` instance's internal `UIScrollView`, require failure
    if ([[otherGestureRecognizer.view nextResponder] isKindOfClass:[UITableViewCell class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - MSDynamicsDrawerViewController <UIDynamicAnimatorDelegate>

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    // If the dynaimc animator has paused while the `panePanGestureRecognizer` is active, ignore it as it's a side effect of removing behaviors, not a resting state
    if (self._panePanGestureRecognizer.state != UIGestureRecognizerStatePossible) {
        return;
    }
    
    // Since a resting pane state has been reached, we can remove all behaviors
    [self._dynamicAnimator removeAllBehaviors];
    
    // Internally update the pane state to the nearest pane state
    [self _setPaneState:[self.paneLayout nearestStateForPaneWithCenter:self.paneView.center forDirection:self.currentDrawerDirection]];
    
    // Update pane user interaction appropriately
    [self _setPaneViewControllerViewUserInteractionEnabled:(self.paneState == MSDynamicsDrawerPaneStateClosed)];
    
    // Since rotation is disabled while the dynamic animator is running, we invoke this method to attempt rotation if it has occured during the state transition
    [UIViewController attemptRotationToDeviceOrientation];
    
    if (self._dynamicAnimatorCompletion) {
        self._dynamicAnimatorCompletion();
        self._dynamicAnimatorCompletion = nil;
    }
}

@end
