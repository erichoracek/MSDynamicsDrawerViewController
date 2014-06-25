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
    MSDynamicsDrawerPaneDragEdgeBoundingStyleElastic,
    /**
     As the pane is dragged against an edge, it should stop when it collides with the edge and allow no further dragging.
     */
    MSDynamicsDrawerPaneDragEdgeBoundingStyleHard
};

@interface MSDynamicsDrawerPaneLayout : NSObject

/**
 Initializes a pane position with a drawer view controller.
 
 @return The initialized pane positioning behavior, or nil if there was a problem initializing the object.
 */
- (instancetype)initWithPaneContainerView:(UIView *)paneContainerView;

/**
 The drawer view controller whose pane position is described by this behavior.
 */
@property (nonatomic, weak, readonly) UIView *paneContainerView;

#warning document
- (CGPoint)paneCenterForPaneState:(MSDynamicsDrawerPaneState)paneState direction:(MSDynamicsDrawerDirection)direction;

#warning document
- (CGPoint)paneCenterWithTranslation:(CGPoint)translation fromCenter:(CGPoint)paneCenter inDirection:(MSDynamicsDrawerDirection)direction;

/**
 Sets the maximum width that the `paneView` opens when revealing the `drawerView` underneath for the specified direction.
 
 Defaults to `MSDynamicsDrawerDefaultMaxRevealWidthHorizontal` when drawer view controllers are set in a horizontal direction. Defaults to `MSDynamicsDrawerDefaultMaxRevealWidthVertical` when drawer view controllers are set in a vertical direction.
 
 @param maxRevealWidth The width that the `paneView` opens when revealing the `drawerView`.
 @param direction The direction that the `maxRevealWidth` should be applied in. Accepts masked direction values.
 
 @see maxRevealWidthForDirection:
 */
- (void)setMaxRevealWidth:(CGFloat)maxRevealWidth forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns the reveal width that the `paneView` opens when revealing the `drawerView` for the specified direction
 
 @param direction The direction that the reveal width should be returned for. Does not accept masked direction values.
 @return The reveal width for the specified direction.
 
 @see setMaxRevealWidth:forDirection:
 */
- (CGFloat)maxRevealWidthForDirection:(MSDynamicsDrawerDirection)direction;

/**
 The amount that the paneView should be offset from the edge of the screen when set to the `MSDynamicsDrawerPaneStateOpenWide`.
 
 This property controls the amount that the pane view is offset from the edge of the `MSDynamicsDrawerViewController` instance's view when the pane view is in the `MSDynamicsDrawerPaneStateOpenWide` `paneState`. When `paneViewSlideOffAnimationEnabled` is set to `YES`, this property controls the amount that the `paneView` slides beyond the edge of the screen before being replaced, and thus controls the duration of the `setPaneViewController:animated:` animation. If the `paneView` has a shadow, this property can be used to slide the `paneView` far enough beyond the edge of the screen so that its shadow isn't visible during the transition. Default value of to `20.0`.
 
 @see paneState
 @see paneViewSlideOffAnimationEnabled
 @see setPaneViewController:animated:completion:
 */
@property (nonatomic, assign) CGFloat paneStateOpenWideEdgeOffset;

#warning document
- (CGFloat)currentRevealWidthForPaneWithCenter:(CGPoint)paneCenter forDirection:(MSDynamicsDrawerDirection)direction;

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
