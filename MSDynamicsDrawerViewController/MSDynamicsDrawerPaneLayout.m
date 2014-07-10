//
//  MSDynamicsDrawerPanePosition.m
//  Docs
//
//  Created by Eric Horacek on 6/11/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
//

#import "MSDynamicsDrawerPaneLayout.h"
#import "MSDynamicsDrawerHelperFunctions.h"

@interface MSDynamicsDrawerPaneLayout ()

@property (nonatomic, weak) UIView *paneContainerView;
@property (nonatomic, strong, setter = _setMaxRevealWidths:) NSMutableDictionary *_maxRevealWidths;
@property (nonatomic, strong, setter = _setpaneCenterCache:) NSMutableDictionary *_paneCenterCache;

@end

@implementation MSDynamicsDrawerPaneLayout

- (instancetype)initWithPaneContainerView:(UIView *)paneContainerView
{
    self = [super init];
    if (self) {
        self.paneContainerView = paneContainerView;
        self.paneStateOpenWideEdgeOffset = 20.0;
        self.paneDragEdgeBoundingStyle = MSDynamicsDrawerPaneDragEdgeBoundingStyleElastic;
    }
    return self;
}

- (CGFloat)revealDistanceForPaneState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction
{
    CGPoint closedCenter = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateClosed direction:direction];
    CGFloat *closedCenterComponent = MSPointComponentForDrawerDirection(&closedCenter, direction);
    
    CGPoint stateCenter = [self paneCenterForPaneState:state direction:direction];
    CGFloat *openCenterComponent = MSPointComponentForDrawerDirection(&stateCenter, direction);

    CGFloat revealDistance = 0.0;
    if (closedCenterComponent && openCenterComponent) {
        revealDistance = fabsf(*openCenterComponent - *closedCenterComponent);
    }
    return revealDistance;
}

static CGFloat const MSDynamicsDrawerDefaultMaxRevealWidthHorizontal = 267.0;
static CGFloat const MSDynamicsDrawerDefaultMaxRevealWidthVertical = 300.0;

- (NSMutableDictionary *)_maxRevealWidths
{
    if (!__maxRevealWidths) {
        self._maxRevealWidths = ({
            NSMutableDictionary *maxRevealWidths = [NSMutableDictionary new];
            MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionHorizontal, ^(MSDynamicsDrawerDirection maskedDirection) {
                maxRevealWidths[@(maskedDirection)] = @(MSDynamicsDrawerDefaultMaxRevealWidthHorizontal);
            });
            MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionVertical, ^(MSDynamicsDrawerDirection maskedDirection) {
                maxRevealWidths[@(maskedDirection)] = @(MSDynamicsDrawerDefaultMaxRevealWidthVertical);
            });
            maxRevealWidths;
        });
    }
    return __maxRevealWidths;
}

- (CGFloat)maxRevealWidthForDirection:(MSDynamicsDrawerDirection)direction;
{
    NSAssert(MSDynamicsDrawerDirectionIsValid(direction), @"Only accepts cardinal directions when querying for reveal width");
    NSNumber *maxRevealWidth = (self._maxRevealWidths[@(direction)] ?: @0.0);
    return [maxRevealWidth floatValue];
}

- (void)setMaxRevealWidth:(CGFloat)maxRevealWidth forDirection:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection){
        self._maxRevealWidths[@(maskedDirection)] = @(maxRevealWidth);
    });
    [self._paneCenterCache removeAllObjects];
}

- (void)setPaneStateOpenWideEdgeOffset:(CGFloat)paneStateOpenWideEdgeOffset
{
    if (_paneStateOpenWideEdgeOffset != paneStateOpenWideEdgeOffset) {
        _paneStateOpenWideEdgeOffset = paneStateOpenWideEdgeOffset;
        [self._paneCenterCache removeAllObjects];
    }
}

static NSString * const MSPaneContainerBoundsKey = @"MSPaneContainerBoundsKey";

- (CGPoint)paneCenterForPaneState:(MSDynamicsDrawerPaneState)paneState direction:(MSDynamicsDrawerDirection)direction
{
    NSAssert(!MSDynamicsDrawerDirectionIsMasked(direction), @"Unable to compute a pane center for a masked direction");
    
    // Lazily create cache
    if (!self._paneCenterCache) {
        self._paneCenterCache = [NSMutableDictionary new];
    }
    
    CGRect paneContainerBounds = self.paneContainerView.bounds;
    
    // Invalidate cache if the pane container bounds have changed
    if (self._paneCenterCache[MSPaneContainerBoundsKey]) {
        CGRect cachedPaneContainerBounds = [self._paneCenterCache[MSPaneContainerBoundsKey] CGRectValue];
        if (!CGRectEqualToRect(paneContainerBounds, cachedPaneContainerBounds)) {
            [self._paneCenterCache removeAllObjects];
        }
    }
    
    if (self._paneCenterCache[@(paneState)][@(direction)]) {
        return [self._paneCenterCache[@(paneState)][@(direction)] CGPointValue];
    }
    
    self._paneCenterCache[MSPaneContainerBoundsKey] = [NSValue valueWithCGRect:paneContainerBounds];
    
    CGPoint paneViewCenter = (CGPoint){
        CGRectGetMidX(paneContainerBounds),
        CGRectGetMidY(paneContainerBounds)
    };
    
    switch ((NSInteger)paneState) {
    case MSDynamicsDrawerPaneStateOpen:
        switch ((NSInteger)direction) {
        case MSDynamicsDrawerDirectionTop:
            paneViewCenter.y += [self maxRevealWidthForDirection:direction];
            break;
        case MSDynamicsDrawerDirectionLeft:
            paneViewCenter.x += [self maxRevealWidthForDirection:direction];
            break;
        case MSDynamicsDrawerDirectionBottom:
            paneViewCenter.y -= [self maxRevealWidthForDirection:direction];
            break;
        case MSDynamicsDrawerDirectionRight:
            paneViewCenter.x -= [self maxRevealWidthForDirection:direction];
            break;
        }
        break;
    case MSDynamicsDrawerPaneStateOpenWide:
        switch ((NSInteger)direction) {
        case MSDynamicsDrawerDirectionTop:
            paneViewCenter.y += (CGRectGetHeight(paneContainerBounds) + self.paneStateOpenWideEdgeOffset);
            break;
        case MSDynamicsDrawerDirectionLeft:
            paneViewCenter.x += (CGRectGetWidth(paneContainerBounds) + self.paneStateOpenWideEdgeOffset);
            break;
        case MSDynamicsDrawerDirectionBottom:
            paneViewCenter.y -= (CGRectGetHeight(paneContainerBounds) + self.paneStateOpenWideEdgeOffset);
            break;
        case MSDynamicsDrawerDirectionRight:
            paneViewCenter.x -= (CGRectGetWidth(paneContainerBounds) + self.paneStateOpenWideEdgeOffset);
            break;
        }
        break;
    }
    if (!self._paneCenterCache[@(paneState)]) {
        self._paneCenterCache[@(paneState)] = [NSMutableDictionary new];
    }
    self._paneCenterCache[@(paneState)][@(direction)] = [NSValue valueWithCGPoint:paneViewCenter];
    return paneViewCenter;
}

- (CGPoint)paneCenterWithTranslation:(CGPoint)translation fromCenter:(CGPoint)paneCenter inDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction == MSDynamicsDrawerDirectionNone) {
        return paneCenter;
    }
    
    CGFloat * const panTranslationComponent = MSPointComponentForDrawerDirection(&translation, direction);
    CGFloat * const paneCenterComponent = MSPointComponentForDrawerDirection(&paneCenter, direction);
    
    *paneCenterComponent += *panTranslationComponent;
    
    // Pane Bounding
    CGFloat closedFraction = [self paneClosedFractionForPaneWithCenter:paneCenter forDirection:direction];
    if ((0.0 <= closedFraction) && (closedFraction <= 1.0)) {
        return paneCenter;
    }
    
    CGPoint paneClosedCenter = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateClosed direction:direction];
    CGPoint paneOpenCenter = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateOpen direction:direction];
    
    CGFloat *relevantBoundingComponent = NULL;
    if (closedFraction > 1.0) {
        relevantBoundingComponent = MSPointComponentForDrawerDirection(&paneClosedCenter, direction);
    } else if (closedFraction < 0.0) {
        relevantBoundingComponent = MSPointComponentForDrawerDirection(&paneOpenCenter, direction);
    }
    
    switch ((NSInteger)self.paneDragEdgeBoundingStyle) {
    case MSDynamicsDrawerPaneDragEdgeBoundingStyleElastic: {
        CGFloat elastictyCoefficient = (CGRectGetWidth(self.paneContainerView.bounds) * .025);
        CGFloat distancePastBoundedCenter = fabsf(*paneCenterComponent - *relevantBoundingComponent);
        CGFloat elasticOffset = elastictyCoefficient * logf( (1.0 / elastictyCoefficient) * distancePastBoundedCenter + 1.0);
        CGFloat elasticOffsetSign = ((*panTranslationComponent > 0.0) ? 1.0 : -1.0);
        *paneCenterComponent = roundf(*relevantBoundingComponent + (elasticOffset * elasticOffsetSign));
        break;
    }
    case MSDynamicsDrawerPaneDragEdgeBoundingStyleHard:
        *paneCenterComponent = *relevantBoundingComponent;
        break;
    }
    return paneCenter;
}

- (CGFloat)currentRevealWidthForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction == MSDynamicsDrawerDirectionNone) {
        return 0.0;
    }
    
    CGPoint paneCenterClosed = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateClosed direction:direction];
    
    CGFloat * const centerComponent = MSPointComponentForDrawerDirection(&paneCenter, direction);
    CGFloat * const centerClosedComponent = MSPointComponentForDrawerDirection(&paneCenterClosed, direction);
    
    if (centerComponent && centerClosedComponent) {
        return fabsf(*centerComponent - *centerClosedComponent);
    }
    return 0.0;
}

- (CGFloat)paneClosedFractionForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction == MSDynamicsDrawerDirectionNone) {
        return 1.0;
    }
    
    CGPoint paneCenterOpened = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateOpen direction:direction];
    CGPoint paneCenterClosed = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateClosed direction:direction];
    
    CGFloat * const centerComponent = MSPointComponentForDrawerDirection(&paneCenter, direction);
    CGFloat * const centerOpenedComponent = MSPointComponentForDrawerDirection(&paneCenterOpened, direction);
    CGFloat * const centerClosedComponent = MSPointComponentForDrawerDirection(&paneCenterClosed, direction);
    
    if (centerComponent && centerOpenedComponent && centerClosedComponent) {
        return ((*centerOpenedComponent - *centerComponent) / (*centerOpenedComponent - *centerClosedComponent));
    }
    return 1.0;
}

- (MSDynamicsDrawerPaneState)nearestStateForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat minDistance = CGFLOAT_MAX;
    MSDynamicsDrawerPaneState minPaneState = NSIntegerMax;
    for (MSDynamicsDrawerPaneState currentPaneState = MSDynamicsDrawerPaneStateClosed; currentPaneState <= MSDynamicsDrawerPaneStateOpenWide; currentPaneState++) {
        CGPoint paneStatePaneCenter = [self paneCenterForPaneState:currentPaneState direction:direction];
        CGFloat distance = sqrtf(powf((paneStatePaneCenter.x - paneCenter.x), 2.0) + powf((paneStatePaneCenter.y - paneCenter.y), 2.0));
        if (distance < minDistance) {
            minDistance = distance;
            minPaneState = currentPaneState;
        }
    }
    return minPaneState;
}

- (BOOL)paneWithCenter:(CGPoint)paneCenter hasReachedOpenWideStateForDirection:(MSDynamicsDrawerDirection)direction
{
    CGPoint openWidePaneCenter = [self paneCenterForPaneState:MSDynamicsDrawerPaneStateOpenWide direction:direction];
    CGFloat * const openWidePaneCenterComponent = MSPointComponentForDrawerDirection(&openWidePaneCenter, direction);
    CGFloat * const currentPaneCenterComponent = MSPointComponentForDrawerDirection(&paneCenter, direction);
    if (!currentPaneCenterComponent || !openWidePaneCenterComponent) {
        return NO;
    }
    if (direction & (MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionTop)) {
        return (*currentPaneCenterComponent >= *openWidePaneCenterComponent);
    }
    if (direction & (MSDynamicsDrawerDirectionRight | MSDynamicsDrawerDirectionBottom)) {
        return (*currentPaneCenterComponent <= *openWidePaneCenterComponent);
    }
    return NO;
}

static CGFloat const MSPaneStatePositionValidityEpsilon = 1.0;

- (BOOL)paneWithCenter:(CGPoint)paneCenter isInValidState:(inout MSDynamicsDrawerPaneState *)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    for (MSDynamicsDrawerPaneState currentPaneState = MSDynamicsDrawerPaneStateClosed; currentPaneState <= MSDynamicsDrawerPaneStateOpenWide; currentPaneState++) {
        CGPoint paneStatePaneViewCenter = [self paneCenterForPaneState:currentPaneState direction:direction];
        if ((fabs(paneStatePaneViewCenter.x - paneCenter.x) < MSPaneStatePositionValidityEpsilon) && (fabs(paneStatePaneViewCenter.y - paneCenter.y) < MSPaneStatePositionValidityEpsilon)) {
            *paneState = currentPaneState;
            return YES;
        }
    }
    return NO;
}

@end
