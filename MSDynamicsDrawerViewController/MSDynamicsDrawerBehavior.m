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
        *boundaryPaneSlideDimension = ((containerPaneBoundingSize + [self.drawerViewController.paneLayout maxRevealWidthForDirection:direction]) + 1.0);
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

@interface MSPaneSnapBehavior ()

@property (nonatomic, assign, readwrite) MSDynamicsDrawerPaneState targetPaneState;
@property (nonatomic, assign, readwrite) MSDynamicsDrawerDirection targetDirection;
@property (nonatomic, strong, readwrite) UIAttachmentBehavior *snap;

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

#pragma mark - MSDynamicsDrawerBehavior

- (instancetype)initWithDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
{
    self = [super initWithDrawerViewController:drawerViewController];
    if (self) {
        [self addChildBehavior:self.snap];
    }
    return self;
}

- (void)positionPaneInState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;
{
    self.targetPaneState = paneState;
    self.targetDirection = direction;
    self.snap.anchorPoint = [self targetPointForState:paneState direction:direction];
}

#pragma mark - MSDynamicsDrawerSnapBehavior

- (CGPoint)targetPointForState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    return [self.drawerViewController.paneLayout paneCenterForPaneState:state direction:direction];
//    
//    NSAssert(!MSDynamicsDrawerDirectionIsMasked(direction), @"Target is undefined for a masked direction");
//    CGPoint targetPoint = (CGPoint){CGRectGetMidX(self.drawerViewController.view.bounds), CGRectGetMidY(self.drawerViewController.view.bounds)};
//    CGPoint targetOffset = CGPointZero;
//    CGFloat targetOffsetMultiplier = ((direction & (MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionTop)) ? 1.0 : -1.0);
//    CGFloat *targetOffsetAxis = NULL;
//    if (direction & MSDynamicsDrawerDirectionHorizontal) {
//        targetOffsetAxis = &targetOffset.x;
//    } else if (direction & MSDynamicsDrawerDirectionVertical) {
//        targetOffsetAxis = &targetOffset.y;
//    }
//    if (state == MSDynamicsDrawerPaneStateOpen) {
//        *targetOffsetAxis = ([self.drawerViewController.paneLayout maxRevealWidthForDirection:direction] * targetOffsetMultiplier);
//    }
//    if (state == MSDynamicsDrawerPaneStateOpenWide) {
//        *targetOffsetAxis = ((CGRectGetWidth(self.drawerViewController.view.bounds) + self.drawerViewController.paneLayout.paneStateOpenWideEdgeOffset) * targetOffsetMultiplier);
//    }
//    targetPoint = (CGPoint){(targetPoint.x + targetOffset.x), (targetPoint.y + targetOffset.y)};
//    return targetPoint;
}

static CGFloat const MSDefaultSnapLength = 0.0;
static CGFloat const MSDefaultSnapDamping = 0.75;
static CGFloat const MSDefaultSnapFrequency = 2.5;

- (UIAttachmentBehavior *)snap
{
    if (!_snap) {
        self.snap = ({
            UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.paneItem attachedToAnchor:self.paneItem.center];
            attachmentBehavior.length = MSDefaultSnapLength;
            attachmentBehavior.damping = MSDefaultSnapDamping;
            attachmentBehavior.frequency = MSDefaultSnapFrequency;
            attachmentBehavior;
        });
    }
    return _snap;
}

@end
