//
//  MSDynamicsDrawerStyle.m
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
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

#import "MSDynamicsDrawerStyle.h"
#import "MSDynamicsDrawerHelperFunctions.h"

@implementation MSDynamicsDrawerParallaxStyle

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parallaxOffsetFraction = 0.35;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat paneRevealDistance = [drawerViewController.paneLayout openRevealDistanceForDirection:direction];
    CGFloat paneClosedFractionClamped = fmaxf(0.0, fminf(paneClosedFraction, 1.0));
    CGFloat translation = ((paneRevealDistance * paneClosedFractionClamped) * self.parallaxOffsetFraction);
    CGFloat translationSign = ((direction & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft)) ? -1.0 : 1.0);
    translation *= translationSign;
    
    [[self class] setDrawerTranslation:translation forDirection:direction inDrawerViewController:drawerViewController];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [[self class] setDrawerTranslation:0.0 forDirection:direction inDrawerViewController:drawerViewController];
    }
}

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        [[self class] setDrawerTranslation:0.0 forDirection:direction inDrawerViewController:drawerViewController];
    }
}

+ (void)setDrawerTranslation:(CGFloat)translation forDirection:(MSDynamicsDrawerDirection)direction inDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    UIView *drawerViewControllerView = [drawerViewController drawerViewControllerForDirection:direction].view;
    CGAffineTransform drawerViewTransform = drawerViewControllerView.transform;
    if (direction & MSDynamicsDrawerDirectionHorizontal) {
        drawerViewTransform.tx = translation;
    } else if (direction & MSDynamicsDrawerDirectionVertical) {
        drawerViewTransform.ty = translation;
    }
    drawerViewControllerView.transform = drawerViewTransform;
}

@end

@implementation MSDynamicsDrawerFadeStyle

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.closedAlpha = 0.0;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat drawerAlpha = ((1.0 - self.closedAlpha) * (1.0  - paneClosedFraction));
    [[self class] setDrawerAlpha:drawerAlpha forDirection:direction inDrawerViewController:drawerViewController];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [[self class] setDrawerAlpha:1.0 forDirection:direction inDrawerViewController:drawerViewController];
    }
}

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        [[self class] setDrawerAlpha:1.0 forDirection:direction inDrawerViewController:drawerViewController];
    }
}

#pragma mark - MSDynamicsDrawerFadeStyle

+ (void)setDrawerAlpha:(CGFloat)alpha forDirection:(MSDynamicsDrawerDirection)direction inDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    [drawerViewController drawerViewControllerForDirection:direction].view.alpha = alpha;
}

@end

@implementation MSDynamicsDrawerScaleStyle

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.closedScale = 0.1;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat scale;
    if (direction & MSDynamicsDrawerDirectionAll) {
        scale = (1.0 - (paneClosedFraction * self.closedScale));
    } else {
        scale = 1.0;
    }
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform drawerViewTransform = drawerViewController.drawerView.transform;
    drawerViewTransform.a = scaleTransform.a;
    drawerViewTransform.d = scaleTransform.d;
    drawerViewController.drawerView.transform = drawerViewTransform;
}

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform drawerViewTransform = drawerViewController.drawerView.transform;
        drawerViewTransform.a = scaleTransform.a;
        drawerViewTransform.d = scaleTransform.d;
        drawerViewController.drawerView.transform = drawerViewTransform;
    }
}

@end

@interface MSDynamicsDrawerResizeStyle ()

@property (nonatomic, weak) MSDynamicsDrawerViewController *drawerViewController;
@property (nonatomic, strong) NSNumber *_maximumResizeRevealDistanceValue;
@property (nonatomic, strong) NSNumber *_minimumResizeRevealDistanceValue;

@end

@implementation MSDynamicsDrawerResizeStyle

#pragma mark - NSObject

@dynamic minimumResizeRevealDistance;
@dynamic maximumResizeRevealDistance;

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction == MSDynamicsDrawerDirectionNone) {
        return;
    }
    
    UIView *drawerViewControllerView = [[drawerViewController drawerViewControllerForDirection:direction] view];
    drawerViewControllerView.frame = [self _drawerFrameForDrawerViewController:drawerViewController closedFraction:paneClosedFraction forDirection:direction];
}

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        self.drawerViewController = drawerViewController;
        UIView *drawerViewControllerView = [[drawerViewController drawerViewControllerForDirection:direction] view];
        CGFloat paneClosedFraction = [drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:drawerViewController.paneView.center forDirection:direction];
        drawerViewControllerView.frame = [self _drawerFrameForDrawerViewController:drawerViewController closedFraction:paneClosedFraction forDirection:direction];
    } else {
        UIView *drawerViewControllerView = [[self.drawerViewController drawerViewControllerForDirection:direction] view];
        drawerViewControllerView.frame = drawerViewControllerView.superview.bounds;
    }
}

#pragma mark - MSDynamicsDrawerResizeStyle

- (CGRect)_drawerFrameForDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController closedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat minimumResizeRevealDistance;
    if (self._minimumResizeRevealDistanceValue) {
        minimumResizeRevealDistance = [self._minimumResizeRevealDistanceValue floatValue];
    } else {
        minimumResizeRevealDistance = [drawerViewController.paneLayout revealDistanceForPaneState:MSDynamicsDrawerPaneStateOpen direction:direction];
    }
    
    CGFloat maximumRevealDistance;
    if (self._maximumResizeRevealDistanceValue) {
        maximumRevealDistance = [self._maximumResizeRevealDistanceValue floatValue];
    } else {
        maximumRevealDistance = [drawerViewController.paneLayout revealDistanceForPaneState:MSDynamicsDrawerPaneStateOpenWide direction:direction];
    }
    
    // Don't expand beyond the bounds of the drawer view controller
    maximumRevealDistance = fminf(maximumRevealDistance, CGRectGetWidth(drawerViewController.view.bounds));
    
    CGFloat currentRevealDistance = [drawerViewController.paneLayout revealDistanceForPaneWithCenter:drawerViewController.paneView.center forDirection:direction];
    
    UIView *drawerViewControllerView = [[drawerViewController drawerViewControllerForDirection:direction] view];
    CGRect drawerViewFrame = drawerViewControllerView.frame;
    CGFloat *drawerViewSizeComponent = MSSizeComponentForDrawerDirection(&drawerViewFrame.size, direction);
    // Bound to (min <= current <= max)
    if (drawerViewSizeComponent) {
        *drawerViewSizeComponent = fmaxf(minimumResizeRevealDistance, fminf(currentRevealDistance, maximumRevealDistance));
    }
    
    CGRect drawerViewContainerBounds = drawerViewControllerView.superview.bounds;
    CGFloat *drawerViewContainerSizeComponent = MSSizeComponentForDrawerDirection(&drawerViewContainerBounds.size, direction);
    CGFloat *drawerViewOriginComponent = MSPointComponentForDrawerDirection(&drawerViewFrame.origin, direction);
    // If open in right or bottom direction, adjust origin to fit within reveal distance
    if ((direction & (MSDynamicsDrawerDirectionBottom | MSDynamicsDrawerDirectionRight)) && drawerViewOriginComponent && drawerViewContainerSizeComponent && drawerViewSizeComponent) {
        *drawerViewOriginComponent = ceilf(*drawerViewContainerSizeComponent - *drawerViewSizeComponent);
    }
    
    return drawerViewFrame;
}

#pragma mark - MSDynamicsDrawerResizeStyle

- (void)setMinimumResizeRevealDistance:(CGFloat)minimumResizeRevealDistance
{
    self._minimumResizeRevealDistanceValue = @(minimumResizeRevealDistance);
}

- (CGFloat)minimumResizeRevealDistance
{
    return [self._minimumResizeRevealDistanceValue floatValue];
}

- (void)setMaximumResizeRevealDistance:(CGFloat)maximumResizeRevealDistance
{
    self._maximumResizeRevealDistanceValue = @(maximumResizeRevealDistance);
}

- (CGFloat)maximumResizeRevealDistance
{
    return [self._maximumResizeRevealDistanceValue floatValue];
}

@end

@interface MSDynamicsDrawerShadowStyle ()

@property (nonatomic, strong) CALayer *shadowLayer;

@end

@implementation MSDynamicsDrawerShadowStyle

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.shadowColor = [UIColor blackColor];
        self.shadowRadius = 10.0;
		self.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeZero;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification
{
    [self.shadowLayer removeFromSuperlayer];
}

#pragma mark - MSDynamicsDrawerStyle

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        self.shadowLayer = [CALayer layer];
        self.shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:drawerViewController.paneView.frame] CGPath];
        self.shadowLayer.shadowColor = self.shadowColor.CGColor;
        self.shadowLayer.shadowOpacity = self.shadowOpacity;
        self.shadowLayer.shadowRadius = self.shadowRadius;
        self.shadowLayer.shadowOffset = self.shadowOffset;
    } else {
        [self.shadowLayer removeFromSuperlayer];
        self.shadowLayer = nil;
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{    
    if (direction & MSDynamicsDrawerDirectionAll) {
        if (!self.shadowLayer.superlayer) {
            CGRect shadowRect = (CGRect){CGPointZero, drawerViewController.paneView.frame.size};
            if (direction & MSDynamicsDrawerDirectionHorizontal) {
                shadowRect = CGRectInset(shadowRect, 0.0, -self.shadowRadius);
            } else if (direction & MSDynamicsDrawerDirectionVertical) {
                shadowRect = CGRectInset(shadowRect, -self.shadowRadius, 0.0);
            }
            self.shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowRect] CGPath];
            [drawerViewController.paneView.layer insertSublayer:self.shadowLayer atIndex:0];
        }
    } else {
        [self.shadowLayer removeFromSuperlayer];
    }
}

#pragma mark - MSDynamicsDrawerShadowStyle

- (void)setShadowColor:(UIColor *)shadowColor
{
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        self.shadowLayer.shadowColor = [shadowColor CGColor];
    }
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (_shadowOpacity != shadowOpacity) {
        _shadowOpacity = shadowOpacity;
        self.shadowLayer.shadowOpacity = shadowOpacity;
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        self.shadowLayer.shadowRadius = shadowRadius;
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        self.shadowLayer.shadowOffset = shadowOffset;
    }
}

@end

@interface MSDynamicsDrawerStatusBarOffsetStyle ()

@property (nonatomic, strong) UIView *statusBarContainerView;
@property (nonatomic, strong) UIView *statusBarSnapshotView;
@property (nonatomic, assign) UIStatusBarStyle statusBarSnapshotStyle;
@property (nonatomic, strong) NSValue *statusBarSnapshotFrame;
@property (nonatomic, assign) UIWindowLevel dynamicsDrawerWindowLevel;
@property (nonatomic, assign) UIWindowLevel dynamicsDrawerOriginalWindowLevel;
@property (nonatomic, assign) BOOL dynamicsDrawerWindowLifted;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, assign) MSDynamicsDrawerDirection direction;

@end

static UIStatusBarStyle const MSStatusBarStyleNone = -1;
static CGFloat const MSStatusBarMaximumAdjustmentHeight = 20.0;
static BOOL const MSStatusBarFrameExceedsMaximumAdjustmentHeight(CGRect statusBarFrame);

@implementation MSDynamicsDrawerStatusBarOffsetStyle

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarWillChangeFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        self.statusBarSnapshotStyle = MSStatusBarStyleNone;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        self.dynamicsDrawerWindowLifted = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.statusBarContainerView removeFromSuperview];
            CGFloat paneClosedFraction = [drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:drawerViewController.paneView.center forDirection:direction];
            [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:YES withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame] paneClosedFraction:paneClosedFraction];
        });
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState != MSDynamicsDrawerPaneStateClosed) {
        CGFloat paneClosedFraction = [drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:drawerViewController.paneView.center forDirection:direction];
        [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:NO withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame] paneClosedFraction:paneClosedFraction];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    if (!self.statusBarContainerView.superview) {
        [self.dynamicsDrawerViewController.paneView addSubview:self.statusBarContainerView];
    }
    self.dynamicsDrawerWindowLifted = !MSStatusBarFrameExceedsMaximumAdjustmentHeight([[UIApplication sharedApplication] statusBarFrame]);
}

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        self.dynamicsDrawerViewController = drawerViewController;
        self.direction |= direction;
        // Async so if it's called as a part of application:didFinishLaunching: the applicationState is valid to take a screenshot
        dispatch_async(dispatch_get_main_queue(), ^{
            self.window = drawerViewController.view.window;
            // If the drawer is currently opened, recreate snapshot
            if (direction == self.dynamicsDrawerViewController.currentDrawerDirection) {
                CGFloat paneClosedFraction = [drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:drawerViewController.paneView.center forDirection:direction];
                [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:YES withStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame] paneClosedFraction:paneClosedFraction];
            }
        });
    } else {
        self.direction ^= direction;
        // If removed while opened in a specific direction, unstyle
        if (direction == self.dynamicsDrawerViewController.currentDrawerDirection) {
            self.dynamicsDrawerWindowLifted = NO;
            [self.statusBarSnapshotView removeFromSuperview];
            [self.statusBarContainerView removeFromSuperview];
        }
    }
}

#pragma mark - MSDynamicsDrawerStatusBarOffsetStyle

- (void)updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:(BOOL)afterScreenUpdates withStatusBarFrame:(CGRect)statusBarFrame paneClosedFraction:(CGFloat)paneClosedFraction
{
    // Remove the status bar snapshot if the frame has changed (and it's not an in-call status bar)
    if (self.statusBarSnapshotView &&
        self.statusBarSnapshotFrame &&
        !CGRectEqualToRect(statusBarFrame, [self.statusBarSnapshotFrame CGRectValue]) &&
        !MSStatusBarFrameExceedsMaximumAdjustmentHeight(statusBarFrame))
    {
        [self.statusBarSnapshotView removeFromSuperview];
        self.statusBarSnapshotView = nil;
    }
    
    if ([self canCreateStatusBarSnapshotWithStatusBarFrame:statusBarFrame paneClosedFraction:paneClosedFraction]) {
        [self.statusBarSnapshotView removeFromSuperview];
        self.statusBarSnapshotView = [self.window.screen snapshotViewAfterScreenUpdates:afterScreenUpdates];
        self.statusBarSnapshotStyle = [[UIApplication sharedApplication] statusBarStyle];
        self.statusBarSnapshotFrame = [NSValue valueWithCGRect:statusBarFrame];
    }
    
    // Add the status bar snapshot to the container
    if (self.statusBarContainerView && self.statusBarSnapshotView) {
        [self.statusBarContainerView addSubview:self.statusBarSnapshotView];
    }
    
    // Set the frame of the container
    UIInterfaceOrientation statusBarOrientation = statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.statusBarContainerView.frame = (CGRect){CGPointZero, {CGRectGetHeight(statusBarFrame), MSStatusBarMaximumAdjustmentHeight}};
    } else if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        self.statusBarContainerView.frame = (CGRect){CGPointZero, {CGRectGetWidth(statusBarFrame), MSStatusBarMaximumAdjustmentHeight}};
    }
}

- (CGFloat)paneClosedFraction
{
    return [self.dynamicsDrawerViewController.paneLayout paneClosedFractionForPaneWithCenter:self.dynamicsDrawerViewController.paneView.center forDirection:self.dynamicsDrawerViewController.currentDrawerDirection];
}

- (UIWindowLevel)dynamicsDrawerWindowLevel
{
    return self.window.windowLevel;
}

- (void)setDynamicsDrawerWindowLevel:(UIWindowLevel)dynamicsDrawerWindowLevel
{
    self.window.windowLevel = dynamicsDrawerWindowLevel;
}

- (BOOL)dynamicsDrawerIsVisibleBelowStatusBar
{
    CGFloat maximumWindowLevel = -CGFLOAT_MAX;
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        // If window wouldn't obscure status bar (hidden or not overlapping), continue
        if (window.hidden || !CGRectIntersectsRect(window.frame, statusBarFrame) || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
            continue;
        }
        maximumWindowLevel = ((window.windowLevel > maximumWindowLevel) ? window.windowLevel : maximumWindowLevel);
    }
    return ((maximumWindowLevel <= self.dynamicsDrawerWindowLevel) && (maximumWindowLevel != -CGFLOAT_MIN));
}

- (BOOL)dynamicsDrawerWindowIsAboveStatusBar
{
    return (self.dynamicsDrawerWindowLevel > UIWindowLevelStatusBar);
}

- (BOOL)canCreateStatusBarSnapshotWithStatusBarFrame:(CGRect)statusBarFrame paneClosedFraction:(CGFloat)paneClosedFraction
{
    return (
        [self dynamicsDrawerIsVisibleBelowStatusBar] &&
        ![self dynamicsDrawerWindowIsAboveStatusBar] &&
        (paneClosedFraction == 1.0) &&
        !MSStatusBarFrameExceedsMaximumAdjustmentHeight(statusBarFrame) &&
        ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) &&
        ((self.statusBarSnapshotStyle == MSStatusBarStyleNone) || ([[UIApplication sharedApplication] statusBarStyle] == self.statusBarSnapshotStyle))
    );
}

- (void)setDynamicsDrawerWindowLifted:(BOOL)dynamicsDrawerWindowLifted
{
    BOOL shouldLiftWindow = (self.dynamicsDrawerViewController.currentDrawerDirection & self.direction);
    if (!shouldLiftWindow && dynamicsDrawerWindowLifted) {
        return;
    }
    if (!_dynamicsDrawerWindowLifted && dynamicsDrawerWindowLifted) {
        self.dynamicsDrawerOriginalWindowLevel = self.dynamicsDrawerWindowLevel;
        self.dynamicsDrawerWindowLevel = (UIWindowLevelStatusBar + 1.0);
    } else if (_dynamicsDrawerWindowLifted && !dynamicsDrawerWindowLifted) {
        self.dynamicsDrawerWindowLevel = self.dynamicsDrawerOriginalWindowLevel;
    }
    _dynamicsDrawerWindowLifted = dynamicsDrawerWindowLifted;
}

//#define STATUS_BAR_DEBUG

- (UIView *)statusBarContainerView
{
    if (!_statusBarContainerView) {
        self.statusBarContainerView = ({
            UIView *view = [UIView new];
            view.userInteractionEnabled = NO;
            view.clipsToBounds = YES;
#ifdef STATUS_BAR_DEBUG
            view.backgroundColor = [UIColor redColor];
            view.layer.borderColor = [UIColor redColor].CGColor;
            view.layer.borderWidth = 1.0;
#endif
            view;
        });
    }
    return _statusBarContainerView;
}

#pragma mark Observer Callbacks

- (void)statusBarWillChangeFrame:(NSNotification *)notification
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:NO withStatusBarFrame:statusBarFrame paneClosedFraction:[self paneClosedFraction]];
    if (MSStatusBarFrameExceedsMaximumAdjustmentHeight(statusBarFrame)) {
        self.dynamicsDrawerWindowLifted = NO;
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:YES withStatusBarFrame:statusBarFrame paneClosedFraction:[self paneClosedFraction]];
    if (!MSStatusBarFrameExceedsMaximumAdjustmentHeight(statusBarFrame)) {
        if (!self.statusBarContainerView.superview) {
            self.dynamicsDrawerWindowLifted = NO;
        } else {
            self.dynamicsDrawerWindowLifted = YES;
        }
    }
}

@end

static BOOL const MSStatusBarFrameExceedsMaximumAdjustmentHeight(CGRect statusBarFrame)
{
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((statusBarOrientation == UIInterfaceOrientationPortrait) || (statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        return (CGRectGetHeight(statusBarFrame) > MSStatusBarMaximumAdjustmentHeight);
    }
    if ((statusBarOrientation == UIInterfaceOrientationLandscapeLeft) || (statusBarOrientation == UIInterfaceOrientationLandscapeRight)) {
        return (CGRectGetWidth(statusBarFrame) > MSStatusBarMaximumAdjustmentHeight);
    }
    return NO;
}
