//
//  MSDynamicsDrawerBehavior.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 5/3/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
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

#import "MSDynamicsDrawerBehavior.h"
#import "MSDynamicsDrawerHelperFunctions.h"

static MSDynamicsDrawerPaneState const MSDynamicsDrawerPaneStateUndefined = -1;
static MSDynamicsDrawerDirection const MSDynamicsDrawerDirectionUndefined = -1;

@interface MSPaneBehavior ()

@property (nonatomic, weak, readwrite) MSDynamicsDrawerViewController *drawerViewController;
@property (nonatomic, weak, readwrite) id <UIDynamicItem> paneItem;
@property (nonatomic, strong, readwrite) UIDynamicItemBehavior *paneBehavior;

@end

@implementation MSPaneBehavior

@synthesize paneItem;
@synthesize drawerViewController = _drawerViewController;

- (instancetype)initWithDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    NSParameterAssert(drawerViewController);
    self = [super init];
    if (self) {
        self.drawerViewController = drawerViewController;
        self.paneItem = self.drawerViewController.paneView;
        [self addChildBehavior:self.paneBehavior];
    }
    return self;
}

- (UIDynamicItemBehavior *)paneBehavior
{
    if (!_paneBehavior) {
        self.paneBehavior = ({
            UIDynamicItemBehavior *behavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paneItem]];
            behavior.allowsRotation = NO;
            behavior;
        });
    }
    return _paneBehavior;
}

@end

@interface MSPaneGravityBehavior ()

@property (nonatomic, assign, readwrite) MSDynamicsDrawerPaneState targetPaneState;
@property (nonatomic, assign, readwrite) MSDynamicsDrawerDirection targetDirection;
@property (nonatomic, strong, readwrite) UIGravityBehavior *gravity;
@property (nonatomic, strong, readwrite) UIPushBehavior *bouncePush;
@property (nonatomic, strong) UICollisionBehavior *boundary;
@property (nonatomic, assign) dispatch_once_t paneBehaviorDefaultConfigurationToken;

@end

@implementation MSPaneGravityBehavior

@synthesize targetDirection;
@synthesize targetPaneState;

#pragma mark - UIDynamicBehavior

- (void)willMoveToAnimator:(UIDynamicAnimator *)dynamicAnimator
{
    self.targetPaneState = MSDynamicsDrawerPaneStateUndefined;
    self.targetDirection = MSDynamicsDrawerDirectionUndefined;
}

#pragma mark - MSPaneBehavior

- (instancetype)initWithDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    self = [super initWithDrawerViewController:drawerViewController];
    if (self) {
        [self addChildBehavior:self.gravity];
        [self addChildBehavior:self.boundary];
        [self addChildBehavior:self.bouncePush];
    }
    return self;
}

static CGFloat const MSDefaultGravityPaneElasticity = 0.25;

- (UIDynamicItemBehavior *)paneBehavior
{
    UIDynamicItemBehavior *paneBehavior = [super paneBehavior];
    // Lazily configure pane behavior to defaults on first access
    dispatch_once(&_paneBehaviorDefaultConfigurationToken, ^{
        paneBehavior.elasticity = MSDefaultGravityPaneElasticity;
    });
    return paneBehavior;
}

#pragma mark - MSDynamicsDrawerGravityBehavior

static CGFloat const MSDefaultGravityMagnitude = 3.5;

- (UIGravityBehavior *)gravity
{
    if (!_gravity) {
        self.gravity = ({
            UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.paneItem]];
            gravity.magnitude = MSDefaultGravityMagnitude;
            gravity;
        });
    }
    return _gravity;
}

- (UIPushBehavior *)bouncePush
{
    if (!_bouncePush) {
        self.bouncePush = ({
            UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.paneItem] mode:UIPushBehaviorModeInstantaneous];
            push.magnitude = 75.0;
            push;
        });
    }
    return _bouncePush;
}

- (UICollisionBehavior *)boundary
{
    if (!_boundary) {
        self.boundary = [[UICollisionBehavior alloc] initWithItems:@[self.paneItem]];
    }
    return _boundary;
}

+ (CGFloat)gravityAngleForPaneState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Indeterminate gravity angle for non-cardinal reveal direction");
    switch (direction) {
        case MSDynamicsDrawerDirectionTop:
            return (CGFloat)((state != MSDynamicsDrawerPaneStateClosed) ? M_PI_2 : (3.0 * M_PI_2));
        case MSDynamicsDrawerDirectionLeft:
            return (CGFloat)((state != MSDynamicsDrawerPaneStateClosed) ? 0.0 : M_PI);
        case MSDynamicsDrawerDirectionBottom:
            return (CGFloat)((state != MSDynamicsDrawerPaneStateClosed) ? (3.0 * M_PI_2) : M_PI_2);
        case MSDynamicsDrawerDirectionRight:
            return (CGFloat)((state != MSDynamicsDrawerPaneStateClosed) ? M_PI : 0.0);
        default:
            return 0.0;
    }
}

- (UIBezierPath *)boundaryPathForPaneState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(MSDynamicsDrawerDirectionIsCardinal(direction), @"Boundary is undefined for a non-cardinal reveal direction");
    CGRect boundary = CGRectZero;
    boundary.origin = (CGPoint){-0.5, -0.5};
    CGRect container = self.drawerViewController.view.bounds;
    
    CGFloat *boundaryPaneSlideDimension = NULL;
    CGFloat containerPaneBoundingSize;
    if (direction & MSDynamicsDrawerDirectionHorizontal) {
        boundaryPaneSlideDimension = &boundary.size.width;
        containerPaneBoundingSize = CGRectGetWidth(container);
        boundary.size.height = (CGRectGetHeight(container) + 1.0);
    } else if (direction & MSDynamicsDrawerDirectionVertical) {
        boundaryPaneSlideDimension = &boundary.size.height;
        containerPaneBoundingSize = CGRectGetHeight(container);
        boundary.size.width = (CGRectGetWidth(container) + 1.0);
    } else {
        return nil;
    }
    switch (state) {
    case MSDynamicsDrawerPaneStateClosed:
        *boundaryPaneSlideDimension = ((containerPaneBoundingSize * 2.0) + self.drawerViewController.paneLayout.paneStateOpenWideEdgeOffset + 1.0);
        break;
    case MSDynamicsDrawerPaneStateOpen:
        *boundaryPaneSlideDimension = ((containerPaneBoundingSize + [self.drawerViewController.paneLayout openRevealDistanceForDirection:direction]) + 1.0);
        break;
    case MSDynamicsDrawerPaneStateOpenWide:
        *boundaryPaneSlideDimension = ((containerPaneBoundingSize * 2.0) + self.drawerViewController.paneLayout.paneStateOpenWideEdgeOffset + 1.0);
        break;
    }
    switch ((NSInteger)direction) {
    case MSDynamicsDrawerDirectionRight:
        boundary.origin.x = ((CGRectGetWidth(container) + 1.0) - boundary.size.width);
        break;
    case MSDynamicsDrawerDirectionBottom:
        boundary.origin.y = ((CGRectGetHeight(container) + 1.0) - boundary.size.height);
        break;
    case MSDynamicsDrawerDirectionNone:
        boundary = CGRectZero;
        break;
    }
    return [UIBezierPath bezierPathWithRect:boundary];
}

#pragma mark - MSPanePositioningBehavior

static NSString * const MSDynamicsDrawerBoundaryIdentifier = @"MSDynamicsDrawerBoundaryIdentifier";

- (void)positionPaneInState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    self.targetPaneState = paneState;
    self.targetDirection = direction;
    self.gravity.angle = [self.class gravityAngleForPaneState:paneState direction:direction];
    [self.boundary removeBoundaryWithIdentifier:MSDynamicsDrawerBoundaryIdentifier];
    [self.boundary addBoundaryWithIdentifier:MSDynamicsDrawerBoundaryIdentifier forPath:[self boundaryPathForPaneState:paneState direction:direction]];
}

#pragma mark - MSPaneBounceBehavior

- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction
{
    self.gravity.angle = [self.class gravityAngleForPaneState:MSDynamicsDrawerPaneStateClosed direction:direction];
    self.bouncePush.angle = [self.class gravityAngleForPaneState:MSDynamicsDrawerPaneStateOpen direction:direction];
    [self.boundary removeBoundaryWithIdentifier:MSDynamicsDrawerBoundaryIdentifier];
    [self.boundary addBoundaryWithIdentifier:MSDynamicsDrawerBoundaryIdentifier forPath:[self boundaryPathForPaneState:MSDynamicsDrawerPaneStateOpen direction:direction]];
    self.bouncePush.active = YES;
}

@end

static CGFloat const MSTargetPointAttachmentOffset = 0.5;

CGPoint MSAttachmentAnchorPoint(MSDynamicsDrawerPaneLayout *layout, CGPoint paneCenter, MSDynamicsDrawerPaneState state, MSDynamicsDrawerDirection direction)
{
    CGPoint targetCenter = [layout paneCenterForPaneState:state direction:direction];
    CGFloat *targetCenterComponent = MSPointComponentForDrawerDirection(&targetCenter, direction);
    CGFloat *currentCenterComponent = MSPointComponentForDrawerDirection(&paneCenter, direction);
    // Add offset to ensure smooth animation
    if (targetCenterComponent && currentCenterComponent) {
        CGFloat sign = ((*targetCenterComponent > *currentCenterComponent) ? -1.0 : 1.0);
        *targetCenterComponent += (sign * MSTargetPointAttachmentOffset);
    }
    return targetCenter;
}

@interface MSPaneSnapBehavior ()

@property (nonatomic, assign, readwrite) MSDynamicsDrawerPaneState targetPaneState;
@property (nonatomic, assign, readwrite) MSDynamicsDrawerDirection targetDirection;
@property (nonatomic, strong) UIAttachmentBehavior *_snap;
@property (nonatomic, assign) BOOL _thrown;

@end

@implementation MSPaneSnapBehavior

@synthesize targetPaneState;
@synthesize targetDirection;

#pragma mark - UIDynamicBehavior

- (void)willMoveToAnimator:(UIDynamicAnimator *)dynamicAnimator
{
    self.targetPaneState = MSDynamicsDrawerPaneStateUndefined;
    self.targetDirection = MSDynamicsDrawerDirectionUndefined;
}

- (void (^)(void))action
{
    if (![super action]) {
        __weak typeof(self) __weak_self = self;
        self.action = ^{
            __strong typeof(self) __strong_self = __weak_self;
            [__strong_self _adjustSnapCoefficientsIfNecessary];
            [__strong_self _removeBehaviorsIfNecessary];
        };
    }
    return [super action];
}

#pragma mark - MSDynamicsDrawerBehavior

static CGFloat const MSSnapBehaviorThrowDampingDefault = 0.55;
static CGFloat const MSSnapBehaviorFrequencyDefault = 3.0;
static CGFloat const MSSnapBehaviorThrowVelocityThresholdDefault = 500.0;

- (instancetype)initWithDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    self = [super initWithDrawerViewController:drawerViewController];
    if (self) {
        [self addChildBehavior:self._snap];
        self.throwDamping = MSSnapBehaviorThrowDampingDefault;
        self.frequency = MSSnapBehaviorFrequencyDefault;
        self.throwVelocityThreshold = MSSnapBehaviorThrowVelocityThresholdDefault;
    }
    return self;
}

static CGFloat const MSSnapBehaviorDefaultDamping = 1.0;

- (void)positionPaneInState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;
{
    self.targetPaneState  = paneState;
    self.targetDirection = direction;
    
    CGPoint paneVelocity = [self.paneBehavior linearVelocityForItem:self.paneItem];
    CGFloat *paneVelocityComponent = MSPointComponentForDrawerDirection(&paneVelocity, direction);
    self._thrown = (paneVelocityComponent && (fabsf(*paneVelocityComponent) > MSSnapBehaviorThrowVelocityThresholdDefault));
    
    self._snap.damping = (self._thrown ? self.throwDamping : MSSnapBehaviorDefaultDamping);
    self._snap.anchorPoint = MSAttachmentAnchorPoint(self.drawerViewController.paneLayout, self.drawerViewController.paneView.center, paneState, direction);
    self._snap.frequency = self.frequency;
}

#pragma mark - MSDynamicsDrawerSnapBehavior

static CGFloat const MSSnapBehaviorThrowRubberBandingDamping = 1.0;

- (void)_adjustSnapCoefficientsIfNecessary
{
    if (!self._thrown) {
        return;
    }
    CGPoint paneCenter = self.drawerViewController.paneView.center;
    CGFloat paneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:paneCenter forDirection:self.targetDirection];
    // If the pane has moved beyond the bounds of its "track", it should rubber-band back in place without "messy" bouncing (damping of 1)
    BOOL shouldRubberBand = ((paneClosedFraction > 1.0) || (paneClosedFraction < 0.0));
    if (shouldRubberBand) {
        self._snap.damping = MSSnapBehaviorThrowRubberBandingDamping;
        self._snap.anchorPoint = MSAttachmentAnchorPoint(self.drawerViewController.paneLayout, self.drawerViewController.paneView.center, self.targetPaneState, self.targetDirection);
    }
}

static CGFloat const MSBehaviorRemovalPaneVelocityThreshold = 5.0;

/**
 If the pane view has a velocity below the threshold and is positioned in valid state, remove the dynamic animator's behaviors to speed up dynamic animator pausing
 */
- (void)_removeBehaviorsIfNecessary
{
    // Determine if the pane is positioned in the target state
    MSDynamicsDrawerPaneState currentPaneState;
    CGPoint paneCenter = self.drawerViewController.paneView.center;
    MSDynamicsDrawerDirection direction = self.drawerViewController.currentDrawerDirection;
    BOOL isPositionedInValidState = [self.drawerViewController.paneLayout paneWithCenter:paneCenter isInValidState:&currentPaneState forDirection:direction];
    BOOL isPositionedInTargetState = (isPositionedInValidState && (currentPaneState == self.targetPaneState));
    // Determine if the velocity is above the removal threshold
    CGPoint paneVelocity = [self.paneBehavior linearVelocityForItem:self.drawerViewController.paneView];
    CGFloat largestVelocityComponent = fmaxf(fabsf(paneVelocity.x), fabsf(paneVelocity.y));
    BOOL isBelowBehaviorRemovalVelocityThreshold = (largestVelocityComponent < MSBehaviorRemovalPaneVelocityThreshold);
    // If both conditiosn are met, remove all behaviors
    if (isPositionedInTargetState && isBelowBehaviorRemovalVelocityThreshold) {
        [self.dynamicAnimator removeAllBehaviors];
    }
}

static CGFloat const MSSnapBehaviorLength = 0.0;

- (UIAttachmentBehavior *)_snap
{
    if (!__snap) {
        self._snap = ({
            UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.paneItem attachedToAnchor:self.paneItem.center];
            attachmentBehavior.length = MSSnapBehaviorLength;
            attachmentBehavior;
        });
    }
    return __snap;
}

@end
