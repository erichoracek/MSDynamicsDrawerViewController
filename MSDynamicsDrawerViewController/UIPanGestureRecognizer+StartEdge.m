//
//  UIPanGestureRecognizer+StartEdge.m
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import "UIPanGestureRecognizer+StartEdge.h"

/**
 After testing Apple's `UIScreenEdgePanGestureRecognizer` this seems to be the closest value to create an equivalent effect.
 */
static CGFloat const MSPaneViewScreenEdgeThreshold = 24.0;

@implementation UIPanGestureRecognizer (StartEdge)

- (UIRectEdge)startedAtEdgesOfView:(UIView *)view;
{
    CGPoint translation = [self translationInView:view];
    CGPoint currentLocation = [self locationInView:view];
    CGPoint startLocation = CGPointMake((currentLocation.x - translation.x), (currentLocation.y - translation.y));
    UIEdgeInsets distanceToEdges = (UIEdgeInsets){
        .top = startLocation.y,
        .left = startLocation.x,
        .bottom = (CGRectGetHeight(view.bounds) - startLocation.y),
        .right = (CGRectGetWidth(view.bounds) - startLocation.x)
    };
    UIRectEdge startEdges = UIRectEdgeNone;
    if (distanceToEdges.top < MSPaneViewScreenEdgeThreshold) {
        if (translation.y < 0.0) {
            startEdges |= UIRectEdgeTop;
        }
    }
    if (distanceToEdges.left < MSPaneViewScreenEdgeThreshold) {
        startEdges |= UIRectEdgeLeft;
    }
    if (distanceToEdges.right < MSPaneViewScreenEdgeThreshold) {
        startEdges |= UIRectEdgeRight;
    }
    if (distanceToEdges.bottom < MSPaneViewScreenEdgeThreshold) {
        startEdges |= UIRectEdgeBottom;
    }
    return startEdges;
}

@end
