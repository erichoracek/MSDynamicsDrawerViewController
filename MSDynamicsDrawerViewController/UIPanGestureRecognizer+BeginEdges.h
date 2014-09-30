//
//  UIPanGestureRecognizer+BeginEdges.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import <UIKit/UIKit.h>

@interface UIPanGestureRecognizer (BeginEdges)

/**
 The edges of a passed view that the gesture recognizer began at. Potentially a mask of UIRectEdge values if the gesture began at multiple edges. UIRectEdgeNone if the gesture did not start at an edge of the view.
 
 @param view The view to query for the begin edges for.
 
 @return The edges that the pan gesture recognizer started at for the passed view.
 */
- (UIRectEdge)ms_didBeginAtEdgesOfView:(UIView *)view;

@end
