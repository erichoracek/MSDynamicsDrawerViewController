//
//  MSDynamicsDrawerPanePosition.h
//  Docs
//
//  Created by Eric Horacek on 6/11/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDynamicsDrawerViewController.h"

/**
 The style that the pane should be bounded with when it is draged against an edge.
 */
typedef NS_ENUM(NSInteger, MSDynamicsDrawerPaneDragEdgeBoundingStyle) {
    /**
     As the pane is dragged against an edge, it should continue to track the gesture.
     */
    MSDynamicsDrawerPaneDragEdgeBoundingStyleNone,
    /**
     As the pane is dragged against an edge, it should provide a small amount of give as it as is dragged past the bounding edge.
     */
    MSDynamicsDrawerPaneDragEdgeBoundingStyleRubberBand,
    /**
     As the pane is dragged against an edge, it should stop when it collides with the edge and allow no further dragging.
     */
    MSDynamicsDrawerPaneDragEdgeBoundingStyleCollision
};

#warning document
@interface MSDynamicsDrawerPaneLayout : NSObject

/**
 Initializes a pane layout with a pane container view.
 
 @param paneContainerView The view that the pane is contained within. Typically the view property on a MSDynamicsDrawerViewController.
 
 @return The initialized pane layout, or nil if there was a problem initializing the object.
 */
- (instancetype)initWithPaneContainerView:(UIView *)paneContainerView;

/**
 The view containing the pane view whose layout is defined by this object.
 */
@property (nonatomic, weak, readonly) UIView *paneContainerView;

#warning document
- (CGPoint)paneCenterForPaneState:(MSDynamicsDrawerPaneState)paneState direction:(MSDynamicsDrawerDirection)direction;

#warning document
- (CGPoint)paneCenterWithTranslation:(CGPoint)translation fromCenter:(CGPoint)paneCenter inDirection:(MSDynamicsDrawerDirection)direction;

///-----------------------
/// @name Reveal Distances
///-----------------------

- (CGFloat)revealDistanceForPaneState:(MSDynamicsDrawerPaneState)state direction:(MSDynamicsDrawerDirection)direction;

/**
 Sets the maximum distance that the `paneView` opens when revealing the `drawerView` underneath for the specified direction.
 
 Defaults to `MSDynamicsDrawerDefaultOpenRevealDistanceHorizontal` when drawer view controllers are set in a horizontal direction. Defaults to `MSDynamicsDrawerDefaultOpenRevealDistanceVertical` when drawer view controllers are set in a vertical direction.
 
 @param openRevealDistance The distance that the `paneView` opens when revealing the `drawerView`.
 @param direction The direction that the `openRevealDistance` should be applied in. Accepts masked direction values.
 
 @see openRevealDistanceForDirection:
 */
- (void)setOpenRevealDistance:(CGFloat)openRevealDistance forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns the reveal distance that the `paneView` opens when revealing the `drawerView` for the specified direction
 
 @param direction The direction that the reveal distance should be returned for. Does not accept masked direction values.
 @return The reveal distance for the specified direction.
 
 @see setOpenRevealDistance:forDirection:
 */
- (CGFloat)openRevealDistanceForDirection:(MSDynamicsDrawerDirection)direction;

/**
 The amount that the paneView should be offset beyond the edge of the screen when set to the `MSDynamicsDrawerPaneStateOpenWide` pane state.
 
 This property controls the amount that the pane view is offset from the edge of the `MSDynamicsDrawerViewController` instance's view when the pane view is in the `MSDynamicsDrawerPaneStateOpenWide` `paneState`. When `paneViewSlideOffAnimationEnabled` is set to `YES`, this property controls the amount that the `paneView` slides beyond the edge of the screen before being replaced, and thus controls the duration of the `setPaneViewController:animated:` animation. If the `paneView` has a shadow, this property can be used to slide the `paneView` far enough beyond the edge of the screen so that its shadow isn't visible during the transition. Default value of to `20.0`.
 
 @see paneState
 @see paneViewSlideOffAnimationEnabled
 @see setPaneViewController:animated:completion:
 */
@property (nonatomic, assign) CGFloat paneStateOpenWideEdgeOffset;

/**
 The current reveal distance for a pane with the specified center for the passed direction.
 
 @param paneCenter <#paneCenter description#>
 @param direction  <#direction description#>
 
 @return <#return value description#>
 */
- (CGFloat)revealDistanceForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

#warning document
- (CGFloat)paneClosedFractionForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

#warning document
- (MSDynamicsDrawerPaneState)nearestStateForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

#warning document
- (BOOL)paneWithCenter:(CGPoint)paneCenter hasReachedOpenWideStateForDirection:(MSDynamicsDrawerDirection)direction;

#warning document
- (BOOL)paneWithCenter:(CGPoint)paneCenter isInValidState:(inout MSDynamicsDrawerPaneState *)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Specifies the behavior of the pane when it is dragged against an edge.
 */
@property (nonatomic, assign) MSDynamicsDrawerPaneDragEdgeBoundingStyle paneDragEdgeBoundingStyle;

@end
