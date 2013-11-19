//
//  MSDynamicsDrawerViewController.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MSDynamicsDrawerStyler;

extern const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthHorizontal;
extern const CGFloat MSDynamicsDrawerDefaultOpenStateRevealWidthVertical;

/**
 The drawer direction defines the direction that a `MSDynamicsDrawerViewController` instance's `paneView` can be opened in.
 
 The values can be masked in some (but not all) cases. See the parameters of individual methods to ensure compatibility with the `MSDynamicsDrawerDirection` that is being passed.
 */
typedef NS_OPTIONS(NSInteger, MSDynamicsDrawerDirection) {
    MSDynamicsDrawerDirectionNone       = UIRectEdgeNone,
    MSDynamicsDrawerDirectionTop        = UIRectEdgeTop,
    MSDynamicsDrawerDirectionLeft       = UIRectEdgeLeft,
    MSDynamicsDrawerDirectionBottom     = UIRectEdgeBottom,
    MSDynamicsDrawerDirectionRight      = UIRectEdgeRight,
    MSDynamicsDrawerDirectionHorizontal = (UIRectEdgeLeft | UIRectEdgeRight),
    MSDynamicsDrawerDirectionVertical   = (UIRectEdgeTop | UIRectEdgeBottom),
};

/**
 The possible drawer/pane visibility states of `MSDynamicsDrawerViewController`.
 
 @see paneState
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
typedef NS_ENUM(NSInteger, MSDynamicsDrawerPaneState) {
    MSDynamicsDrawerPaneStateClosed,   // Drawer view entirely hidden by pane view
    MSDynamicsDrawerPaneStateOpen,     // Drawer view revealed to open width
    MSDynamicsDrawerPaneStateOpenWide, // Drawer view entirely visible
};

@class MSDynamicsDrawerViewController;

/**
 `MSDynamicsDrawerViewController` is a container view controller that manages the presentation of a single "pane" view controller overlaid over one or two "drawer" view controllers. The drawer view controllers are hidden by default, but can be exposed by a user-initiaed swipe in the direction that that drawer view controller is set in.
 */
@interface MSDynamicsDrawerViewController : UIViewController

///------------------------------------------
/// @name Managing the Child View Controllers
///------------------------------------------

/**
 The pane view controller is the primary view controller, displayed centered and covering the drawer view controllers.
 
 @see setPaneViewController:animated:completion:
 @see paneState
 */
@property (nonatomic, strong) UIViewController *paneViewController;

/**
 Sets the `paneViewController` with an animated transition.
 
 If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneViewController` setter.
 
 @param paneViewController The `paneViewController` to be added.
 @param animated Whether adding the pane should be animated.
 @param completion An optional completion block called upon the completion of the `paneViewController` being set.
 
 @see paneViewController
 @see paneViewSlideOffAnimationEnabled
 */
- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 Sets the view controller to be revealed as a drawer in the specified direction underneath the pane view controller.
 
 There is a maximum of two drawer view controllers that can be set simultaneously. When a second view controllers is set, it must be in the opposite direction of the first view controller. When a single drawer view controller is set, it can be set in any of the cardinal directions.
 
 @param drawerViewController The view controller to revealed as a drawer
 @param direction The direction that the drawer view controller should be revealed in. Does not accept masked direction values.
 
 @see drawerViewControllerForDirection:
 */
- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns the drawer view controller that has been set for the specified direction.
 
 @param direction The direction that the drawer view controller should be revealed. Must not be masked.
 @return The drawer view controller that has been set for the specified direction. If not yet set, `nil`.
 
 @see setDrawerViewController:forDirection:
 */
- (UIViewController *)drawerViewControllerForDirection:(MSDynamicsDrawerDirection)direction;

/**
 If setting a new `paneViewController` should have an animation that slides off the old view controller before animating the new one into its place.
 
 This animation only occurs when the method `setPaneViewController:animated:completion:` is invoked with an `animated` parameter of `YES`.
 
 @see paneViewController
 @see setPaneViewController:animated:completion:
 */
@property (nonatomic, assign) BOOL paneViewSlideOffAnimationEnabled;

/**
 If the status bar should align with the pane view as the pane view frame is adjusted by both the user gestures and the internal dynamic animator.
 */
@property (nonatomic, assign) BOOL shouldAlignStatusBarToPaneView;

///----------------------------------
/// @name Accessing & Modifying State
///----------------------------------

/**
 The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
 The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal width for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is more than one drawer view controller set, use `setPaneState:inDirection:` instead and specify a direction.
 
 @see setPaneState:inDirection:
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
@property (nonatomic, assign) MSDynamicsDrawerPaneState paneState;

/**
 The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
  The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal width for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is only one drawer view controller set, use `paneState` property instead.
 
 @see paneState
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction;

/**
 Sets the state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
 If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneState` setter. If there is more than one drawer view controller set, use `setPaneState:inDirection:animated:allowUserInterruption:completion:` instead and specify a direction.
 
 @param paneState The state of the pane view.
 @param animated Whether the transition should be animated.
 @param allowUserInterruption If the user should be able to interrupt the pane state transition with gestures.
 @param completion Called upon completion of the update to the pane state. If the user interrupts the transition, the completion will be called when the internal dynamic animator completes.
 
 @see paneState
 @see setPaneState:inDirection:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion;

/**
 Sets the state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
 If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneState` setter. If there is only one drawer view controller set, use `setPaneState:animated:allowUserInterruption:completion:` instead.
 
 @param paneState The state of the pane view.
 @param direction The direction that the `paneState` update should be applied in.
 @param animated Whether the transition should be animated.
 @param allowUserInterruption If the user should be able to interrupt the pane state transition with gestures.
 @param completion Called upon completion of the update to the pane state. If the user interrupts the transition, the completion will be called when the internal dynamic animator completes.
 
 @see paneState
 @see setPaneState:inDirection:
 @see setPaneState:animated:allowUserInterruption:completion:
 */
- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction animated:(BOOL)animated allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion;

/**
 Bounces the `paneView` open to reveal the `drawerView` underneath.
 
 If there is more than one drawer view controller set, use `bouncePaneOpenInDirection:`. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`.
 
 @see bouncePaneOpenInDirection:
 @see bounceElasticity
 @see bounceMagnitude
 */
- (void)bouncePaneOpen;

/**
 Bounces the `paneView` open in the specified direction, revealing the `drawerView` underneath.
 
 If there is only one drawer view controller, use `bouncePaneOpen` instead. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`.
 
 @param direction The direction that the `paneView` will be bounced open in.
  ?
 @see bouncePaneOpen
 @see bounceElasticity
 @see bounceMagnitude
 */
- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction;

/**
 The directions that the `paneView` can be opened in.
 
 Corresponds to the directions that there are drawer view controllers set for. If more than one drawer view controller is set, this will be a bitmask of the directions that the drawer view controllers are set in.
 */
@property (nonatomic, assign, readonly) MSDynamicsDrawerDirection possibleDrawerDirection;

///-------------------------------------
/// @name Configuring Dynamics Behaviors
///-------------------------------------

/**
 The magnitude of the gravity vector that affects the pane view.
 
 Default value of `2.0`. A magnitude value of `1.0` represents an acceleration of 1000 points / second².
 */
@property (nonatomic, assign) CGFloat gravityMagnitude;

/**
 The elasticity applied to the pane view.
 
 Default value of `0.0`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.
 */
@property (nonatomic, assign) CGFloat elasticity;

/**
 The amount of elasticity applied to the pane view when it is bounced open.
 
 Applies when the pane is bounced open. Default value of `0.5`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.
 
 @see bouncePaneOpen
 @see bouncePaneOpenInDirection:
 */
@property (nonatomic, assign) CGFloat bounceElasticity;

/**
 The magnitude of the push vector that is applied to the pane view when bouncePaneOpen is called.
 
 Applies when the pane is bounced open. Default of 60.0. A magnitude value of 1.0 represents an acceleration of 1000 points / second².
 
 @see bouncePaneOpen
 @see bouncePaneOpenInDirection:
 */
@property (nonatomic, assign) CGFloat bounceMagnitude;

///--------------------------
///@name Configuring Gestures
///--------------------------

/**
 Sets if a user-initiated pan gesture on the `paneView` can move the pane in the specified direction.
 
 @param paneDraggingEnabled Whether dragging should be enabled.
 @param direction The direction that dragging should be enabled for. Accepts masked direction values.
 
 @see paneDragRevealEnabledForDirection:
 */
- (void)setPaneDragRevealEnabled:(BOOL)paneDraggingEnabled forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns if a user-initiated pan gesture on the `paneView` can move the pane in the specified direction.
 
 @param direction The direction to check against. Does not accept masked direction values.
 @return If dragging is enabled in the specified direction.
 
 @see setPaneDragRevealEnabled:forDirection:
 */
- (BOOL)paneDragRevealEnabledForDirection:(MSDynamicsDrawerDirection)direction;

/**
 Sets if a user-initiated tap gesture on the `paneView` can close it while it is opened.
 
 @param paneTapToCloseEnabled Whether tap-to-close should be enabled.
 @param direction The direction that tap-to-close should be enabled for. Accepts masked direction values.
 
 @see paneTapToCloseEnabledForDirection:
 */
- (void)setPaneTapToCloseEnabled:(BOOL)paneTapToCloseEnabled forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns if a user-initiated tap gesture on the `paneView` can close it while it is opened.
 
 @param direction The direction to check against. Does not accept masked direction values.
 @return If tap-to-close is enabled for the specified direction.
 
 @see setPaneTapToCloseEnabled:forDirection:
 */
- (BOOL)paneTapToCloseEnabledForDirection:(MSDynamicsDrawerDirection)direction;

/**
 Attempts to register a `UIView` subclass that the pane view should forward dragging through.
 
 When the user drags the `paneView` to reveal the `drawerView` underneath, if the pan gesture is performed on an instance of a class that has been registed as a touch forwarding class, the gesture is ignored. By default, `UISlider` and `UISwitch` are registered as touch forwarding classes.
 
 @param touchForwardingClass The class that should not allow pan gestures through.
 */
- (void)registerTouchForwardingClass:(Class)touchForwardingClass;

///--------------------------
/// @name Configuring Stylers
///--------------------------

/**
 Adds a styler (a class that conforms to the `MSDynamicsDrawerStyler` protocol).
 
 @param styler The styler that should be added.
 @param direction The direction that the styler apply to. Accepts masked direction values.
 
 @see addStylersFromArray:forDirection:
 @see removeStyler:forDirection:
 @see stylersForDirection:
 */
- (void)addStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Removes a styler (a class that conforms to the `MSDynamicsDrawerStyler` protocol).
 
 @param styler The styler that should be removed.
 @param direction The direction that they styler should be removed for. Accepts masked direction values.
 
 @see addStyler:forDirection:
 @see addStylersFromArray:forDirection:
 @see stylersForDirection:
 */
- (void)removeStyler:(id <MSDynamicsDrawerStyler>)styler forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Adds an array of stylers (classes that conform to the `MSDynamicsDrawerStyler` protocol).
 
 @param stylers The array of stylers that should be added.
 @param direction The direction that the stylers apply to. Accepts masked direction values.
 
 @see addStyler:forDirection:
 @see removeStyler:forDirection:
 @see stylersForDirection:
 */
- (void)addStylersFromArray:(NSArray *)stylers forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns an array of the stylers that are set in a specified direction
 
 @param direction The direction that the stylers should be returned for. Accepts masked direction values.
 @return An array of stylers that are
 
 @see addStyler:forDirection:
 @see addStylersFromArray:forDirection:
 @see stylersForDirection:
 */
- (NSArray *)stylersForDirection:(MSDynamicsDrawerDirection)direction;

///-------------------------------
/// @name Configuring Reveal Width
///-------------------------------

/**
 Sets the width that the `paneView` opens when revealing the `drawerView` underneath for the specified direction.
 
 Defaults to `MSDynamicsDrawerDefaultOpenStateRevealWidthHorizontal` when drawer view controllers are set in a horizontal direction. Defaults to `MSDynamicsDrawerDefaultOpenStateRevealWidthVertical` when drawer view controllers are set in a vertical direction.
 
 @param revealWidth The width that the `paneView` opens when revealing the `drawerView`.
 @param direction The direction that the `revealWidth` should be applied in. Accepts masked direction values.
 
 @see
 */
- (void)setRevealWidth:(CGFloat)revealWidth forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns the reveal width that the `paneView` opens when revealing the `drawerView` for the specified direction
 
 @param direction The direction that the reveal width should be returned for. Does not accept masked direction values.
 @return The reveal width for the specified direction.
 */
- (CGFloat)revealWidthForDirection:(MSDynamicsDrawerDirection)direction;

///----------------------
/// @name Container Views
///----------------------

/**
 The drawer view contains the currently visible drawer view controller's view.
 
 The `drawerView` is always presented underneath the `paneView`. The frame of the `drawerView` never moves, and it is not affected by dynamics.
 */
@property (nonatomic, readonly) UIView *drawerView;

/**
 The pane view contains the pane view controller's view.
 
 The user can slide the `paneView` in any of the directions defined in `possibleDrawerDirection` to reveal the drawer view controller underneath. The frame of the `paneView` is frequently updated by internal dynamics and user gestures.
 */
@property (nonatomic, readonly) UIView *paneView;

@end

///----------------
/// @name Functions
///----------------

/**
 The action block used in @see MSDynamicsDrawerDirectionActionForMaskedValues.
 */
typedef void (^MSDynamicsDrawerActionBlock)(MSDynamicsDrawerDirection maskedValue);

/**
 Performs an action on all values within a `MSDynamicsDrawerDirection` direction bitmask.
 
 @param drawerDirection The direction bitmask.
 @param action The action block that should be performed on each of the directions contained within the direction bitmask.
 
 @see MSDynamicsDrawerActionBlock
 */
void MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirection direction, MSDynamicsDrawerActionBlock action);

#import "MSDynamicsDrawerStyler.h"
