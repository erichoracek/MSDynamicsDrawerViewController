//
//  MSNavigationPaneViewController.h
//  MSNavigationPaneViewController
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

#import "MSNavigationPaneViewController.h"
#import <QuartzCore/QuartzCore.h>

//#define LAYOUT_DEBUG

// Sizes
const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthLeft = 267.0;
const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthTop = 200.0;
const CGFloat MSNavigationPaneOpenAnimationOvershot = 30.0;

// Appearance Type Constants
const CGFloat MSNavigationPaneAppearanceTypeZoomScaleFraction = 0.075;
const CGFloat MSNavigationPaneAppearanceTypeParallaxOffsetFraction = 0.35;

// Animation Durations
const CGFloat MSNavigationPaneAnimationDurationOpenToSide = 0.2;
const CGFloat MSNavigationPaneAnimationDurationClosedToSide = 0.5;
const CGFloat MSNavigationPaneAnimationDurationSideToClosed = 0.45;
const CGFloat MSNavigationPaneAnimationDurationOpenToClosed = 0.3;
const CGFloat MSNavigationPaneAnimationDurationClosedToOpen = 0.3;
const CGFloat MSNavigationPaneAnimationDurationSnap = 0.2;

// Velocity Thresholds
const CGFloat MSDraggableViewVelocityThreshold = 5.0;

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

@interface MSNavigationPaneViewController () <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate>
{    
    UIViewController *_masterViewController;
    UIViewController *_paneViewController;
    MSNavigationPaneAppearanceType _appearanceType;
    MSNavigationPaneState _paneState;
    MSNavigationPaneRevealDirection _revealDirection;
}

@property (nonatomic, assign) BOOL animatingPane;
@property (nonatomic, assign) BOOL animatingRotation;
@property (nonatomic, assign) CGPoint paneStartLocation;
@property (nonatomic, assign) CGPoint paneStartLocationInSuperview;
@property (nonatomic, assign) CGFloat paneVelocity;
@property (nonatomic) UIView *masterView;
@property (nonatomic) UIView *paneView;
@property (nonatomic) NSMutableDictionary *masterViewControllers;
@property (nonatomic) NSMutableSet *paneAdjustmentHandlers;
@property (nonatomic) NSMutableSet *touchForwardingClasses;
@property (nonatomic) UIPanGestureRecognizer *panePanGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *paneTapGestureRecognizer;
@property (nonatomic) UIDynamicAnimator* animator;
@property (nonatomic) UIGravityBehavior* gravity;
@property (nonatomic) UICollisionBehavior* boundary;
@property (nonatomic, copy) void (^dynamicAnimatorCompletion)(void);
@property (nonatomic, copy) void (^dynamicAnimatorAction)(void);


- (void)initialize;
- (void)updatePaneToState:(MSNavigationPaneState)state;
- (void)didUpdateDynamicAnimatorAction;
- (void)updateDynamicsForState:(MSNavigationPaneState)state;
- (void)updateAppearance;
- (CGFloat)paneViewClosedFraction;
- (void)paneTapped:(UIPanGestureRecognizer *)gesureRecognizer;
- (void)panePanned:(UITapGestureRecognizer *)gesureRecognizer;

@end

@implementation MSNavigationPaneViewController

//@dynamic masterViewController;
@dynamic paneViewController;
@dynamic paneState;
@dynamic appearanceType;

#pragma mark - NSObject

- (void)dealloc
{
    [self.paneView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Both views are the same size of our view
    self.masterView.frame = (CGRect){CGPointZero, self.view.frame.size};
    self.paneView.frame = (CGRect){CGPointZero, self.view.frame.size};
    
    [self.view addSubview:self.masterView];
    [self.view addSubview:self.paneView];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.paneView addObserver:self forKeyPath:@"frame" options:NULL context:NULL];
    
    [self updateDynamicsForState:self.paneState];
}

- (void)awakeFromNib
{
    [self initialize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.masterViewController.supportedInterfaceOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = YES;
    self.masterView.transform = CGAffineTransformIdentity;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = NO;
    [self updateAppearance];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.masterViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.masterViewController;
}

#pragma mark - MSNavigationPaneViewController

- (void)initialize
{
    _paneState = MSNavigationPaneStateClosed;
    _appearanceType = MSNavigationPaneAppearanceTypeNone;
    _revealDirection = MSNavigationPaneRevealDirectionLeft;
    _openStateRevealWidth = MSNavigationPaneDefaultOpenStateRevealWidthLeft;
    _paneDraggingEnabled = YES;
    _paneViewSlideOffAnimationEnabled = YES;
    
    self.masterViewControllers = [NSMutableDictionary new];
    
    self.touchForwardingClasses = [NSMutableSet setWithObjects:UISlider.class, UISwitch.class, nil];
    self.paneAdjustmentHandlers = [NSMutableSet set];
    
    self.masterView = [UIView new];
    self.masterView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.masterView.backgroundColor = [UIColor clearColor];
    
    self.paneView = [UIView new];
    self.paneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.paneView.backgroundColor = [UIColor clearColor];
    
    self.panePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panePanned:)];
    self.panePanGestureRecognizer.minimumNumberOfTouches = 1;
    self.panePanGestureRecognizer.maximumNumberOfTouches = 1;
    self.panePanGestureRecognizer.delegate = self;
    [self.paneView addGestureRecognizer:self.panePanGestureRecognizer];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    
    self.boundary = [[UICollisionBehavior alloc] initWithItems:@[self.paneView]];
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.paneView]];
    
    __weak typeof(self) weakSelf = self;
    self.gravity.action = ^{
        [weakSelf didUpdateDynamicAnimatorAction];
        [weakSelf updateAppearance];
    };
    
#if defined(LAYOUT_DEBUG)
    self.masterView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    self.masterView.layer.borderColor = [[UIColor blueColor] CGColor];
    self.masterView.layer.borderWidth = 2.0;
    
    self.paneView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    self.paneView.layer.borderColor = [[UIColor redColor] CGColor];
    self.paneView.layer.borderWidth = 2.0;
#endif
}

- (void)bounceAgainstGravity
{
    self.view.userInteractionEnabled = NO;
    self.animatingPane = YES;
    [self updateDynamicsForState:self.paneState];
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.boundary];
    
    UIPushBehavior *bouncePush;
    bouncePush = [[UIPushBehavior alloc] initWithItems:@[self.paneView] mode:UIPushBehaviorModeInstantaneous];
    bouncePush.angle = ((self.paneState != MSNavigationPaneStateClosed) ? M_PI : 0.0);
    bouncePush.magnitude = 60.0;
    [self.animator addBehavior:bouncePush];
    
    NSLog(@"Bounce Push: (rad: %f, mag: %f)", bouncePush.angle, bouncePush.magnitude);
    
    __weak typeof(self) weakSelf = self;
    self.dynamicAnimatorCompletion = ^{
        [weakSelf.animator removeBehavior:bouncePush];
        [weakSelf.animator removeBehavior:weakSelf.boundary];
        [weakSelf.animator removeBehavior:weakSelf.gravity];
        weakSelf.animatingPane = NO;
        weakSelf.view.userInteractionEnabled = YES;
    };
}

#pragma mark View Controller Accessors

- (UIViewController *)masterViewController
{
    return _masterViewController;
}

- (void)setMasterViewController:(UIViewController *)masterViewController
{
	if (self.masterViewController == nil) {
        
        masterViewController.view.frame = self.masterView.bounds;
		_masterViewController = masterViewController;
		[self addChildViewController:self.masterViewController];
		[self.masterView addSubview:self.masterViewController.view];
		[self.masterViewController didMoveToParentViewController:self];
        
	} else if (self.masterViewController != masterViewController) {
        
		masterViewController.view.frame = self.masterView.bounds;
		[self.masterViewController willMoveToParentViewController:nil];
		[self addChildViewController:masterViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [self.masterViewController removeFromParentViewController];
            [masterViewController didMoveToParentViewController:self];
            [self setNeedsStatusBarAppearanceUpdate];
            _masterViewController = masterViewController;
        };
        
		[self transitionFromViewController:self.masterViewController toViewController:masterViewController duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:transitionCompletion];
	}
}

- (void)setMasterViewController:(UIViewController *)masterViewController forRevealDirection:(MSNavigationPaneRevealDirection)revealDirection
{
    self.masterViewControllers[@(revealDirection)] = masterViewController;
}

- (UIViewController *)paneViewController
{
    return _paneViewController;
}

- (void)setPaneViewController:(UIViewController *)paneViewController
{
	if (self.paneViewController == nil) {
        
		paneViewController.view.frame = self.paneView.bounds;
		_paneViewController = paneViewController;
		[self addChildViewController:self.paneViewController];
		[self.paneView addSubview:self.paneViewController.view];
		[self.paneViewController didMoveToParentViewController:self];
        
	} else if (self.paneViewController != paneViewController) {
        
		paneViewController.view.frame = self.paneView.bounds;
		[self.paneViewController willMoveToParentViewController:nil];
		[self addChildViewController:paneViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [self.paneViewController removeFromParentViewController];
            [paneViewController didMoveToParentViewController:self];
            _paneViewController = paneViewController;
        };
        
		[self transitionFromViewController:self.paneViewController
						  toViewController:paneViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:nil
								completion:transitionCompletion];
	}
}

- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    void(^internalCompletion)() = ^{
        self.view.userInteractionEnabled = YES;
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:didAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self didAnimateToPane:paneViewController];
        }
        if (completion != nil) completion();
    };
    
    if (!animated || (self.paneViewController == nil)) {
        self.paneViewController = paneViewController;
        internalCompletion();
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    void(^movePaneToSide)() = ^{
        CGRect paneViewFrame = self.paneView.frame;
        switch (self.revealDirection) {
            case MSNavigationPaneRevealDirectionLeft:
                paneViewFrame.origin.x = (CGRectGetWidth(self.view.frame) + MSNavigationPaneOpenAnimationOvershot);
                break;
            case MSNavigationPaneRevealDirectionTop:
                paneViewFrame.origin.y = (CGRectGetHeight(self.view.frame) + MSNavigationPaneOpenAnimationOvershot);
                break;
        }
        self.paneView.frame = paneViewFrame;
    };
    
    void(^movePaneToClosed)() = ^{
        CGRect paneViewFrame = self.paneView.frame;
        paneViewFrame.origin = CGPointMake(0.0, 0.0);
        self.paneView.frame = paneViewFrame;
    };
    
    // Animate off to the right first, set the pane view controller, and then animate closed
    if (paneViewController != self.paneViewController) {
        
        void(^newPaneCompletion)(BOOL finished) = ^(BOOL finished) {
            
            self.paneViewController = paneViewController;
            
            // Force redraw of the new pane view (for smooth animation)
            [self.paneView setNeedsDisplay];
            [CATransaction flush];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Slide the pane back into view
                [self setPaneState:MSNavigationPaneStateClosed animated:animated completion:internalCompletion];
            });
        };
        
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:willAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self willAnimateToPane:paneViewController];
        }
        
        if (self.paneViewSlideOffAnimationEnabled) {
            
            self.animatingPane = YES;
            [self updateDynamicsForState:MSNavigationPaneStateOpenWide];
            [self.animator addBehavior:self.gravity];
            [self.animator addBehavior:self.boundary];
            
            __weak typeof(self) weakSelf = self;
            
            self.dynamicAnimatorAction = ^{
                if (weakSelf.paneView.frame.origin.x > (CGRectGetWidth(weakSelf.view.frame) + MSNavigationPaneOpenAnimationOvershot)) {
                    [weakSelf.animator removeBehavior:weakSelf.boundary];
                    [weakSelf.animator removeBehavior:weakSelf.gravity];
                }
            };
            
            self.dynamicAnimatorCompletion = ^{
                movePaneToSide();
                newPaneCompletion(YES);
                weakSelf.dynamicAnimatorAction = nil;
            };
            
        } else {
            
            newPaneCompletion(YES);
        }

    }
    // If we're trying to animate to the currently visible pane view controller, just close
    else {
        [self setPaneState:MSNavigationPaneStateClosed animated:animated completion:^{
            internalCompletion();
        }];
    }
}

#pragma mark Pane View Animation

- (void)didUpdateDynamicAnimatorAction
{
    if (self.dynamicAnimatorAction) {
        self.dynamicAnimatorAction();
    }
}

- (void)updateDynamicsForState:(MSNavigationPaneState)state;
{
    [self.boundary removeAllBoundaries];
    
    CGSize boundarySize;
    switch (state) {
        case MSNavigationPaneStateClosed: {
            boundarySize.width = ((CGRectGetWidth(self.view.frame) * 2.0) + MSNavigationPaneOpenAnimationOvershot + 1.0);
            break;
        }
        case MSNavigationPaneStateOpen: {
            boundarySize.width = ((CGRectGetWidth(self.view.frame) + self.openStateRevealWidth) + 1.0);
            break;
        }
        case MSNavigationPaneStateOpenWide: {
            boundarySize.width = ((CGRectGetWidth(self.view.frame) * 2.0) + MSNavigationPaneOpenAnimationOvershot + 1.0);
            break;
        }
    }
    boundarySize.height = (CGRectGetHeight(self.view.frame) + 1.0);
    [self.boundary addBoundaryWithIdentifier:@"Boundary" forPath:[UIBezierPath bezierPathWithRect:(CGRect){{-1.0, -1.0}, boundarySize}]];
    
    self.gravity.magnitude = ((self.animatingPane == YES) ? 1.25 : 0.0);
    self.gravity.angle = ((state != MSNavigationPaneStateClosed) ? 0.0 : M_PI);
}

- (CGFloat)paneViewClosedFraction
{
    CGFloat fraction;
    switch (self.revealDirection) {
        case MSNavigationPaneRevealDirectionLeft:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.x) / self.openStateRevealWidth);
            break;
        case MSNavigationPaneRevealDirectionTop:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.y) / self.openStateRevealWidth);
            break;
    }
    
    // Clip to 0.0 < fraction < 1.0
    fraction = (fraction < 0.0) ? 0.0 : fraction;
    fraction = (fraction > 1.0) ? 1.0 : fraction;
    
    return fraction;
}

- (void)updateAppearance
{
    // This prevents weird transform issues
    if (self.animatingRotation) {
        return;
    }
    
    // Update appearance types
    CGFloat closedFraction = [self paneViewClosedFraction];
    if (self.appearanceType == MSNavigationPaneAppearanceTypeZoom) {
        CGFloat scale = (1.0 - (closedFraction * MSNavigationPaneAppearanceTypeZoomScaleFraction));
        self.masterView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    else if (self.appearanceType == MSNavigationPaneAppearanceTypeParallax) {
        CGFloat translate = -((self.openStateRevealWidth * closedFraction) * MSNavigationPaneAppearanceTypeParallaxOffsetFraction);
        CGAffineTransform transform;
        switch (self.revealDirection) {
            case MSNavigationPaneRevealDirectionLeft:
                transform = CGAffineTransformMakeTranslation(translate, 0.0);
                break;
            case MSNavigationPaneRevealDirectionTop:
                transform = CGAffineTransformMakeTranslation(0.0, translate);
                break;
        }
        self.masterView.transform = transform;
    }
    else if (self.appearanceType == MSNavigationPaneAppearanceTypeFade) {
        self.masterView.alpha = (1.0 - closedFraction);
    }
    
    CGRect paneViewRect = (CGRect){CGPointZero, self.paneView.frame.size};
    switch (self.revealDirection) {
        case MSNavigationPaneRevealDirectionLeft:
            self.paneView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(paneViewRect, 0.0, -40.0)] CGPath];
            break;
        case MSNavigationPaneRevealDirectionTop:
            self.paneView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(paneViewRect, -40.0, 0.0)] CGPath];
            break;
    }
}

- (void)updatePaneToState:(MSNavigationPaneState)state
{
    // Notify delegate of pane state change
    if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:willUpdateToPaneState:)]) {
        [self.delegate navigationPaneViewController:self willUpdateToPaneState:state];
    }
    
    self.view.userInteractionEnabled = NO;
    self.animatingPane = YES;
    [self updateDynamicsForState:state];
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.boundary];
    
    // If we are past the dragging velocity threshold, add a push behavior
    UIPushBehavior *dragPush;
    if (fabs(self.paneVelocity) > MSDraggableViewVelocityThreshold) {
        dragPush = [[UIPushBehavior alloc] initWithItems:@[self.paneView] mode:UIPushBehaviorModeInstantaneous];
        // Pane is updating to open from closed
        if (state == MSNavigationPaneStateOpen) {
            dragPush.angle = ((self.paneVelocity > 0.0) ? 0.0 : M_PI);
        }
        // Pane is updating to closed from open
        else {
            dragPush.angle = ((self.paneVelocity > 0.0) ? 0.0 : M_PI);
        }
        dragPush.magnitude = (fabsf(self.paneVelocity) * 5.0);
        [self.animator addBehavior:dragPush];
        NSLog(@"Drag Push: (rad: %f, mag: %f)", dragPush.angle, dragPush.magnitude);
    }
    
    __weak typeof(self) weakSelf = self;
    self.dynamicAnimatorCompletion = ^{
        NSLog(@"Finished animating, updating pane to state: %@", ((state == MSNavigationPaneStateOpen) ? @"Open" : @"Closed"));
        [weakSelf.animator removeBehavior:dragPush];
        [weakSelf.animator removeBehavior:weakSelf.gravity];
        [weakSelf.animator removeBehavior:weakSelf.boundary];
        weakSelf.animatingPane = NO;
        weakSelf.view.userInteractionEnabled = YES;
        if (weakSelf.paneState != state) {
            weakSelf.paneState = state;
            if ([weakSelf.delegate respondsToSelector:@selector(navigationPaneViewController:didUpdateToPaneState:)]) {
                [weakSelf.delegate navigationPaneViewController:weakSelf didUpdateToPaneState:state];
            }
        }
    };
}

#pragma mark Appearance Type

- (void)setAppearanceType:(MSNavigationPaneAppearanceType)appearanceType
{
    // Reset scale transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeZoom) {
        self.masterView.transform = CGAffineTransformIdentity;
    }
    // Reset translate transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeParallax) {
        self.masterView.transform = CGAffineTransformIdentity;
    }
    if (appearanceType != MSNavigationPaneAppearanceTypeFade) {
        self.masterView.alpha = 1.0;
    }
    _appearanceType = appearanceType;
}

- (MSNavigationPaneAppearanceType)appearanceType
{
    return _appearanceType;
}

#pragma mark Pane State

- (MSNavigationPaneState)paneState
{
    return _paneState;
}

- (void)setPaneState:(MSNavigationPaneState)paneState
{
    [self setPaneState:paneState animated:NO completion:nil];
}

- (void)setPaneState:(MSNavigationPaneState)paneState animated:(BOOL)animated completion:(void (^)(void))completion;
{
    if (paneState == _paneState) {
        return;
    }
    
    void(^internalCompletion)() = ^ {
        _paneState = paneState;
        // Disable interation when pane is open
        for (UIView *subview in self.paneView.subviews) {
            subview.userInteractionEnabled = (self.paneState == MSNavigationPaneStateClosed);
        }
        // Notify delegate of pane state change
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:didUpdateToPaneState:)]) {
            [self.delegate navigationPaneViewController:self didUpdateToPaneState:self.paneState];
        }
        if (completion != nil) completion();
    };
    
    void(^addGestureRecognizer)() = ^() {
        if (!self.paneTapGestureRecognizer) {
            self.paneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paneTapped:)];
            self.paneTapGestureRecognizer.numberOfTouchesRequired = 1;
            self.paneTapGestureRecognizer.numberOfTapsRequired = 1;
        }
        [self.paneView addGestureRecognizer:self.paneTapGestureRecognizer];
    };
    
    void(^removeGestureRecognizer)() = ^() {
        [self.paneView removeGestureRecognizer:self.paneTapGestureRecognizer];
    };
    
    if (animated) {
        
        self.view.userInteractionEnabled = NO;
        self.animatingPane = YES;
        [self updateDynamicsForState:paneState];
        [self.animator addBehavior:self.gravity];
        [self.animator addBehavior:self.boundary];
        
        __weak typeof(self) weakSelf = self;
        self.dynamicAnimatorCompletion = ^{
            [weakSelf.animator removeBehavior:weakSelf.gravity];
            [weakSelf.animator removeBehavior:weakSelf.boundary];
            weakSelf.animatingPane = NO;
            weakSelf.view.userInteractionEnabled = YES;
            if (paneState == MSNavigationPaneStateClosed) {
                removeGestureRecognizer();
            } else {
                addGestureRecognizer();
            }
            internalCompletion();
        };
        
    } else {
        
        switch (paneState) {
            case MSNavigationPaneStateClosed: {
                CGRect paneViewFrame = self.paneView.frame;
                paneViewFrame.origin = CGPointZero;
                self.paneView.frame = paneViewFrame;
                removeGestureRecognizer();
                break;
            }
            case MSNavigationPaneStateOpen: {
                CGRect paneViewFrame = self.paneView.frame;
                switch (self.revealDirection) {
                    case MSNavigationPaneRevealDirectionLeft:
                        paneViewFrame.origin.x = self.openStateRevealWidth;
                        break;
                    case MSNavigationPaneRevealDirectionTop:
                        paneViewFrame.origin.y = self.openStateRevealWidth;
                        break;
                }
                self.paneView.frame = paneViewFrame;
                addGestureRecognizer();
                break;
            }
            case MSNavigationPaneStateOpenWide: {
                CGRect paneViewFrame = self.paneView.frame;
                switch (self.revealDirection) {
                    case MSNavigationPaneRevealDirectionLeft:
                        paneViewFrame.origin.x = CGRectGetWidth(self.view.frame);
                        break;
                    case MSNavigationPaneRevealDirectionTop:
                        paneViewFrame.origin.y = CGRectGetHeight(self.view.frame);
                        break;
                }
                self.paneView.frame = paneViewFrame;
                removeGestureRecognizer();
                break;
            }
        }
        
        internalCompletion();
    }
}

#pragma mark Open Direction

- (MSNavigationPaneRevealDirection)revealDirection
{
    return _revealDirection;
}

- (void)setRevealDirection:(MSNavigationPaneRevealDirection)revealDirection
{
    // Close the pane if it's currently open (before we update the direction)
    if (self.paneState != MSNavigationPaneStateClosed) {
        self.paneState = MSNavigationPaneStateClosed;
    }
    
    _revealDirection = revealDirection;
    
    // Reset the master view's transform when the open direction is changed
    self.masterView.transform = CGAffineTransformIdentity;
    [self updateAppearance];
}

#pragma mark - UIGestureRecognizer Callbacks

- (void)paneTapped:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
}

- (void)panePanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Don't allow for panning when dragging is disabled or the pane is actively being animated
    if (!self.paneDraggingEnabled || self.animatingPane) {
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.paneStartLocation = [gestureRecognizer locationInView:self.paneView];
            self.paneVelocity = 0.0;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint panLocationInPaneView = [gestureRecognizer locationInView:self.paneView];
            // Pane finger tracking
            CGRect newFrame = self.paneView.frame;
            switch (self.revealDirection) {
                case MSNavigationPaneRevealDirectionLeft: {
                    newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
                    if (newFrame.origin.x < 0.0) {
                        newFrame.origin.x = -nearbyintf(sqrtf(fabs(newFrame.origin.x) * 2.0));
                    } else if (newFrame.origin.x > self.openStateRevealWidth) {
                        newFrame.origin.x = (self.openStateRevealWidth + nearbyintf(sqrtf((newFrame.origin.x - self.openStateRevealWidth) * 2.0)));
                    }
                    self.paneView.frame = newFrame;
                    break;
                }
                case MSNavigationPaneRevealDirectionTop: {
                    newFrame.origin.y += (panLocationInPaneView.y - self.paneStartLocation.y);
                    if (newFrame.origin.y < 0.0) {
                        newFrame.origin.y = -nearbyintf(sqrtf(fabs(newFrame.origin.y) * 2.0));
                    } else if (newFrame.origin.y > self.openStateRevealWidth) {
                        newFrame.origin.y = (self.openStateRevealWidth + nearbyintf(sqrtf((newFrame.origin.y - self.openStateRevealWidth) * 2.0)));
                    }
                    self.paneView.frame = newFrame;
                    break;
                }
            }
            // Velocity Calculation
            CGFloat velocity;
            switch (self.revealDirection) {
                case MSNavigationPaneRevealDirectionLeft:
                    velocity = -(self.paneStartLocation.x - panLocationInPaneView.x);
                    break;
                case MSNavigationPaneRevealDirectionTop:
                    velocity = -(self.paneStartLocation.y - panLocationInPaneView.y);
                    break;
            }
            // For some reason, velocity can be 0 due to an error in the API, so just ignore it
            if (velocity != 0.0) {
                self.paneVelocity = velocity;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // We've reached the velocity threshold, bounce to the appropriate state
            if (fabsf(self.paneVelocity) > MSDraggableViewVelocityThreshold) {
                MSNavigationPaneState state = ((self.paneVelocity > 0) ? MSNavigationPaneStateOpen : MSNavigationPaneStateClosed);
                [self updatePaneToState:state];
            }
            // If we're released past half-way, snap to completion with no bounce, otherwise, snap to back to the starting position with no bounce
            else {
                MSNavigationPaneState state = (([self paneViewClosedFraction] > 0.5) ? MSNavigationPaneStateClosed : MSNavigationPaneStateOpen);
                [self updatePaneToState:state];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!self.paneDraggingEnabled) {
        return NO;
    }
    __block BOOL shouldReceiveTouch = YES;
    // Enumerate the view's superviews, checking for a touch-forwarding class
    [touch.view superviewHierarchyAction:^(UIView *view) {
        // Only enumerate while still receiving the touch
        if (shouldReceiveTouch) {
            // If the touch was in a touch forwarding view, don't handle the gesture
            [self.touchForwardingClasses enumerateObjectsUsingBlock:^(Class touchForwardingClass, BOOL *stop) {
                if ([view isKindOfClass:touchForwardingClass]) {
                    shouldReceiveTouch = NO;
                    *stop = YES;
                }
            }];
        }
    }];
    return shouldReceiveTouch;
}

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator
{

}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    if (self.dynamicAnimatorCompletion) {
        self.dynamicAnimatorCompletion();
        self.dynamicAnimatorCompletion = nil;
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#warning migrate to KVO
    if([keyPath isEqualToString:@"frame"] && (object == self.paneView)) {
        CGRect newFrame = CGRectNull;
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            [self updateAppearance];
        }
    }
}

@end
