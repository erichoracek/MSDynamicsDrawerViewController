//
//  MSDynamicsDrawerViewController.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 9/4/12.
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

#import <QuartzCore/QuartzCore.h>
#import "MSDynamicsDrawerViewController.h"

//#define DEBUG_LAYOUT

const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthHorizontal = 267.0;
const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthVertical = 300.0;
const CGFloat MSPaneViewVelocityThreshold = 5.0;
const CGFloat MSPaneViewVelocityMultiplier = 5.0;
const CGFloat MSPaneViewScreenEdgeThreshold = 24.0; // After testing Apple's `UIScreenEdgePanGestureRecognizer` this seems to be the closest value to create an equivalent effect.

NSString * const MSDynamicsDrawerBoundaryIdentifier = @"MSDynamicsDrawerBoundaryIdentifier";

typedef void (^ViewActionBlock)(UIView *view);
@interface UIView (ViewHierarchyAction)
- (void)superviewHierarchyAction:(ViewActionBlock)viewAction;
@end
@implementation UIView (ViewHierarchyAction)
- (void)superviewHierarchyAction:(ViewActionBlock)viewAction
{
    viewAction(self);
    [self.superview superviewHierarchyAction:viewAction];
}
@end

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsNonMasked(MSDynamicsDrawerDirection drawerDirection)
{
    switch (drawerDirection) {
        case MSDynamicsDrawerDirectionNone:
        case MSDynamicsDrawerDirectionTop:
        case MSDynamicsDrawerDirectionLeft:
        case MSDynamicsDrawerDirectionBottom:
        case MSDynamicsDrawerDirectionRight:
            return YES;
        default:
            return NO;
    }
}

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsCardinal(MSDynamicsDrawerDirection drawerDirection)
{
    switch (drawerDirection) {
        case MSDynamicsDrawerDirectionTop:
        case MSDynamicsDrawerDirectionLeft:
        case MSDynamicsDrawerDirectionBottom:
        case MSDynamicsDrawerDirectionRight:
            return YES;
        default:
            return NO;
    }
}

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsValid(MSDynamicsDrawerDirection drawerDirection)
{
    switch (drawerDirection) {
        case MSDynamicsDrawerDirectionNone:
        case MSDynamicsDrawerDirectionTop:
        case MSDynamicsDrawerDirectionLeft:
        case MSDynamicsDrawerDirectionBottom:
        case MSDynamicsDrawerDirectionRight:
        case MSDynamicsDrawerDirectionHorizontal:
        case MSDynamicsDrawerDirectionVertical:
            return YES;
        default:
            return NO;
    }
}

void MSDynamicsDrawerDirectionActionForMaskedValues(NSInteger direction, MSDynamicsDrawerActionBlock action)
{
    for (MSDynamicsDrawerDirection currentDirection = MSDynamicsDrawerDirectionTop; currentDirection <= MSDynamicsDrawerDirectionRight; currentDirection <<= 1) {
        if (currentDirection & direction) {
            action(currentDirection);
        }
    }
}

@interface MSDynamicsDrawerViewController () <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate>

// State
@property (nonatomic, assign) BOOL animatingRotation;
@property (nonatomic, assign) MSDynamicsDrawerDirection currentDrawerDirection;
@property (nonatomic, assign) MSDynamicsDrawerDirection possibleDrawerDirection;
@property (nonatomic, assign) MSDynamicsDrawerPaneState potentialPaneState;
// View Controller Container Views
@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, strong) UIView *paneView;
// Visible View Controllers
@property (nonatomic, strong) UIViewController *drawerViewController;
// Internal Properties
@property (nonatomic, strong) NSMutableDictionary *drawerViewControllers;
@property (nonatomic, strong) NSMutableDictionary *revealWidth;
@property (nonatomic, strong) NSMutableDictionary *paneDragRevealEnabled;
@property (nonatomic, strong) NSMutableDictionary *paneTapToCloseEnabled;
@property (nonatomic, strong) NSMutableDictionary *stylers;
// Gestures
@property (nonatomic, strong) NSMutableSet *touchForwardingClasses;
@property (nonatomic, strong) UIPanGestureRecognizer *panePanGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *paneTapGestureRecognizer;
// Dynamics
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIPushBehavior *panePushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *paneElasticityBehavior;
@property (nonatomic, strong) UIGravityBehavior *paneGravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *paneBoundaryCollisionBehavior;
@property (nonatomic, copy) void (^dynamicAnimatorCompletion)(void);

@end

@implementation MSDynamicsDrawerViewController

@synthesize currentDrawerDirection = _currentDrawerDirection;
@synthesize possibleDrawerDirection = _possibleDrawerDirection;
@synthesize paneState = _paneState;
@synthesize paneViewController = _paneViewController;
@synthesize drawerViewController = _drawerViewController;

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    [self.paneView removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame))];
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.drawerView.frame = self.view.bounds;
    self.paneView.frame = self.view.bounds;
    [self.view addSubview:self.drawerView];
    [self.view addSubview:self.paneView];
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicAnimator.delegate = self;
    
    self.paneBoundaryCollisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.paneView]];
    self.paneGravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.paneView]];
    self.panePushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.paneView] mode:UIPushBehaviorModeInstantaneous];
    self.paneElasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paneView]];
    
    __weak typeof(self) weakSelf = self;
    self.paneGravityBehavior.action = ^{
        [weakSelf didUpdateDynamicAnimatorAction];
    };
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.animatingRotation = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.animatingRotation = NO;
    [self updateStylers];
}

- (BOOL)shouldAutorotate
{
    // Do not allow rotation when not in resting state (dynamic animator is running or pane pan gesture recognizer is active)
    return (!self.dynamicAnimator.isRunning && (self.panePanGestureRecognizer.state == UIGestureRecognizerStatePossible));
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    if (self.paneViewController) {
        supportedInterfaceOrientations &= self.paneViewController.supportedInterfaceOrientations;
    }
    if (self.drawerViewController) {
        supportedInterfaceOrientations &= self.drawerViewController.supportedInterfaceOrientations;
    }
    return supportedInterfaceOrientations;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.paneViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.paneViewController;
}

#pragma mark - MSDynamicsDrawerViewController

- (void)initialize
{
    _paneState = MSDynamicsDrawerPaneStateClosed;
    _currentDrawerDirection = MSDynamicsDrawerDirectionNone;
    self.potentialPaneState = NSIntegerMax;
    
    self.paneViewSlideOffAnimationEnabled = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    self.shouldAlignStatusBarToPaneView = YES;
    self.screenEdgePanCancelsConflictingGestures = YES;
    
    self.drawerViewControllers = [NSMutableDictionary new];
    self.revealWidth = [NSMutableDictionary new];
    self.paneDragRevealEnabled = [NSMutableDictionary new];
    self.paneTapToCloseEnabled = [NSMutableDictionary new];
    self.stylers = [NSMutableDictionary new];
    
    self.touchForwardingClasses = [NSMutableSet setWithArray:@[[UISlider class], [UISwitch class]]];
    
    self.drawerView = [UIView new];
    self.drawerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.paneView = [UIView new];
    self.paneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.paneView addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:0 context:NULL];
    
    self.panePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panePanned:)];
    self.panePanGestureRecognizer.minimumNumberOfTouches = 1;
    self.panePanGestureRecognizer.maximumNumberOfTouches = 1;
    self.panePanGestureRecognizer.delegate = self;
    [self.paneView addGestureRecognizer:self.panePanGestureRecognizer];
    
    self.paneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paneTapped:)];
    self.paneTapGestureRecognizer.numberOfTouchesRequired = 1;
    self.paneTapGestureRecognizer.numberOfTapsRequired = 1;
    self.paneTapGestureRecognizer.delegate = self;
    [self.paneView addGestureRecognizer:self.paneTapGestureRecognizer];
    
    self.gravityMagnitude = 2.0;
    self.elasticity = 0.0;
    self.bounceElasticity = 0.5;
    self.bounceMagnitude = 60.0;
    self.paneStateOpenWideEdgeOffset = 20.0;
    
#if defined(DEBUG_LAYOUT)
    self.drawerView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    self.drawerView.layer.borderColor = [[UIColor redColor] CGColor];
    self.drawerView.layer.borderWidth = 2.0;
    self.paneView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    self.paneView.layer.borderColor = [[UIColor greenColor] CGColor];
    self.paneView.layer.borderWidth = 2.0;
#endif
}

#pragma mark Bouncing

- (void)bouncePaneOpen
{
    [self bouncePaneOpenAllowingUserInterruption:YES completion:nil];
}

- (void)bouncePaneOpenAllowingUserInterruption:(BOOL)allowingUserInterruption completion:(void (^)(void))completion
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.possibleDrawerDirection), @"Unable to bounce open with multiple possible reveal directions");
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

    [self addDynamicsBehaviorsToCreatePaneState:MSDynamicsDrawerPaneStateClosed pushMagnitude:self.bounceMagnitude pushAngle:[self gravityAngleForState:MSDynamicsDrawerPaneStateOpen direction:direction] pushElasticity:self.bounceElasticity];
    
    if (!allowUserInterruption) [self setViewUserInteractionEnabled:NO];
    __weak typeof(self) weakSelf = self;
    self.dynamicAnimatorCompletion = ^{
        if (!allowUserInterruption) [weakSelf setViewUserInteractionEnabled:YES];
        if (completion) completion();
    };
}

#pragma mark Generic View Controller Containment

- (void)replaceViewController:(UIViewController *)existingViewController withViewController:(UIViewController *)newViewController inContainerView:(UIView *)containerView completion:(void (^)(void))completion
{
    // Add initial view controller
	if (!existingViewController && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [newViewController beginAppearanceTransition:YES animated:NO];
		[self addChildViewController:newViewController];
        newViewController.view.frame = containerView.bounds;
		[containerView addSubview:newViewController.view];
		[newViewController didMoveToParentViewController:self];
        [newViewController endAppearanceTransition];
        if (completion) completion();
	}
    // Remove existing view controller
    else if (existingViewController && !newViewController) {
        [existingViewController willMoveToParentViewController:nil];
        [existingViewController beginAppearanceTransition:NO animated:NO];
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        [existingViewController endAppearanceTransition];
        if (completion) completion();
    }
    // Replace existing view controller with new view controller
    else if ((existingViewController != newViewController) && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [existingViewController willMoveToParentViewController:nil];
        [existingViewController beginAppearanceTransition:NO animated:NO];
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        [existingViewController endAppearanceTransition];
        [newViewController beginAppearanceTransition:YES animated:NO];
        newViewController.view.frame = containerView.bounds;
        [self addChildViewController:newViewController];
        [containerView addSubview:newViewController.view];
        [newViewController didMoveToParentViewController:self];
        [newViewController endAppearanceTransition];
        if (completion) completion();
    }
}

#pragma mark Drawer View Controller

- (void)setDrawerViewController:(UIViewController *)drawerViewController
{
    [self replaceViewController:self.drawerViewController withViewController:drawerViewController inContainerView:self.drawerView completion:^{
        _drawerViewController = drawerViewController;
    }];
}

- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts cardinal reveal directions");
    for (UIViewController * __unused currentDrawerViewController in self.drawerViewControllers) {
        NSAssert(currentDrawerViewController != drawerViewController, @"Unable to add a drawer view controller when it's previously been added");
    }
    if (direction & MSDynamicsDrawerDirectionHorizontal) {
        NSAssert(!(self.drawerViewControllers[@(MSDynamicsDrawerDirectionTop)] || self.drawerViewControllers[@(MSDynamicsDrawerDirectionBottom)]), @"Unable to simultaneously have top/bottom drawer view controllers while setting left/right drawer view controllers");
    } else if (direction & MSDynamicsDrawerDirectionVertical) {
        NSAssert(!(self.drawerViewControllers[@(MSDynamicsDrawerDirectionLeft)] || self.drawerViewControllers[@(MSDynamicsDrawerDirectionRight)]), @"Unable to simultaneously have left/right drawer view controllers while setting top/bottom drawer view controllers");
    }
    UIViewController *existingDrawerViewController = self.drawerViewControllers[@(direction)];
    // New drawer view controller
    if (drawerViewController && !existingDrawerViewController) {
        self.possibleDrawerDirection |= direction;
        self.drawerViewControllers[@(direction)] = drawerViewController;
    }
    // Removing existing drawer view controller
    else if (!drawerViewController && existingDrawerViewController) {
        self.possibleDrawerDirection ^= direction;
        [self.drawerViewControllers removeObjectForKey:@(direction)];
    }
    // Replace existing drawer view controller
    else if (drawerViewController && existingDrawerViewController) {
        self.drawerViewControllers[@(direction)] = drawerViewController;
    }
}

- (UIViewController *)drawerViewControllerForDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only cardinal reveal directions are accepted");
    return self.drawerViewControllers[@(direction)];
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
            _paneViewController = paneViewController;
            // Force redraw of the new pane view (drastically smoothes animation)
            [self.paneView setNeedsDisplay];
            [CATransaction flush];
            [self setNeedsStatusBarAppearanceUpdate];
            // After drawing has finished, set new pane view controller view and close
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = self;
                _paneViewController = paneViewController;
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

- (void)didUpdateDynamicAnimatorAction
{
    [self paneViewDidUpdateFrame];
}

- (void)addDynamicsBehaviorsToCreatePaneState:(MSDynamicsDrawerPaneState)paneState;
{
    [self addDynamicsBehaviorsToCreatePaneState:paneState pushMagnitude:0.0 pushAngle:0.0 pushElasticity:self.elasticity];
}

- (void)addDynamicsBehaviorsToCreatePaneState:(MSDynamicsDrawerPaneState)paneState pushMagnitude:(CGFloat)pushMagnitude pushAngle:(CGFloat)pushAngle pushElasticity:(CGFloat)elasticity
{
    if (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
        return;
    }
    
    [self setPaneViewControllerViewUserInteractionEnabled:(paneState == MSDynamicsDrawerPaneStateClosed)];
    
    [self.paneBoundaryCollisionBehavior removeAllBoundaries];
    [self.paneBoundaryCollisionBehavior addBoundaryWithIdentifier:MSDynamicsDrawerBoundaryIdentifier forPath:[self boundaryPathForState:paneState direction:self.currentDrawerDirection]];
    [self.dynamicAnimator addBehavior:self.paneBoundaryCollisionBehavior];
    
    self.paneGravityBehavior.magnitude = [self gravityMagnitude];
    self.paneGravityBehavior.angle = [self gravityAngleForState:paneState direction:self.currentDrawerDirection];
    [self.dynamicAnimator addBehavior:self.paneGravityBehavior];
    
    if (elasticity != 0.0) {
        self.paneElasticityBehavior.elasticity = elasticity;
        [self.dynamicAnimator addBehavior:self.paneElasticityBehavior];
    }
    
    if (pushMagnitude != 0.0) {
        self.panePushBehavior.angle = pushAngle;
        self.panePushBehavior.magnitude = pushMagnitude;
        self.panePushBehavior.active = YES;
        [self.dynamicAnimator addBehavior:self.panePushBehavior];
    }
    
    self.potentialPaneState = paneState;
    
    if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:)]) {
        [self.delegate dynamicsDrawerViewController:self mayUpdateToPaneState:paneState forDirection:self.currentDrawerDirection];
    }
}

- (UIBezierPath *)boundaryPathForState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Boundary is undefined for a non-cardinal reveal direction");
    CGRect boundary = CGRectZero;
    boundary.origin = (CGPoint){-1.0, -1.0};
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        boundary.size.height = (CGRectGetHeight(self.paneView.frame) + 1.0);
        switch (state) {
            case MSDynamicsDrawerPaneStateClosed:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) * 2.0) + self.paneStateOpenWideEdgeOffset + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpen:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) + self.openStateRevealWidth) + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpenWide:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) * 2.0) + self.paneStateOpenWideEdgeOffset + 2.0);
                break;
        }
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        boundary.size.width = (CGRectGetWidth(self.paneView.frame) + 1.0);
        switch (state) {
            case MSDynamicsDrawerPaneStateClosed:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) * 2.0) + self.paneStateOpenWideEdgeOffset + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpen:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) + self.openStateRevealWidth) + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpenWide:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) * 2.0) + self.paneStateOpenWideEdgeOffset + 2.0);
                break;
        }
    }
    switch (direction) {
        case MSDynamicsDrawerDirectionRight:
            boundary.origin.x = ((CGRectGetWidth(self.paneView.frame) + 1.0) - boundary.size.width);
            break;
        case MSDynamicsDrawerDirectionBottom:
            boundary.origin.y = ((CGRectGetHeight(self.paneView.frame) + 1.0) - boundary.size.height);
            break;
        case MSDynamicsDrawerDirectionNone:
            boundary = CGRectZero;
            break;
        default:
            break;
    }
    return [UIBezierPath bezierPathWithRect:boundary];
}

- (CGFloat)gravityAngleForState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Indeterminate gravity angle for non-cardinal reveal direction");
    switch (direction) {
        case MSDynamicsDrawerDirectionTop:
            return (CGFloat) ((state != MSDynamicsDrawerPaneStateClosed) ? M_PI_2 : (3.0 * M_PI_2));
        case MSDynamicsDrawerDirectionLeft:
            return (CGFloat) ((state != MSDynamicsDrawerPaneStateClosed) ? 0.0 : M_PI);
        case MSDynamicsDrawerDirectionBottom:
            return (CGFloat) ((state != MSDynamicsDrawerPaneStateClosed) ? (3.0 * M_PI_2) : M_PI_2);
        case MSDynamicsDrawerDirectionRight:
            return (CGFloat) ((state != MSDynamicsDrawerPaneStateClosed) ? M_PI : 0.0);
        default:
            return 0.0;
    }
}

#pragma mark Closed Fraction

- (CGFloat)paneViewClosedFraction
{
    CGFloat fraction = 0;
    switch (self.currentDrawerDirection) {
        case MSDynamicsDrawerDirectionTop:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.y) / self.openStateRevealWidth);
            break;
        case MSDynamicsDrawerDirectionLeft:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.x) / self.openStateRevealWidth);
            break;
        case MSDynamicsDrawerDirectionBottom:
            fraction = (1.0 - (fabsf(self.paneView.frame.origin.y) / self.openStateRevealWidth));
            break;
        case MSDynamicsDrawerDirectionRight:
            fraction = (1.0 - (fabsf(self.paneView.frame.origin.x) / self.openStateRevealWidth));
            break;
        case MSDynamicsDrawerDirectionNone:
            fraction = 1.0; // If we have no direction, we want 1.0 since the pane is closed when it has no direction
            break;
        default:
            break;
    }
    // Clip to 0.0 < fraction < 1.0
    fraction = (fraction < 0.0) ? 0.0 : fraction;
    fraction = (fraction > 1.0) ? 1.0 : fraction;
    return fraction;
}

#pragma mark Stylers

- (void)addStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        // Lazy creation of stylers sets
        if (!self.stylers[@(maskedValue)]) {
            self.stylers[@(maskedValue)] = [NSMutableSet new];
        }
        NSMutableSet *stylersSet = self.stylers[@(maskedValue)];
        [stylersSet addObject:styler];
        BOOL existsInCurrentStylers = NO;
        for (NSSet *currentStylersSet in [self.stylers allValues]) {
            if ([currentStylersSet containsObject:styler]) {
                existsInCurrentStylers = YES;
            }
        }
        if (existsInCurrentStylers) {
            if ([styler respondsToSelector:@selector(stylerWasAddedToDynamicsDrawerViewController:forDirection:)]) {
                [styler stylerWasAddedToDynamicsDrawerViewController:self forDirection:direction];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([styler respondsToSelector:@selector(stylerWasAddedToDynamicsDrawerViewController:)]) {
                [styler stylerWasAddedToDynamicsDrawerViewController:self];
            }
#pragma clang diagnostic pop
        }
    });
}

- (void)removeStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        NSMutableSet *stylersSet = self.stylers[@(maskedValue)];
        [stylersSet removeObject:styler];
        NSInteger containedCount = 0;
        for (NSSet *currentStylersSet in [self.stylers allValues]) {
            if ([currentStylersSet containsObject:styler]) {
                containedCount++;
            }
        }
        if (containedCount == 0) {
            if ([styler respondsToSelector:@selector(stylerWasRemovedFromDynamicsDrawerViewController:forDirection:)]) {
                [styler stylerWasRemovedFromDynamicsDrawerViewController:self forDirection:direction];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([styler respondsToSelector:@selector(stylerWasRemovedFromDynamicsDrawerViewController:)]) {
                [styler stylerWasRemovedFromDynamicsDrawerViewController:self];
            }
#pragma clang diagnostic pop
        }
    });
}

- (void)addStylersFromArray:(NSArray *)stylers forDirection:(MSDynamicsDrawerDirection)direction
{
    for (id <MSDynamicsDrawerStyler> styler in stylers) {
        [self addStyler:styler forDirection:direction];
    }
}

- (void)updateStylers
{
    // Prevent weird animation issues on rotation
    if (self.animatingRotation) {
        return;
    }
    NSMutableSet *activeStylers = [NSMutableSet new];
    if (MSDynamicsDrawerDirectionIsCardinal(self.currentDrawerDirection)) {
        [activeStylers unionSet:self.stylers[@(self.currentDrawerDirection)]];
    } else {
        for (NSSet *stylers in [self.stylers allValues]) {
            [activeStylers unionSet:stylers];
        }
    }
    for (id <MSDynamicsDrawerStyler> styler in activeStylers) {
        [styler dynamicsDrawerViewController:self didUpdatePaneClosedFraction:[self paneViewClosedFraction] forDirection:self.currentDrawerDirection];
    }
}

- (NSArray *)stylersForDirection:(MSDynamicsDrawerDirection)direction
{
    NSMutableSet *stlyerCollection = [NSMutableSet new];
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        [stlyerCollection unionSet:self.stylers[@(maskedValue)]];
    });
    return [stlyerCollection allObjects];
}

#pragma mark Pane State

- (void)paneViewDidUpdateFrame
{
    if (self.shouldAlignStatusBarToPaneView) {
        NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
        id object = [UIApplication sharedApplication];
        UIView *statusBar;
        if ([object respondsToSelector:NSSelectorFromString(key)]) {
            statusBar = [object valueForKey:key];
        }
        statusBar.transform = CGAffineTransformMakeTranslation(self.paneView.frame.origin.x, self.paneView.frame.origin.y);
    }
    
    CGPoint openWidePoint = [self paneViewOriginForPaneState:MSDynamicsDrawerPaneStateOpenWide];
    CGRect paneFrame = self.paneView.frame;
    CGFloat *openWideLocation = NULL;
    CGFloat *paneLocation = NULL;
    if (self.currentDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        openWideLocation = &openWidePoint.x;
        paneLocation = &paneFrame.origin.x;
    } else if (self.currentDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        openWideLocation = &openWidePoint.y;
        paneLocation = &paneFrame.origin.y;
    }
    BOOL reachedOpenWideState = NO;
    if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionTop)) {
        if (paneLocation && (*paneLocation >= *openWideLocation)) {
            reachedOpenWideState = YES;
        }
    } else if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionRight | MSDynamicsDrawerDirectionBottom)) {
        if (paneLocation && (*paneLocation <= *openWideLocation)) {
            reachedOpenWideState = YES;
        }
    }
    if (reachedOpenWideState && (self.potentialPaneState == MSDynamicsDrawerPaneStateOpenWide)) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    [self updateStylers];
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
    NSAssert(((self.possibleDrawerDirection & direction) == direction), @"Unable to bounce open with impossible or multiple directions");
    if ((paneState != MSDynamicsDrawerPaneStateClosed)) {
        self.currentDrawerDirection = direction;
    }
    if (animated) {
        [self addDynamicsBehaviorsToCreatePaneState:paneState];
        if (!allowUserInterruption) [self setViewUserInteractionEnabled:NO];
        __weak typeof(self) weakSelf = self;
        self.dynamicAnimatorCompletion = ^{
            if (!allowUserInterruption) [weakSelf setViewUserInteractionEnabled:YES];
            if (completion) completion();
        };
    } else {
        [self _setPaneState:paneState];
        if (completion) completion();
    }
}

- (void)_setPaneState:(MSDynamicsDrawerPaneState)paneState
{
    MSDynamicsDrawerDirection previousDirection = self.currentDrawerDirection;
    
    // When we've actually upated to a pane state, invalidate the `potentialPaneState`
    self.potentialPaneState = NSIntegerMax;
    
    if (_paneState != paneState) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(paneState))];
        _paneState = paneState;
        if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:)]) {
            if (self.paneState & (MSDynamicsDrawerPaneStateOpen | MSDynamicsDrawerPaneStateOpenWide)) {
                [self.delegate dynamicsDrawerViewController:self didUpdateToPaneState:paneState forDirection:self.currentDrawerDirection];
            } else {
                [self.delegate dynamicsDrawerViewController:self didUpdateToPaneState:paneState forDirection:previousDirection];
            }
        }
        [self didChangeValueForKey:NSStringFromSelector(@selector(paneState))];
    }
    
    // Update pane frame regardless of if it's changed
    self.paneView.frame = (CGRect){[self paneViewOriginForPaneState:paneState], self.paneView.frame.size};
    
    // Update `currentDirection` to `MSDynamicsDrawerDirectionNone` if the `paneState` is `MSDynamicsDrawerPaneStateClosed`
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        self.currentDrawerDirection = MSDynamicsDrawerDirectionNone;
    }
}

- (CGPoint)paneViewOriginForPaneState:(MSDynamicsDrawerPaneState)paneState
{
    CGPoint paneViewOrigin = CGPointZero;
    switch (paneState) {
        case MSDynamicsDrawerPaneStateOpen:
            switch (self.currentDrawerDirection) {
                case MSDynamicsDrawerDirectionTop:
                    paneViewOrigin.y = self.openStateRevealWidth;
                    break;
                case MSDynamicsDrawerDirectionLeft:
                    paneViewOrigin.x = self.openStateRevealWidth;
                    break;
                case MSDynamicsDrawerDirectionBottom:
                    paneViewOrigin.y = -self.openStateRevealWidth;
                    break;
                case MSDynamicsDrawerDirectionRight:
                    paneViewOrigin.x = -self.openStateRevealWidth;
                    break;
                default:
                    break;
            }
            break;
        case MSDynamicsDrawerPaneStateOpenWide:
            switch (self.currentDrawerDirection) {
                case MSDynamicsDrawerDirectionLeft:
                    paneViewOrigin.x = (CGRectGetWidth(self.paneView.frame) + self.paneStateOpenWideEdgeOffset);
                    break;
                case MSDynamicsDrawerDirectionTop:
                    paneViewOrigin.y = (CGRectGetHeight(self.paneView.frame) + self.paneStateOpenWideEdgeOffset);
                    break;
                case MSDynamicsDrawerDirectionBottom:
                    paneViewOrigin.y = (CGRectGetHeight(self.paneView.frame) + self.paneStateOpenWideEdgeOffset);
                    break;
                case MSDynamicsDrawerDirectionRight:
                    paneViewOrigin.x = -(CGRectGetWidth(self.paneView.frame) + self.paneStateOpenWideEdgeOffset);
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return paneViewOrigin;
}

- (BOOL)paneViewIsPositionedInValidState:(inout MSDynamicsDrawerPaneState *)paneState
{
    BOOL validState = NO;
    for (MSDynamicsDrawerPaneState currentPaneState = MSDynamicsDrawerPaneStateClosed; currentPaneState <= MSDynamicsDrawerPaneStateOpenWide; currentPaneState++) {
        CGPoint paneStatePaneViewOrigin = [self paneViewOriginForPaneState:currentPaneState];
        CGPoint currentPaneViewOrigin = (CGPoint){roundf(self.paneView.frame.origin.x), roundf(self.paneView.frame.origin.y)};
        CGFloat epsilon = 2.0;
        if ((fabs(paneStatePaneViewOrigin.x - currentPaneViewOrigin.x) < epsilon) && (fabs(paneStatePaneViewOrigin.y - currentPaneViewOrigin.y) < epsilon)) {
            validState = YES;
            *paneState = currentPaneState;
            break;
        }
    }
    return validState;
}

- (MSDynamicsDrawerPaneState)nearestPaneState
{
    CGFloat minDistance = CGFLOAT_MAX;
    MSDynamicsDrawerPaneState minPaneState = NSIntegerMax;
    for (MSDynamicsDrawerPaneState currentPaneState = MSDynamicsDrawerPaneStateClosed; currentPaneState <= MSDynamicsDrawerPaneStateOpenWide; currentPaneState++) {
        CGPoint paneStatePaneViewOrigin = [self paneViewOriginForPaneState:currentPaneState];
        CGPoint currentPaneViewOrigin = (CGPoint){roundf(self.paneView.frame.origin.x), roundf(self.paneView.frame.origin.y)};
        CGFloat distance = sqrt(pow((paneStatePaneViewOrigin.x - currentPaneViewOrigin.x), 2) + pow((paneStatePaneViewOrigin.y - currentPaneViewOrigin.y), 2));
        if (distance < minDistance) {
            minDistance = distance;
            minPaneState = currentPaneState;
        }
    }
    return minPaneState;
}

#pragma mark Current Reveal Direction

- (void)setCurrentDrawerDirection:(MSDynamicsDrawerDirection)currentDrawerDirection
{
    NSAssert(MSDynamicsDrawerDirectionIsNonMasked(currentDrawerDirection), @"Only accepts non-masked directions as current reveal direction");
    NSAssert(!((currentDrawerDirection == MSDynamicsDrawerDirectionNone) && (self.paneState != MSDynamicsDrawerPaneStateClosed)), @"Can't set direction to none while we have a non-closed pane state");
    
    if (_currentDrawerDirection == currentDrawerDirection) return;
    
    // Inform stylers about the transition between directions when directly transitioning
    if (_currentDrawerDirection != MSDynamicsDrawerDirectionNone) {
        NSMutableSet *allStylers = [NSMutableSet new];
        for (NSSet *stylers in [self.stylers allValues]) {
            [allStylers unionSet:stylers];
        }
        for (id <MSDynamicsDrawerStyler> styler in allStylers) {
            [styler dynamicsDrawerViewController:self didUpdatePaneClosedFraction:1.0 forDirection:MSDynamicsDrawerDirectionNone];
        }
    }
    
    _currentDrawerDirection = currentDrawerDirection;
    
    self.drawerViewController = self.drawerViewControllers[@(currentDrawerDirection)];
    
    // Disable pane view interaction when not closed
    [self setPaneViewControllerViewUserInteractionEnabled:(currentDrawerDirection == MSDynamicsDrawerDirectionNone)];
    
    [self updateStylers];
}

#pragma mark Possible Reveal Direction

- (void)setPossibleDrawerDirection:(MSDynamicsDrawerDirection)possibleDrawerDirection
{
    NSAssert(MSDynamicsDrawerDirectionIsValid(possibleDrawerDirection), @"Only accepts valid reveal directions as possible reveal direction");
    _possibleDrawerDirection = possibleDrawerDirection;
}

#pragma mark Reveal Width

- (CGFloat)revealWidthForDirection:(MSDynamicsDrawerDirection)direction;
{
    NSAssert(MSDynamicsDrawerDirectionIsValid(direction), @"Only accepts cardinal directions when querying for reveal width");
    NSNumber *revealWidth = self.revealWidth[@(direction)];
    // Default values
    if (!revealWidth) {
        if (direction & MSDynamicsDrawerDirectionHorizontal) {
            revealWidth = @(MSDynamicsDrawerDefaultOpenStateRevealWidthHorizontal);
        } else if (direction & MSDynamicsDrawerDirectionVertical) {
            revealWidth = @(MSDynamicsDrawerDefaultOpenStateRevealWidthVertical);
        } else {
            revealWidth = @0;
        }
    }
    return [revealWidth floatValue];
}

- (void)setRevealWidth:(CGFloat)revealWidth forDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert((self.paneState == MSDynamicsDrawerPaneStateClosed), @"Only able to update the reveal width while the pane view is closed");
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        self.revealWidth[@(maskedValue)] = @(revealWidth);
    });
}

- (CGFloat)openStateRevealWidth
{
    return [self revealWidthForDirection:self.currentDrawerDirection];
}

- (CGFloat)currentRevealWidth
{
    switch (self.currentDrawerDirection) {
        case MSDynamicsDrawerDirectionLeft:
        case MSDynamicsDrawerDirectionRight:
            return fabs(self.paneView.frame.origin.x);
        case MSDynamicsDrawerDirectionTop:
        case MSDynamicsDrawerDirectionBottom:
            return fabs(self.paneView.frame.origin.y);
        default:
            return 0.0;
    }
}

#pragma mark Gestures

- (void)setPaneDragRevealEnabled:(BOOL)paneDraggingEnabled forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        self.paneDragRevealEnabled[@(maskedValue)] = @(paneDraggingEnabled);
    });
}

- (BOOL)paneDragRevealEnabledForDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts singular directions when querying for drag reveal enabled");
    NSNumber *paneDragRevealEnabled = self.paneDragRevealEnabled[@(direction)];
    if (!paneDragRevealEnabled) paneDragRevealEnabled = @(YES);
    return [paneDragRevealEnabled boolValue];
}

- (void)setPaneTapToCloseEnabled:(BOOL)paneTapToCloseEnabled forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue){
        self.paneTapToCloseEnabled[@(maskedValue)] = @(paneTapToCloseEnabled);
    });
}

- (BOOL)paneTapToCloseEnabledForDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts singular directions when querying for drag reveal enabled");
    NSNumber *paneTapToCloseEnabled = self.paneTapToCloseEnabled[@(direction)];
    if (!paneTapToCloseEnabled) paneTapToCloseEnabled = @(YES);
    return [paneTapToCloseEnabled boolValue];
}

- (void)registerTouchForwardingClass:(Class)touchForwardingClass
{
    NSAssert([touchForwardingClass isSubclassOfClass:[UIView class]], @"Registered touch forwarding classes must be a subclass of UIView");
    [self.touchForwardingClasses addObject:touchForwardingClass];
}

- (CGFloat)deltaForPanWithStartLocation:(CGPoint)startLocation currentLocation:(CGPoint)currentLocation
{
    CGFloat panDelta = 0.0;
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        panDelta = (currentLocation.x - startLocation.x);
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        panDelta = (currentLocation.y - startLocation.y);
    }
    return panDelta;
}

- (MSDynamicsDrawerDirection)directionForPanWithStartLocation:(CGPoint)startLocation currentLocation:(CGPoint)currentLocation
{
    CGFloat delta = [self deltaForPanWithStartLocation:startLocation currentLocation:currentLocation];
    MSDynamicsDrawerDirection direction = MSDynamicsDrawerDirectionNone;
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        if (delta > 0.0) {
            direction = MSDynamicsDrawerDirectionLeft;
        } else if (delta < 0.0) {
            direction = MSDynamicsDrawerDirectionRight;
        }
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        if (delta > 0.0) {
            direction = MSDynamicsDrawerDirectionTop;
        } else if (delta < 0.0) {
            direction = MSDynamicsDrawerDirectionBottom;
        }
    }
    return direction;
}

- (CGRect)paneViewFrameForPanWithStartLocation:(CGPoint)startLocation currentLocation:(CGPoint)currentLocation bounded:(inout BOOL *)bounded
{
    CGFloat panDelta = [self deltaForPanWithStartLocation:startLocation currentLocation:currentLocation];
    // Track the pane frame to the pan gesture
    CGRect paneFrame = self.paneView.frame;
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        paneFrame.origin.x += panDelta;
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        paneFrame.origin.y += panDelta;
    }
    // Pane view edge bounding
    CGFloat paneBoundOpenLocation = 0.0;
    CGFloat paneBoundClosedLocation = 0.0;
    CGFloat *paneLocation = NULL;
    switch (self.currentDrawerDirection) {
        case MSDynamicsDrawerDirectionLeft:
            paneLocation = &paneFrame.origin.x;
            paneBoundOpenLocation = [self openStateRevealWidth];
            break;
        case MSDynamicsDrawerDirectionRight:
            paneLocation = &paneFrame.origin.x;
            paneBoundClosedLocation = -[self openStateRevealWidth];
            break;
        case MSDynamicsDrawerDirectionTop:
            paneLocation = &paneFrame.origin.y;
            paneBoundOpenLocation = [self openStateRevealWidth];
            break;
        case MSDynamicsDrawerDirectionBottom:
            paneLocation = &paneFrame.origin.y;
            paneBoundClosedLocation = -[self openStateRevealWidth];
            break;
        default:
            break;
    }
    // Bounded open
    if (paneLocation && (*paneLocation <= paneBoundClosedLocation)) {
        *paneLocation = paneBoundClosedLocation;
        *bounded = YES;
    }
    // Bounded closed
    else if (paneLocation && (*paneLocation >= paneBoundOpenLocation)) {
        *paneLocation = paneBoundOpenLocation;
        *bounded = YES;
    }
    else {
        *bounded = NO;
    }
    return paneFrame;
}

- (CGFloat)velocityForPanWithStartLocation:(CGPoint)startLocation currentLocation:(CGPoint)currentLocation
{
    CGFloat velocity = 0.0;
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        velocity = -(startLocation.x - currentLocation.x);
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        velocity = -(startLocation.y - currentLocation.y);
    }
    return velocity;
}

- (MSDynamicsDrawerPaneState)paneStateForPanVelocity:(CGFloat)panVelocity
{
    MSDynamicsDrawerPaneState state = MSDynamicsDrawerPaneStateClosed;
    if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft)) {
        state = ((panVelocity > 0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    } else if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionBottom | MSDynamicsDrawerDirectionRight)) {
        state = ((panVelocity < 0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
    }
    return state;
}

- (UIRectEdge)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer didStartAtEdgesOfView:(UIView *)view
{
    CGPoint translation = [panGestureRecognizer translationInView:view];
    CGPoint currentLocation = [panGestureRecognizer locationInView:view];
    CGPoint startLocation = CGPointMake((currentLocation.x - translation.x), (currentLocation.y - translation.y));
    UIEdgeInsets distanceToEdges = UIEdgeInsetsMake(startLocation.y, startLocation.x, (view.bounds.size.height - startLocation.y), (view.bounds.size.width - startLocation.x));
    UIRectEdge rectEdge = UIRectEdgeNone;
    if (distanceToEdges.top < MSPaneViewScreenEdgeThreshold) {
        rectEdge |= UIRectEdgeTop;
    }
    if (distanceToEdges.left < MSPaneViewScreenEdgeThreshold) {
        rectEdge |= UIRectEdgeLeft;
    }
    if (distanceToEdges.right < MSPaneViewScreenEdgeThreshold) {
        rectEdge |= UIRectEdgeRight;
    }
    if (distanceToEdges.bottom < MSPaneViewScreenEdgeThreshold) {
        rectEdge |= UIRectEdgeBottom;
    }
    return rectEdge;
}

#pragma mark User Interaction

- (void)setViewUserInteractionEnabled:(BOOL)enabled
{
    static NSInteger disableCount;
    if (!enabled) {
        disableCount++;
    } else {
        disableCount = MAX((disableCount - 1), 0);
    }
    self.view.userInteractionEnabled = (disableCount == 0);
}

- (void)setPaneViewControllerViewUserInteractionEnabled:(BOOL)enabled
{
    self.paneViewController.view.userInteractionEnabled = enabled;
}

#pragma mark UIGestureRecognizer Callbacks

- (void)paneTapped:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([self paneTapToCloseEnabledForDirection:self.currentDrawerDirection]) {
        [self addDynamicsBehaviorsToCreatePaneState:MSDynamicsDrawerPaneStateClosed];
    }
}

- (void)panePanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGPoint panStartLocation;
    static CGFloat paneVelocity;
    static MSDynamicsDrawerDirection panDirection;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            // Initialize static variables
            panStartLocation = [gestureRecognizer locationInView:self.paneView];
            paneVelocity = 0.0;
            panDirection = self.currentDrawerDirection;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPanLocation = [gestureRecognizer locationInView:self.paneView];
            MSDynamicsDrawerDirection currentPanDirection = [self directionForPanWithStartLocation:panStartLocation currentLocation:currentPanLocation];
            // If there's no current direction, try to determine it
            if (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
                MSDynamicsDrawerDirection currentDrawerDirection = MSDynamicsDrawerDirectionNone;
                // If a direction has not yet been previousy determined, use the pan direction
                if (panDirection == MSDynamicsDrawerDirectionNone) {
                    currentDrawerDirection = currentPanDirection;
                } else {
                    // Only allow a new direction to be in the same direction as before to prevent swiping between drawers in one gesture
                    if (currentPanDirection == panDirection) {
                        currentDrawerDirection = panDirection;
                    }
                }
                // If the new direction is still none, don't continue
                if (currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
                    return;
                }
                // Ensure that the new current direction is:
                if ((self.possibleDrawerDirection & currentDrawerDirection) &&         // Possible
                    ([self paneDragRevealEnabledForDirection:currentDrawerDirection])) // Has drag to reveal enabled
                {
                    self.currentDrawerDirection = currentDrawerDirection;
                    // Establish the initial drawer direction if there was none
                    if (panDirection == MSDynamicsDrawerDirectionNone) {
                        panDirection = self.currentDrawerDirection;
                    }
                }
                // If these criteria aren't met, cancel the gesture
                else {
                    gestureRecognizer.enabled = NO;
                    gestureRecognizer.enabled = YES;
                    return;
                }
            }
            // If the current reveal direction's pane drag reveal is disabled, cancel the gesture
            else if (![self paneDragRevealEnabledForDirection:self.currentDrawerDirection]) {
                gestureRecognizer.enabled = NO;
                gestureRecognizer.enabled = YES;
                return;
            }
            // At this point, panning is able to move the pane independently from the dynamic animator, so remove all behaviors to prevent conflicting frames
            [self.dynamicAnimator removeAllBehaviors];
            // Update the pane frame based on the pan gesture
            BOOL paneViewFrameBounded;
            self.paneView.frame = [self paneViewFrameForPanWithStartLocation:panStartLocation currentLocation:currentPanLocation bounded:&paneViewFrameBounded];
            // Update the pane velocity based on the pan gesture
            CGFloat currentPaneVelocity = [self velocityForPanWithStartLocation:panStartLocation currentLocation:currentPanLocation];
            // If the pane view is bounded or the determined velocity is 0, don't update it
            if (!paneViewFrameBounded && (currentPaneVelocity != 0.0)) {
                paneVelocity = currentPaneVelocity;
            }
            // If the drawer is being swiped into the closed state, set the direciton to none and the state to closed since the user is manually doing so
            if ((self.currentDrawerDirection != MSDynamicsDrawerDirectionNone) &&
                (currentPanDirection != MSDynamicsDrawerDirectionNone) &&
                CGPointEqualToPoint(self.paneView.frame.origin, [self paneViewOriginForPaneState:MSDynamicsDrawerPaneStateClosed])) {
                [self _setPaneState:MSDynamicsDrawerPaneStateClosed];
                self.currentDrawerDirection = MSDynamicsDrawerDirectionNone;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.currentDrawerDirection != MSDynamicsDrawerDirectionNone) {
                // If the user released the pane over the velocity threshold
                if (fabsf(paneVelocity) > MSPaneViewVelocityThreshold) {
                    MSDynamicsDrawerPaneState state = [self paneStateForPanVelocity:paneVelocity];
                    [self addDynamicsBehaviorsToCreatePaneState:state pushMagnitude:(fabsf(paneVelocity) * MSPaneViewVelocityMultiplier) pushAngle:[self gravityAngleForState:state direction:self.currentDrawerDirection] pushElasticity:self.elasticity];
                }
                // If not released with a velocity over the threhold, update to nearest `paneState`
                else {
                    [self addDynamicsBehaviorsToCreatePaneState:[self nearestPaneState]];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))] && (object == self.paneView)) {
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            [self paneViewDidUpdateFrame];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panePanGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(dynamicsDrawerViewController:shouldBeginPanePan:)]) {
            if (![self.delegate dynamicsDrawerViewController:self shouldBeginPanePan:self.panePanGestureRecognizer]) {
                return NO;
            }
        }
        if (self.paneDragRequiresScreenEdgePan) {
            MSDynamicsDrawerPaneState paneState;
            if ([self paneViewIsPositionedInValidState:&paneState] && (paneState == MSDynamicsDrawerPaneStateClosed)) {
                UIRectEdge edges = [self panGestureRecognizer:self.panePanGestureRecognizer didStartAtEdgesOfView:self.paneView];
                // Mask out edges that aren't possible
                BOOL validEdges = (edges & self.possibleDrawerDirection);
                // If there is a valid edge and pane drag is revealed for that edge's direction
                if (validEdges && [self paneDragRevealEnabledForDirection:validEdges]) {
                    return YES;
                }
                return NO;
            }
        }
    }
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.panePanGestureRecognizer) {
        __block BOOL shouldReceiveTouch = YES;
        // Enumerate the view's superviews, checking for a touch-forwarding class
        [touch.view superviewHierarchyAction:^(UIView *view) {
            // Only enumerate while still receiving the touch
            if (!shouldReceiveTouch) {
                return;
            }
            // If the touch was in a touch forwarding view, don't handle the gesture
            [self.touchForwardingClasses enumerateObjectsUsingBlock:^(Class touchForwardingClass, BOOL *stop) {
                if ([view isKindOfClass:touchForwardingClass]) {
                    shouldReceiveTouch = NO;
                    *stop = YES;
                }
            }];
        }];
        return shouldReceiveTouch;
    } else if (gestureRecognizer == self.paneTapGestureRecognizer) {
        MSDynamicsDrawerPaneState paneState;
        if ([self paneViewIsPositionedInValidState:&paneState]) {
            return (paneState != MSDynamicsDrawerPaneStateClosed);
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.panePanGestureRecognizer) && self.screenEdgePanCancelsConflictingGestures) {
        UIRectEdge edges = [self panGestureRecognizer:self.panePanGestureRecognizer didStartAtEdgesOfView:self.paneView];
        // Mask out edges that aren't possible
        BOOL validEdges = (edges & self.possibleDrawerDirection);
        // If there is a valid edge and pane drag is revealed for that edge's direction
        if (validEdges && [self paneDragRevealEnabledForDirection:validEdges]) {
            return YES;
        }
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

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    // If the dynaimc animator has paused while the `panePanGestureRecognizer` is active, ignore it as it's a side effect of removing behaviors, not a resting state
    if (self.panePanGestureRecognizer.state != UIGestureRecognizerStatePossible) return;
    
    // Since a resting pane state has been reached, we can remove all behaviors
    [self.dynamicAnimator removeAllBehaviors];
    
    // Update the pane state to the nearest pane state
    [self _setPaneState:[self nearestPaneState]];
    
    // Update pane user interaction appropriately
    [self setPaneViewControllerViewUserInteractionEnabled:(self.paneState == MSDynamicsDrawerPaneStateClosed)];
    
    // Since rotation is disabled while the dynamic animator is running, we invoke this method to cause rotation to happen (if device rotation has occured during state transition)
    [UIViewController attemptRotationToDeviceOrientation];
    
    if (self.dynamicAnimatorCompletion) {
        self.dynamicAnimatorCompletion();
        self.dynamicAnimatorCompletion = nil;
    }
}

@end
