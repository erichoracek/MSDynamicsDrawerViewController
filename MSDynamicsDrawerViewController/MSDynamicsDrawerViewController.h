//
//  MSDynamicsDrawerViewController.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012-2014 Monospace Ltd. All rights reserved.
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

@class MSPaneBehavior;
@class MSDynamicsDrawerPaneLayout;
@protocol MSDynamicsDrawerStyle;
@protocol MSDynamicsDrawerViewControllerDelegate;
@protocol MSPanePositioningBehavior;
@protocol MSPaneBounceBehavior;

/**
 The drawer direction defines the direction that a `MSDynamicsDrawerViewController` instance's `paneView` can be opened in.
 
 The values can be masked in some (but not all) cases. See the parameters of individual methods to ensure compatibility with the `MSDynamicsDrawerDirection` that is being passed.
 */
typedef NS_OPTIONS(NSInteger, MSDynamicsDrawerDirection) {
    /**
     Represents the state of no direction.
     */
    MSDynamicsDrawerDirectionNone       = UIRectEdgeNone,
    /**
     A drawer that is revealed from underneath the top edge of the pane.
     */
    MSDynamicsDrawerDirectionTop        = UIRectEdgeTop,
    /**
     A drawer that is revealed from underneath the left edge of the pane.
     */
    MSDynamicsDrawerDirectionLeft       = UIRectEdgeLeft,
    /**
     A drawer that is revealed from underneath the bottom edge of the pane.
     */
    MSDynamicsDrawerDirectionBottom     = UIRectEdgeBottom,
    /**
     A drawer that is revealed from underneath the right edge of the pane.
     */
    MSDynamicsDrawerDirectionRight      = UIRectEdgeRight,
    /**
     The drawers that are revealed from underneath both the left and right edges of the pane.
     */
    MSDynamicsDrawerDirectionHorizontal = (UIRectEdgeLeft | UIRectEdgeRight),
    /**
     The drawers that are revealed from underneath both the top and bottom edges of the pane.
     */
    MSDynamicsDrawerDirectionVertical   = (UIRectEdgeTop | UIRectEdgeBottom),
    /**
     The drawers that are revealed from underneath all edges of the pane.
     */
    MSDynamicsDrawerDirectionAll        = UIRectEdgeAll
};

/**
 The possible drawer/pane visibility states of `MSDynamicsDrawerViewController`.
*/
typedef NS_ENUM(NSInteger, MSDynamicsDrawerPaneState) {
    /**
     The the drawer is entirely hidden by the pane.
     */
    MSDynamicsDrawerPaneStateClosed,
    /**
     The drawer is revealed underneath the pane to the specified open width.
     */
    MSDynamicsDrawerPaneStateOpen,
    /**
     The drawer view is entirely visible, with the pane opened wide enough as to no longer be visible.
     */
    MSDynamicsDrawerPaneStateOpenWide,
};

@class MSDynamicsDrawerViewController;

/**
 `MSDynamicsDrawerViewController` is a container view controller that manages the presentation of a single "pane" view controller overlaid over one or two "drawer" view controllers. The drawer view controllers are hidden by default, but can be exposed by a user-initiated swipe in the direction that that drawer view controller is set in.
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

#warning document
- (void)setDrawerViewController:(UIViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction preloadView:(BOOL)preloadView;

/**
 Returns the drawer view controller that has been set for the specified direction.
 
 @param direction The direction that the drawer view controller should be revealed. Must not be masked.
 @return The drawer view controller that has been set for the specified direction. If not yet set, `nil`.
 
 @see setDrawerViewController:forDirection:
 */
- (UIViewController *)drawerViewControllerForDirection:(MSDynamicsDrawerDirection)direction;

/**
 If setting a new `paneViewController` should have an animation that slides off the old view controller before animating the new one into its place.
 
 This animation only occurs when the method `setPaneViewController:animated:completion:` is invoked with an `animated` parameter of `YES`. This is functionally equivalent to always setting the `paneState` to `MSDynamicsDrawerPaneStateOpenWide` prior to replacing the pane view controller. To adjust the amount that the `paneView` slides past the edge of the `MSDynamicsDrawerViewController` instance's view during the transition, use `paneStateOpenWideEdgeOffset`.
 
 @see paneViewController
 @see setPaneViewController:animated:completion:
 @see paneStateOpenWideEdgeOffset
 */
@property (nonatomic, assign) BOOL paneViewSlideOffAnimationEnabled;

///----------------------------------
/// @name Accessing & Modifying State
///----------------------------------

/**
 The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
 The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal distance for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is more than one drawer view controller set, use `setPaneState:inDirection:` instead and specify a direction.
 
 @see setPaneState:inDirection:
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
@property (nonatomic, assign) MSDynamicsDrawerPaneState paneState;

/**
 The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
  The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal distance for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is only one drawer view controller set, use `paneState` property instead.
 
 @param paneState The state that the pane view controller should be updated to be in.
 @param direction The direction that the `paneState` update should be applied in.
 
 @see paneState
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */
- (void)setPaneState:(MSDynamicsDrawerPaneState)paneState inDirection:(MSDynamicsDrawerDirection)direction;

/**
 Sets the state of the pane view as defined in a `MSDynamicsDrawerPaneState`.
 
 If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneState` setter. If there is more than one drawer view controller set, use `setPaneState:inDirection:animated:allowUserInterruption:completion:` instead and specify a direction.
 
 @param paneState The state that the pane view controller should be updated to be in.
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
 
 @param paneState The state that the pane view controller should be updated to be in.
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
 
 If there is more than one drawer view controller set, use `bouncePaneOpenInDirection:`. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`. The bounce can be interrupted by a user touch. To override this behavior, use `bouncePaneOpenAllowUserInterruption:completion:`
 
 @see bouncePaneOpenInDirection:
 @see bouncePaneOpenAllowingUserInterruption:completion:
 @see bouncePaneOpenInDirection:allowUserInterruption:completion:
 */
- (void)bouncePaneOpen;

/**
 Bounces the `paneView` open to reveal the `drawerView` underneath. Executes `completion` when the dynamic animation finishes.
 
 If there is more than one drawer view controller set, use `bouncePaneOpenInDirection:allowUserInterruption:completion:`. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`.
 
 @param allowingUserInterruption If the user should be able to interrupt the bounce animation with gestures.
 @param completion A block that is run when the dynamic animator finishes animating the bounce.
 
 @see bouncePaneOpen
 @see bouncePaneOpenInDirection:
 @see bouncePaneOpenInDirection:allowUserInterruption:completion:
 */
- (void)bouncePaneOpenAllowingUserInterruption:(BOOL)allowingUserInterruption completion:(void (^)(void))completion;

/**
 Bounces the `paneView` open in the specified direction, revealing the `drawerView` underneath.
 
 If there is only one drawer view controller, use `bouncePaneOpen` instead. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`.
 
 @param direction The direction that the `paneView` will be bounced open in.
 ?
 @see bouncePaneOpen
 @see bouncePaneOpenAllowingUserInterruption:completion:
 @see bouncePaneOpenInDirection:allowUserInterruption:completion:
 */
- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction;

/**
 Bounces the `paneView` open in the specified direction, revealing the `drawerView` underneath. Executes `completion` when the dynamic animation finishes.
 
 If there is only one drawer view controller, use `bouncePaneOpenAllowUserInterruption:completion:` instead. When invoked, `bounceElasticity` and `bounceMagnitude` are used as the dynamics values for the `paneView`.
 
 @param direction The direction that the `paneView` will be bounced open in.
 @param allowUserInterruption If the user should be able to interrupt the bounce animation with gestures.
 @param completion A block that is run when the dynamic animator finishes animating the bounce.
 
 @see bouncePaneOpen
 @see bouncePaneOpenAllowingUserInterruption:completion:
 @see bouncePaneOpenInDirection:
 */
- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction allowUserInterruption:(BOOL)allowUserInterruption completion:(void (^)(void))completion;


@property (nonatomic, assign, readonly) MSDynamicsDrawerDirection currentDrawerDirection;

/**
 The directions that the `paneView` can be opened in.
 
 Corresponds to the directions that there are drawer view controllers set for. If more than one drawer view controller is set, this will be a bitmask of the directions that the drawer view controllers are set in.
 */
@property (nonatomic, assign, readonly) MSDynamicsDrawerDirection possibleDrawerDirection;

///---------------------------
/// @name Configuring Dynamics
///---------------------------

/**
 The dynamic behavior that is responsible for positioning the pane view controller.
 
 @see paneState
 @see setPaneState:inDirection:
 @see setPaneState:animated:allowUserInterruption:completion:
 @see setPaneState:inDirection:animated:allowUserInterruption:completion:
 */

#warning rename
@property (nonatomic, strong) MSPaneBehavior <MSPanePositioningBehavior> *panePositioningBehavior;


/**
 The bounce behavior that is responsible for bouncing the pane view controller open.

 @see bouncePaneOpen
 @see bouncePaneOpenInDirection:
 @see bouncePaneOpenAllowingUserInterruption:completion:
 @see bouncePaneOpenInDirection:allowUserInterruption:completion:
 */
@property (nonatomic, strong) MSPaneBehavior <MSPaneBounceBehavior> *paneBounceBehavior;

///-------------------------
/// @name Configuring Layout
///-------------------------

/**
 The pane layout that is responsible for providing the position of the pane to the MSDynamicsDrawerViewController.
 */
@property (nonatomic, strong) MSDynamicsDrawerPaneLayout *paneLayout;

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
 Whether the only pans that can open the drawer should be those that originate from the screen's edges.
 
 If set to `YES`, pans that originate elsewhere are ignored and have no effect on the drawer. This property is designed to mimic the behavior of the `UIScreenEdgePanGestureRecognizer` as applied to the `MSDynamicsDrawerViewController` interaction paradigm. Setting this property to `YES` yields a similar behavior to that of screen edge pans within a `UINavigationController` in iOS7+. Defaults to `NO`.
 
 @see screenEdgePanCancelsConflictingGestures
 */
@property (nonatomic, assign) BOOL paneDragRequiresScreenEdgePan;

/**
 Whether gestures that start at the edge of the screen should be cancelled under the assumption that the user is dragging the pane view to reveal a drawer underneath.
 
  This behavior only applies to edges that have a corresponding drawer view controller set in the same direction as the edge that the gesture originated in. The primary use of this property is the case of having a `UIScrollView` within the view of the active pane view controller. When the drawers are closed and the user starts a pan-like gesture at the edge of the screen, all other conflicting gesture recognizers will be required to fail, yielding to the internal `UIPanGestureRecognizer` in the `MSDynamicsDrawerViewController` instance. Effectually, this property makes it easier for the user to open the drawers. Defaults to `YES`.
 
 @see paneDragRequiresScreenEdgePan
 */
@property (nonatomic, assign) BOOL screenEdgePanCancelsConflictingGestures;

/**
 Attempts to register a `UIView` subclass that the pane view should forward dragging through.
 
 When the user drags the `paneView` to reveal the `drawerView` underneath, if the pan gesture is performed on an instance of a class that has been registed as a touch forwarding class, the gesture is ignored. By default, `UISlider` and `UISwitch` are registered as touch forwarding classes.
 
 @param touchForwardingClass The class that should not allow pan gestures through.
 */
- (void)registerTouchForwardingClass:(Class)touchForwardingClass;

///--------------------------
/// @name Configuring Styles
///--------------------------

/**
 Adds a style (a class that conforms to the `MSDynamicsDrawerStyle` protocol).
 
 @param style The style that should be added.
 @param direction The direction that the style apply to. Accepts masked direction values.
 
 @see addStyles:forDirection:
 @see removeStyle:forDirection:
 @see stylesForDirection:
 */
- (void)addStyle:(id <MSDynamicsDrawerStyle>)style forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Removes a style (a class that conforms to the `MSDynamicsDrawerStyle` protocol).
 
 @param style The style that should be removed.
 @param direction The direction that they style should be removed for. Accepts masked direction values.
 
 @see addStyle:forDirection:
 @see addStyles:forDirection:
 @see stylesForDirection:
 */
- (void)removeStyle:(id <MSDynamicsDrawerStyle>)style forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Adds an array of styles (classes that conform to the `MSDynamicsDrawerStyle` protocol).
 
 @param styles The array of styles that should be added.
 @param direction The direction that the styles apply to. Accepts masked direction values.
 
 @see addStyle:forDirection:
 @see removeStyle:forDirection:
 @see stylesForDirection:
 */
- (void)addStyles:(NSArray *)styles forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Returns an array of the styles that are set in a specified direction
 
 @param direction The direction that the styles should be returned for. Accepts masked direction values.
 @return An array of styles that are
 
 @see addStyle:forDirection:
 @see addStyles:forDirection:
 @see stylesForDirection:
 */
- (NSArray *)stylesForDirection:(MSDynamicsDrawerDirection)direction;

///----------------------
/// @name Container Views
///----------------------

/**
 The drawer view contains the currently visible drawer view controller's view.
 
 The `drawerView` is always presented underneath the `paneView`. The frame of the `drawerView` never moves, and it is not affected by dynamics.
 */
@property (nonatomic, strong, readonly) UIView *drawerView;

/**
 The pane view contains the pane view controller's view.
 
 The user can slide the `paneView` in any of the directions defined in `possibleDrawerDirection` to reveal the drawer view controller underneath. The frame of the `paneView` is frequently updated by internal dynamics and user gestures.
 */
@property (nonatomic, strong, readonly) UIView *paneView;

///------------------------------------
/// @name Accessing the Delegate Object
///------------------------------------

/**
 The delegate you want to receive dynamics drawer view controller messages.
 
 The dynamics drawer view controller informs its delegate of changes to the state of the drawer view controller. For more information about the methods you can implement in your delegate, `MSDynamicsDrawerViewControllerDelegate`.
 */
@property (nonatomic, weak) id <MSDynamicsDrawerViewControllerDelegate> delegate;

@end

/**
 To respond to the updates to `paneState` for an instance of `MSDynamicsDrawerViewController`, configure a custom class to adopt the `MSDynamicsDrawerViewControllerDelegate` protocol and set it as the `delegate` object.
 */
@protocol MSDynamicsDrawerViewControllerDelegate <NSObject>

@optional

/**
 Informs the delegate that the drawer view controller will attempt to update to a pane state in the specified direction.
 
 It is important to note that the user can interrupt this state change, and therefore is it not guaranteed that this update will occur. If desired, the user can be prevented from interrupting by passing `NO` for the `allowingUserInterruption` parameter in methods that update the `paneState`. For the aforementioned reasons, this method does not always pair with an invocation of `dynamicsDrawerViewController:didUpdateToPaneState:forDirection:`.
 
 @param drawerViewController The drawer view controller that the delegate is registered with.
 @param paneState The pane state that the view controller will attempt to update to.
 @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Informs the delegate that the drawer view controller did update to a pane state in the specified direction.
 
 @param drawerViewController The drawer view controller that the delegate is registered with.
 @param paneState The pane state that the view controller did update to.
 @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Queries the delegate for whether the dynamics drawer view controller should begin a pane pan
 
 @param drawerViewController The drawer view controller that the delegate is registered with.
 @param panGestureRecognizer The internal pan gesture recognizer that is responsible for panning the pane. The behavior resulting from modifying attributes of this gesture recognizer is undefined and not recommended.
 
 @return Whether the drawer view controller should begin a pane pan
 */
- (BOOL)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController shouldBeginPanePan:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

// These headers are imported at the bottom of this header file to allow for the only necessary import to be:
// `#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>`
#import "MSDynamicsDrawerStyle.h"
#import "MSDynamicsDrawerBehavior.h"
#import "MSStatusBarOffsetDrawerNavigationController.h"
#import "MSDynamicsDrawerPaneLayout.h"
