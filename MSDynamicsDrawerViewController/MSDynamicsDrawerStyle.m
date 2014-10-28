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

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState != MSDynamicsDrawerPaneStateClosed) {
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
        paneClosedFraction = fminf(fmaxf(0.0, paneClosedFraction), 1.0);
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
@property (nonatomic) NSNumber *_maximumResizeRevealDistanceValue;
@property (nonatomic) NSNumber *_minimumResizeRevealDistanceValue;

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

@interface _MSShadowLayer : CALayer

@property (nonatomic) MSDynamicsDrawerDirection direction;

@end

@implementation _MSShadowLayer

#pragma mark - CALayer

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateShadowPath];
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self updateShadowPath];
}

#pragma mark - _MSShadowLayer

- (void)setDirection:(MSDynamicsDrawerDirection)direction
{
    if (_direction != direction) {
        _direction = direction;
        [self updateShadowPath];
    }
}

- (void)updateShadowPath
{
    CGRect shadowPathRect = self.bounds;
    CGFloat shadowRadius = self.shadowRadius;
    if (self.direction & MSDynamicsDrawerDirectionHorizontal) {
        shadowPathRect = CGRectInset(shadowPathRect, 0.0, -shadowRadius);
    }
    if (self.direction & MSDynamicsDrawerDirectionVertical) {
        shadowPathRect = CGRectInset(shadowPathRect, -shadowRadius, 0.0);
    }
    self.shadowPath = [[UIBezierPath bezierPathWithRect:shadowPathRect] CGPath];
}

@end

@interface _MSShadowView : UIView

@property (nonatomic, readonly) _MSShadowLayer *layer;

@end

@implementation _MSShadowView

+ (Class)layerClass
{
    return [_MSShadowLayer class];
}

@end

@interface MSDynamicsDrawerShadowStyle ()

@property (nonatomic) _MSShadowView *shadowView;

@end

@implementation MSDynamicsDrawerShadowStyle

@dynamic shadowColor;
@dynamic shadowRadius;
@dynamic shadowOpacity;
@dynamic shadowOffset;

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.shadowColor = [UIColor blackColor];
        self.shadowRadius = 10.0;
		self.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeZero;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    if (drawerViewController) {
        self.shadowView.layer.direction = direction;
        [self insertShadowView:self.shadowView inDrawerViewControllerIfNecessary:drawerViewController];
    } else {
        [self.shadowView removeFromSuperview];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState != MSDynamicsDrawerPaneStateClosed) {
        self.shadowView.layer.direction = direction;
        [self insertShadowView:self.shadowView inDrawerViewControllerIfNecessary:drawerViewController];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [self.shadowView removeFromSuperview];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{    
    self.shadowView.layer.direction = direction;
    [self insertShadowView:self.shadowView inDrawerViewControllerIfNecessary:drawerViewController];
}

#pragma mark - MSDynamicsDrawerShadowStyle

- (void)insertShadowView:(UIView *)shadowView inDrawerViewControllerIfNecessary:(MSDynamicsDrawerViewController *)drawerViewController
{
    if (shadowView.superview != drawerViewController.paneView) {
        shadowView.frame = drawerViewController.paneView.bounds;
        shadowView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [drawerViewController.paneView addSubview:shadowView];
    }
    if ([[shadowView.superview subviews] indexOfObject:shadowView] > 0) {
        [drawerViewController.paneView sendSubviewToBack:shadowView];
    }
}

- (_MSShadowView *)shadowView
{
    if (!_shadowView) {
        self.shadowView = [_MSShadowView new];
    }
    return _shadowView;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.shadowView.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.shadowView.layer.shadowColor];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.shadowView.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)shadowOpacity
{
    return self.shadowView.layer.shadowOpacity;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    self.shadowView.layer.shadowRadius = shadowRadius;
}

- (CGFloat)shadowRadius
{
    return self.shadowView.layer.shadowRadius;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    self.shadowView.layer.shadowOffset = shadowOffset;
}

- (CGSize)shadowOffset
{
    return self.shadowView.layer.shadowOffset;
}

@end

@interface MSDynamicsDrawerStatusBarOffsetStyle ()

@property (nonatomic, readwrite, getter=isWindowLited) BOOL windowLifted;
@property (nonatomic) UIView *statusBarContainerView;
@property (nonatomic) UIView *statusBarSnapshotView;
@property (nonatomic) UIStatusBarStyle statusBarSnapshotStyle;
@property (nonatomic) NSValue *statusBarSnapshotFrame;
@property (nonatomic) UIWindowLevel windowLevel;
@property (nonatomic) UIWindowLevel originalWindowLevel;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic) MSDynamicsDrawerDirection direction;

@end

static UIStatusBarStyle const MSUIStatusBarStyleNone = -1;
static CGFloat const MSStatusBarMaximumAdjustmentHeight = 20.0;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarWillChangeOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        self.statusBarSnapshotStyle = MSUIStatusBarStyleNone;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyle

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        self.windowLifted = NO;
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
    self.windowLifted = !MSStatusBarOffsetStyleWillOffset([[UIApplication sharedApplication] statusBarFrame]);
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
            [self.statusBarSnapshotView removeFromSuperview];
            [self.statusBarContainerView removeFromSuperview];
            // Must unlift window after removing status bar snapshot view to prevent stauts bar flickering
            self.windowLifted = NO;
        }
    }
}

#pragma mark - MSDynamicsDrawerStatusBarOffsetStyle

#pragma mark Public

- (void)invalidateStatusBarSnapshot
{
    [self.statusBarSnapshotView removeFromSuperview];
    self.statusBarSnapshotView = nil;
}

#pragma mark Private

- (void)updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:(BOOL)afterScreenUpdates withStatusBarFrame:(CGRect)statusBarFrame paneClosedFraction:(CGFloat)paneClosedFraction
{
    // Invalidate status bar snapshot if the frame has changed (and it's not an in-call status bar)
    if (self.statusBarSnapshotView &&
        self.statusBarSnapshotFrame &&
        !CGRectEqualToRect(statusBarFrame, [self.statusBarSnapshotFrame CGRectValue]) &&
        !MSStatusBarOffsetStyleWillOffset(statusBarFrame))
    {
        [self invalidateStatusBarSnapshot];
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

- (UIWindowLevel)windowLevel
{
    return self.window.windowLevel;
}

- (void)setwindowLevel:(UIWindowLevel)windowLevel
{
    self.window.windowLevel = windowLevel;
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
    return ((maximumWindowLevel <= self.windowLevel) && (maximumWindowLevel != -CGFLOAT_MIN));
}

- (BOOL)dynamicsDrawerWindowIsAboveStatusBar
{
    return (self.windowLevel > UIWindowLevelStatusBar);
}

- (BOOL)canCreateStatusBarSnapshotWithStatusBarFrame:(CGRect)statusBarFrame paneClosedFraction:(CGFloat)paneClosedFraction
{
    return (
        [self dynamicsDrawerIsVisibleBelowStatusBar] &&
        ![self dynamicsDrawerWindowIsAboveStatusBar] &&
        (paneClosedFraction == 1.0) &&
        !MSStatusBarOffsetStyleWillOffset(statusBarFrame) &&
        ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) &&
        ((self.statusBarSnapshotStyle == MSUIStatusBarStyleNone) || ([[UIApplication sharedApplication] statusBarStyle] == self.statusBarSnapshotStyle))
    );
}

- (void)setWindowLifted:(BOOL)dynamicsDrawerWindowLifted
{
    BOOL shouldLiftWindow = (self.dynamicsDrawerViewController.currentDrawerDirection & self.direction);
    if (!shouldLiftWindow && dynamicsDrawerWindowLifted) {
        return;
    }
    if (!_windowLifted && dynamicsDrawerWindowLifted) {
        self.originalWindowLevel = self.windowLevel;
        self.windowLevel = (UIWindowLevelStatusBar + 1.0);
    } else if (_windowLifted && !dynamicsDrawerWindowLifted) {
        self.windowLevel = self.originalWindowLevel;
    }
    _windowLifted = dynamicsDrawerWindowLifted;
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
    if (MSStatusBarOffsetStyleWillOffset(statusBarFrame)) {
        self.windowLifted = NO;
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    [self updateStatusBarSnapshotViewIfPossibleAfterScreenUpdates:YES withStatusBarFrame:statusBarFrame paneClosedFraction:[self paneClosedFraction]];
    if (!MSStatusBarOffsetStyleWillOffset(statusBarFrame)) {
        if (!self.statusBarContainerView.superview) {
            self.windowLifted = NO;
        } else {
            self.windowLifted = YES;
        }
    }
}

- (void)statusBarWillChangeOrientation:(NSNotification *)notification
{
    NSNumber *statusBarOrientationNumber = notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
    if (statusBarOrientationNumber) {
        UIInterfaceOrientation fromStatusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        UIInterfaceOrientation toStatusBarOrientation = [statusBarOrientationNumber integerValue];
        BOOL landscapeToLandscape = (UIInterfaceOrientationIsLandscape(fromStatusBarOrientation) && UIInterfaceOrientationIsLandscape(toStatusBarOrientation));
        BOOL portraitToPortrait = (UIInterfaceOrientationIsPortrait(fromStatusBarOrientation) && UIInterfaceOrientationIsPortrait(toStatusBarOrientation));
        // If the status bar has rotated from landscape to portrait or vice versa, invalidate snapshot
        if (!landscapeToLandscape && !portraitToPortrait) {
            [self invalidateStatusBarSnapshot];
        }
    }
}

@end

BOOL const MSStatusBarOffsetStyleWillOffset(CGRect statusBarFrame)
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
