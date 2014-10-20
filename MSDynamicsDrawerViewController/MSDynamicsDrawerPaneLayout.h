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
typedef NS_ENUM(NSInteger, MSDynamicsDrawerPaneBoundingStyle) {
    /**
     As the pane is dragged against an edge, it should continue to track the gesture.
     */
    MSDynamicsDrawerPaneBoundingStyleNone,
    /**
     As the pane is dragged against an edge, it should provide a small amount of give as it as is dragged past the bounding edge.
     */
    MSDynamicsDrawerPaneBoundingStyleRubberBand,
    /**
     As the pane is dragged against an edge, it should stop when it collides with the edge and allow no further dragging.
     */
    MSDynamicsDrawerPaneBoundingStyleCollision
};

/**
 A pane layout is resonsible for calculating the position of the pane when it isn't directly being positioned by a MSPaneBehavior within a dynamic animator. These responsiblities include calculating the pane center in various scenarios, managing the pane reveal distances, and calculating various other layout-related values.
 */
@interface MSDynamicsDrawerPaneLayout : NSObject

/**
 Initializes a pane layout with a pane container view.
 
 @param paneContainerView The view that the pane is contained within. Should be the view property on a MSDynamicsDrawerViewController.
 
 @return The initialized pane layout, or nil if there was a problem initializing the object.
 */
- (instancetype)initWithPaneContainerView:(UIView *)paneContainerView;

/**
 The view containing the pane view whose layout is defined by this object.
 */
@property (nonatomic, weak, readonly) UIView *paneContainerView;

///-----------------------
/// @name Pane Centers
///-----------------------

/**
 The center point of a pane given a specific state and direction.
 
 @param paneState The state of the pane for which the center point is desired.
 @param direction The direction of the pane for which the center point is desired. Can be the "none" direction.
 
 @return The center of the pane.
 */
- (CGPoint)paneCenterForPaneState:(MSDynamicsDrawerPaneState)paneState direction:(MSDynamicsDrawerDirection)direction;

/**
 The pane's center when translated from a specified center position in a direction for a specific bounding style.
 */
- (CGPoint)paneCenterWithTranslation:(CGPoint)translation fromCenter:(CGPoint)paneCenter inDirection:(MSDynamicsDrawerDirection)direction forBoundingStyle:(MSDynamicsDrawerPaneBoundingStyle)boundingStyle;

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
@property (nonatomic) CGFloat paneStateOpenWideEdgeOffset;

/**
 The current reveal distance for a pane with the specified center for the passed direction.
 
 @param paneCenter The center of the pane for which the reveal distance is being calculated for.
 @param direction The direction that the pane is opened in.
 
 @return The reveal distance.
 */
- (CGFloat)revealDistanceForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

/**
 The fraction that the pane is closed with the specified center in a specific direction. When the pane is entirely closed (the drawer is not visible underneath), the closed fraction is 1.0. When the pane is entirely open (the drawer opened to the openRevealDistance) the closed fraction is 0.0. If the pane is opened or closed beyond these bounds, the fraction reflects that, and can therefore be both less than 0.0 and greater than 1.0.
 
 @param The center of the pane for which the closed fraction is being calculated for.
 @param direction The direction that the pane is opened in.
 
 @return The fraction that the pane is closed.
 */
- (CGFloat)paneClosedFractionForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

///-----------------------
/// @name Pane State
///-----------------------

/**
 The nearest pane state for a pane with a given center in a specified direction.
 
 @param paneCenter The center of the pane for which the nearest state is being calculated for.
 @param direction The direction that the pane is opened in.
 
 @return The nearest pane state.
 */
- (MSDynamicsDrawerPaneState)nearestStateForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Whether a pane with the specified center has reached the open wide state.
 
 @param paneCenter The center of the pane.
 @param direction The direction that the pane is opened in.
 
 @return Whether the pane has reached the open wide state.
 */
- (BOOL)paneWithCenter:(CGPoint)paneCenter hasReachedOpenWideStateForDirection:(MSDynamicsDrawerDirection)direction;

/**
 Whether a pane with the specified center is positioned in a valid state.
 
 @param paneCenter The center of the pane.
 @param paneState An inout parameter of the paneState that the pane is positioned in. If the return value of this method is NO, paneState is not set to a value.
 @param direction The direction that the pane is opened in.
 
 @return Whether the pane is positioned in a valid state.
 */
- (BOOL)paneWithCenter:(CGPoint)paneCenter isInValidState:(inout MSDynamicsDrawerPaneState *)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Specifies the behavior of the pane when it is dragged against an edge.
 */
@property (nonatomic) MSDynamicsDrawerPaneBoundingStyle boundingStyle;

@end
