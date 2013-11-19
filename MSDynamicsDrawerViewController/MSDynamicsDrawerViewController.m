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

//#define DEBUG_DYNAMICS
//#define DEBUG_LAYOUT

const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthHorizontal = 267.0;
const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthVertical = 300.0;
const CGFloat MSDynamicsDrawerOpenAnimationOvershot = 30.0;
const CGFloat MSPaneViewVelocityThreshold = 5.0;
const CGFloat MSPaneViewVelocityMultiplier = 5.0;

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

static BOOL MSDynamicsDrawerDirectionIsNonMasked(MSDynamicsDrawerDirection drawerDirection)
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

static BOOL MSDynamicsDrawerDirectionIsCardinal(MSDynamicsDrawerDirection drawerDirection)
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

static BOOL MSDynamicsDrawerDirectionIsValid(MSDynamicsDrawerDirection drawerDirection)
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

void MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirection direction, MSDynamicsDrawerActionBlock action)
{
    for (MSDynamicsDrawerDirection currentDirection = MSDynamicsDrawerDirectionTop; currentDirection <= MSDynamicsDrawerDirectionRight; currentDirection <<= 1) {
        if (currentDirection & direction) {
            action(currentDirection);
        }
    }
}

@interface MSDynamicsDrawerViewController () <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate>
{
    MSDynamicsDrawerDirection _currentDrawerDirection;
    MSDynamicsDrawerDirection _possibleDrawerDirection;
    UIViewController *_drawerViewController;
    UIViewController *_paneViewController;
    MSDynamicsDrawerPaneState _paneState;
}

@property (nonatomic, assign) BOOL animatingRotation;
@property (nonatomic, assign) MSDynamicsDrawerDirection currentDrawerDirection;
@property (nonatomic, assign) MSDynamicsDrawerDirection possibleDrawerDirection;
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
// Dyanimcs
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIPushBehavior *panePushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *paneElasticityBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *bounceElasticityBehavior;
@property (nonatomic, strong) UIGravityBehavior *paneGravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *paneBoundaryCollisionBehavior;
@property (nonatomic, copy) void (^dynamicAnimatorCompletion)(void);

@end

@implementation MSDynamicsDrawerViewController

@dynamic paneViewController;
@dynamic paneState;

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
    [self.paneView removeObserver:self forKeyPath:@"frame"];
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
    [self.view addSubview:self.drawerView];
    [self.view addSubview:self.paneView];
    self.drawerView.frame = (CGRect){CGPointZero, self.view.frame.size};
    self.paneView.frame = (CGRect){CGPointZero, self.view.frame.size};
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.paneView addObserver:self forKeyPath:@"frame" options:0 context:NULL];
    
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
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = YES;
    self.drawerView.transform = CGAffineTransformIdentity;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = NO;
    [self updateStylers];
}

- (BOOL)shouldAutorotate
{
    return !self.dynamicAnimator.isRunning;
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
    
    self.paneViewSlideOffAnimationEnabled = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    self.shouldAlignStatusBarToPaneView = YES;
    
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
    
#if defined(DEBUG_DYNAMICS)
    self.gravityMagnitude = 0.05;
#endif
    
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
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.possibleDrawerDirection), @"Unable to bounce open with multiple possible reveal directions");
    [self bouncePaneOpenInDirection:self.currentDrawerDirection];
}

- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(((self.possibleDrawerDirection & direction) == direction), @"Unable to bounce open with impossible/multiple directions");
    self.currentDrawerDirection = direction;
    [self addDynamicsBehaviorsToCreatePaneState:MSDynamicsDrawerPaneStateClosed pushMagnitude:self.bounceMagnitude pushAngle:[self gravityAngleForState:MSDynamicsDrawerPaneStateOpen direction:direction] pushElasticity:self.bounceElasticity];
}

#pragma mark Generic View Controller Containment

- (void)replaceViewController:(UIViewController *)existingViewController withViewController:(UIViewController *)newViewController inContainerView:(UIView *)containerView completion:(void (^)(void))completion
{
    // Add initial view controller
	if (!existingViewController && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [newViewController beginAppearanceTransition:YES animated:NO];
		[self addChildViewController:newViewController];
        newViewController.view.frame = (CGRect){CGPointZero, containerView.frame.size};
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
        newViewController.view.frame = (CGRect){CGPointZero, containerView.frame.size};
        [self addChildViewController:newViewController];
        [containerView addSubview:newViewController.view];
        [newViewController didMoveToParentViewController:self];
        [newViewController endAppearanceTransition];
        if (completion) completion();
    }
}

#pragma mark Drawer View Controller

- (UIViewController *)drawerViewController
{
    return _drawerViewController;
}

- (void)setDrawerViewController:(UIViewController *)drawerViewController
{
    [self replaceViewController:self.drawerViewController withViewController:drawerViewController inContainerView:self.drawerView completion:^{
        _drawerViewController = drawerViewController;
    }];
}

- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Only accepts cardinal reveal directions");
    for (UIViewController *currentDrawerViewController in self.drawerViewControllers) {
        NSAssert(currentDrawerViewController != drawerViewController, @"Unable to add a drawer view controller when it's previously been added");
    }
    switch (direction) {
        case MSDynamicsDrawerDirectionLeft:
        case MSDynamicsDrawerDirectionRight:
            NSAssert(!(self.drawerViewControllers[@(MSDynamicsDrawerDirectionTop)] || self.drawerViewControllers[@(MSDynamicsDrawerDirectionBottom)]), @"Unable to simultaneously have top/bottom drawer view controllers while setting left/right drawer view controllers");
            break;
        case MSDynamicsDrawerDirectionTop:
        case MSDynamicsDrawerDirectionBottom:
            NSAssert(!(self.drawerViewControllers[@(MSDynamicsDrawerDirectionLeft)] || self.drawerViewControllers[@(MSDynamicsDrawerDirectionRight)]), @"Unable to simultaneously have left/right drawer view controllers while setting top/bottom drawer view controllers");
            break;
        default:
            break;
    }
    UIViewController *existingDrawerViewController = self.drawerViewControllers[@(direction)];
    // New drawer view controller
    if (drawerViewController && (existingDrawerViewController == nil)) {
        self.possibleDrawerDirection |= direction;
        self.drawerViewControllers[@(direction)] = drawerViewController;
    }
    // Removing existing drawer view controller
    else if (!drawerViewController && (existingDrawerViewController != nil)) {
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

- (UIViewController *)paneViewController
{
    return _paneViewController;
}

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
            paneViewController.view.frame = (CGRect){CGPointZero, self.paneView.frame.size};
            [paneViewController beginAppearanceTransition:YES animated:animated];
            [self.paneView addSubview:paneViewController.view];
            _paneViewController = paneViewController;
            // Force redraw of the new pane view (drastically smoothes animation)
            [self.paneView setNeedsDisplay];
            [CATransaction flush];
            [self setNeedsStatusBarAppearanceUpdate];
            // After drawing has finished, add new pane view controller view and close
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
        [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:animated allowUserInterruption:NO completion:^{
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
        [self.dynamicAnimator addBehavior:self.self.paneElasticityBehavior];
    }
    
    if (pushMagnitude != 0.0) {
        self.panePushBehavior.angle = pushAngle;
        self.panePushBehavior.magnitude = pushMagnitude;
        [self.dynamicAnimator addBehavior:self.panePushBehavior];
        self.panePushBehavior.active = YES;
    }
}

- (UIBezierPath *)boundaryPathForState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Indeterminate boundary for non-cardinal reveal direction");
    CGRect boundary = CGRectZero;
    boundary.origin = (CGPoint){-1.0, -1.0};
    if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        boundary.size.height = (CGRectGetHeight(self.paneView.frame) + 1.0);
        switch (state) {
            case MSDynamicsDrawerPaneStateClosed:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) * 2.0) + MSDynamicsDrawerOpenAnimationOvershot + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpen:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) + self.openStateRevealWidth) + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpenWide:
                boundary.size.width = ((CGRectGetWidth(self.paneView.frame) * 2.0) + MSDynamicsDrawerOpenAnimationOvershot + 2.0);
                break;
        }
    } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
        boundary.size.width = (CGRectGetWidth(self.paneView.frame) + 1.0);
        switch (state) {
            case MSDynamicsDrawerPaneStateClosed:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) * 2.0) + MSDynamicsDrawerOpenAnimationOvershot + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpen:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) + self.openStateRevealWidth) + 2.0);
                break;
            case MSDynamicsDrawerPaneStateOpenWide:
                boundary.size.height = ((CGRectGetHeight(self.paneView.frame) * 2.0) + MSDynamicsDrawerOpenAnimationOvershot + 2.0);
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

- (CGFloat)gravityAngleForState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)rirection
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(rirection), @"Indeterminate gravity angle for non-cardinal reveal direction");
    switch (rirection) {
        case MSDynamicsDrawerDirectionTop:
            return ((state != MSDynamicsDrawerPaneStateClosed) ? M_PI_2 : (3.0 * M_PI_2));
        case MSDynamicsDrawerDirectionLeft:
            return ((state != MSDynamicsDrawerPaneStateClosed) ? 0.0 : M_PI);
        case MSDynamicsDrawerDirectionBottom:
            return ((state != MSDynamicsDrawerPaneStateClosed) ? (3.0 * M_PI_2) : M_PI_2);
        case MSDynamicsDrawerDirectionRight:
            return ((state != MSDynamicsDrawerPaneStateClosed) ? M_PI : 0.0);
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
        default:
            break;
    }
    // Clip to 0.0 < fraction < 1.0
    fraction = (fraction < 0.0) ? 0.0 : fraction;
    fraction = (fraction > 1.0) ? 1.0 : fraction;
    return fraction;
}

#pragma mark Stylers

- (void)addStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction;
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
        if (existsInCurrentStylers && [styler respondsToSelector:@selector(stylerWasAddedToDynamicsDrawerViewController:)]) {
            [styler stylerWasAddedToDynamicsDrawerViewController:self];
        }
    });
    [self updateStylers];
}

- (void)removeStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction;
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
        if ((containedCount == 0) && [styler respondsToSelector:@selector(stylerWasRemovedFromDynamicsDrawerViewController:)]) {
            [styler stylerWasRemovedFromDynamicsDrawerViewController:self];
        }
    });
    [self updateStylers];
}

- (void)addStylersFromArray:(NSArray *)stylers forDirection:(MSDynamicsDrawerDirection)direction;
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

- (NSArray *)stylersForDirection:(MSDynamicsDrawerDirection)direction;
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
    
    [self updateStylers];
}

- (MSDynamicsDrawerPaneState)paneState
{
    return _paneState;
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState
{
    [self setPaneState:paneState animated:NO allowUserInterruption:NO completion:nil];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction
{
    [self setPaneState:paneState inDirection:direction animated:NO allowUserInterruption:NO completion:nil];
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion;
{
    if ((paneState != MSDynamicsDrawerPaneStateClosed) && (self.currentDrawerDirection == MSDynamicsDrawerDirectionNone)) {
        NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.possibleDrawerDirection), @"Unable to set pane to an open state with multiple possible reveal directions");
        [self setPaneState:paneState inDirection:self.possibleDrawerDirection animated:animated allowUserInterruption:allowUserInterruption completion:completion];
    } else {
        [self setPaneState:paneState inDirection:self.currentDrawerDirection animated:animated allowUserInterruption:allowUserInterruption completion:completion];
    }
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion;
{
    NSAssert(((self.possibleDrawerDirection & direction) == direction), @"Unable to bounce open with impossible or multiple directions");
    
    void(^internalCompletion)() = ^ {
        _paneState = paneState;
        if (completion != nil) completion();
    };
    
    self.currentDrawerDirection = direction;
    
    if (animated) {
        if (!allowUserInterruption) [self setViewUserInteractionEnabled:NO];
        [self addDynamicsBehaviorsToCreatePaneState:paneState];
        __weak typeof(self) weakSelf = self;
        self.dynamicAnimatorCompletion = ^{
            if (!allowUserInterruption) [weakSelf setViewUserInteractionEnabled:YES];
            internalCompletion();
        };
    } else {
        self.paneView.frame = (CGRect){[self paneViewOriginForPaneState:paneState], self.paneView.frame.size};
        internalCompletion();
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
                    paneViewOrigin.x = CGRectGetWidth(self.view.frame);
                    break;
                case MSDynamicsDrawerDirectionTop:
                    paneViewOrigin.y = CGRectGetHeight(self.view.frame);
                    break;
                case MSDynamicsDrawerDirectionBottom:
                    paneViewOrigin.y = 0.0;
                    break;
                case MSDynamicsDrawerDirectionRight:
                    paneViewOrigin.x = 0.0;
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

- (BOOL)paneViewIsPositionedInState:(MSDynamicsDrawerPaneState *)paneState
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

#pragma mark Current Reveal Direction

- (MSDynamicsDrawerDirection)currentDrawerDirection
{
    return _currentDrawerDirection;
}

- (void)setCurrentDrawerDirection:(MSDynamicsDrawerDirection)currentDrawerDirection
{
    NSAssert(MSDynamicsDrawerDirectionIsNonMasked(currentDrawerDirection), @"Only accepts non-masked directions as current reveal direction");
    
    if (_currentDrawerDirection == currentDrawerDirection) return;
    _currentDrawerDirection = currentDrawerDirection;
    
    self.drawerViewController = self.drawerViewControllers[@(currentDrawerDirection)];
    
    // Reset the drawer view's transform when the reveal direction is changed
    self.drawerView.transform = CGAffineTransformIdentity;
    
    // Disable pane view interaction when not closed
    [self setPaneViewControllerViewUserInteractionEnabled:(currentDrawerDirection == MSDynamicsDrawerDirectionNone)];
    
    [self updateStylers];
}

#pragma mark Possible Reveal Direction

- (MSDynamicsDrawerDirection)possibleDrawerDirection
{
    return _possibleDrawerDirection;
}

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
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(self.currentDrawerDirection), @"Invalid state, must be opened to close");
    if ([self paneTapToCloseEnabledForDirection:self.currentDrawerDirection]) {
        [self addDynamicsBehaviorsToCreatePaneState:MSDynamicsDrawerPaneStateClosed];
    }
}

- (void)panePanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    static MSDynamicsDrawerDirection panDrawerDirection;
    static CGPoint panStartLocationInPane;
    static CGFloat panVelocity;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            panStartLocationInPane = [gestureRecognizer locationInView:self.paneView];
            panVelocity = 0.0;
            panDrawerDirection = (MSDynamicsDrawerDirectionNone | self.currentDrawerDirection);
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint panLocationInPane = [gestureRecognizer locationInView:self.paneView];
            // Pan gesture tracking
            CGRect updatedPaneFrame = self.paneView.frame;
            CGFloat panDelta;
            if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
                panDelta = (panLocationInPane.x - panStartLocationInPane.x);
                updatedPaneFrame.origin.x += panDelta;
            } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
                panDelta = (panLocationInPane.y - panStartLocationInPane.y);
                updatedPaneFrame.origin.y += panDelta;
            }
            // Direction Determination if we have no pan reveal direction or current reveal direction
            if (panDrawerDirection == MSDynamicsDrawerDirectionNone ||
                self.currentDrawerDirection == MSDynamicsDrawerDirectionNone) {
                MSDynamicsDrawerDirection potentialPanDrawerDirection = MSDynamicsDrawerDirectionNone;
                if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
                    if (panDelta > 0) {
                        potentialPanDrawerDirection = MSDynamicsDrawerDirectionLeft;
                    } else if (panDelta < 0) {
                        potentialPanDrawerDirection = MSDynamicsDrawerDirectionRight;
                    }
                } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
                    if (panDelta > 0) {
                        potentialPanDrawerDirection = MSDynamicsDrawerDirectionTop;
                    } else if (panDelta < 0) {
                        potentialPanDrawerDirection = MSDynamicsDrawerDirectionBottom;
                    }
                }
                if ((potentialPanDrawerDirection != MSDynamicsDrawerDirectionNone)             // Potential reveal direction is not none
                    && (self.possibleDrawerDirection & potentialPanDrawerDirection)                  // Potential reveal direction is possible
                    && ([self paneDragRevealEnabledForDirection:potentialPanDrawerDirection])) // Pane drag reveal is enabled for the potential reveal direction
                    
                {
                    panDrawerDirection = potentialPanDrawerDirection;
                    self.currentDrawerDirection = panDrawerDirection;
                } else {
                    return;
                }
            }
            // If the determined pan reveal direction's pane drag reveal is disabled, return
            else if (![self paneDragRevealEnabledForDirection:panDrawerDirection]) {
                return;
            }
            // Panning is able to move pane, so remove all animators to prevent conflicting behavior
            [self.dynamicAnimator removeAllBehaviors];
            // Frame Bounding
            CGFloat paneBoundOpenLocation = 0.0;
            CGFloat paneBoundClosedLocation = 0.0;
            CGFloat *paneLocation = NULL;
            switch (self.currentDrawerDirection) {
                case MSDynamicsDrawerDirectionLeft:
                    paneLocation = &updatedPaneFrame.origin.x;
                    paneBoundOpenLocation = [self openStateRevealWidth];
                    break;
                case MSDynamicsDrawerDirectionRight:
                    paneLocation = &updatedPaneFrame.origin.x;
                    paneBoundClosedLocation = -[self openStateRevealWidth];
                    break;
                case MSDynamicsDrawerDirectionTop: {
                    paneLocation = &updatedPaneFrame.origin.y;
                    paneBoundOpenLocation = [self openStateRevealWidth];
                    break;
                case MSDynamicsDrawerDirectionBottom:
                    paneLocation = &updatedPaneFrame.origin.y;
                    paneBoundClosedLocation = -[self openStateRevealWidth];
                    break;
                default:
                    NSAssert(NO, @"Invalid state, current reveal direction must be set by this point");
                    break;
                }
            }
            BOOL frameBounded = YES;
            if (*paneLocation <= paneBoundClosedLocation) {
                *paneLocation = paneBoundClosedLocation;
            }
            else if (*paneLocation >= paneBoundOpenLocation) {
                *paneLocation = paneBoundOpenLocation;
            }
            else {
                frameBounded = NO;
            }
            self.paneView.frame = updatedPaneFrame;
            // Velocity Calculation
            CGFloat updatedVelocity = 0.0;
            if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionHorizontal) {
                updatedVelocity = -(panStartLocationInPane.x - panLocationInPane.x);
            } else if (self.possibleDrawerDirection & MSDynamicsDrawerDirectionVertical) {
                updatedVelocity = -(panStartLocationInPane.y - panLocationInPane.y);
            }
            // Velocity can be 0 due to an error, so ignore it in that case
            if ((updatedVelocity != 0.0) && !frameBounded) {
                panVelocity = updatedVelocity;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (panDrawerDirection == MSDynamicsDrawerDirectionNone) {
                return;
            }
            // Reached the velocity threshold so update to the appropriate state
            if (fabsf(panVelocity) > MSPaneViewVelocityThreshold) {
                MSDynamicsDrawerPaneState state = 0;
                if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft)) {
                    state = ((panVelocity > 0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
                } else if (self.currentDrawerDirection & (MSDynamicsDrawerDirectionBottom | MSDynamicsDrawerDirectionRight)) {
                    state = ((panVelocity < 0) ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed);
                } else {
                    NSAssert(NO, @"Invalid state, reveal direction niether positive nor negative");
                }
                [self addDynamicsBehaviorsToCreatePaneState:state pushMagnitude:(fabsf(panVelocity) * MSPaneViewVelocityMultiplier) pushAngle:[self gravityAngleForState:state direction:self.currentDrawerDirection] pushElasticity:self.elasticity];
            }
            // If we're released past half-way, snap to completion with no bounce, otherwise, snap to back to the starting position with no bounce
            else {
                MSDynamicsDrawerPaneState state = (([self paneViewClosedFraction] > 0.5) ? MSDynamicsDrawerPaneStateClosed : MSDynamicsDrawerPaneStateOpen);
                [self addDynamicsBehaviorsToCreatePaneState:state];
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
    if([keyPath isEqualToString:@"frame"] && (object == self.paneView)) {
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            [self paneViewDidUpdateFrame];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

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
        if ([self paneViewIsPositionedInState:&paneState]) {
            return (paneState != MSDynamicsDrawerPaneStateClosed);
        }
    }
    return YES;
}

#pragma mark - UIDynamicAnimatorDelegates

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    // When dynamic animator has paused, a pane state has been reached, so remove all behaviors
    [self.dynamicAnimator removeAllBehaviors];
    
    // Update to the new pane state
    MSDynamicsDrawerPaneState updatedPaneState;
    if ([self paneViewIsPositionedInState:&updatedPaneState]) {
        if (updatedPaneState == MSDynamicsDrawerPaneStateClosed) {
            self.currentDrawerDirection = MSDynamicsDrawerDirectionNone;
        }
        self.paneState = updatedPaneState;
    }
    
    [self setPaneViewControllerViewUserInteractionEnabled:(self.paneState == MSDynamicsDrawerPaneStateClosed)];

    // Since rotation is disabled while the dynamic animator is running, we invoke this method to cause rotation to happen (if rotation has been initiated during dynamics)
    [UIViewController attemptRotationToDeviceOrientation];
    
    if (self.dynamicAnimatorCompletion) {
        self.dynamicAnimatorCompletion();
        self.dynamicAnimatorCompletion = nil;
    }
}

@end
